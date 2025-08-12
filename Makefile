ifeq ($(VERSION),)
VERSION := latest
endif

setup: docker/.env
	echo Ready

network:
	docker network create kamailio-example

docker/.env:
	cp docker/env.example docker/.env

local.dev.yml:
	cp docker/local.dev.yml.example docker/local.dev.yml

create-kam-pg:
	docker exec -it kb-kam sh -c "apk add postgresql-client"
	# access kamailio db w/o ask for password
	docker exec -it kb-kam sh -c "echo 'gw-pg:5432:kamailio:root:root' > ~/.pgpass"
	docker exec -it kb-kam sh -c "chmod 0600 ~/.pgpass"
	# seems we need to create a kamailio user since kamdbctl failed to create it correctly
	docker exec -it kb-kam sh -c "psql postgres://kb-pg -c \"CREATE USER kamailio WITH PASSWORD 'kamailio'\"";
	docker exec -it kb-kam sh -c "kamdbctl create";

create-kam-mysql:
	IP=`docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" kb-kam`
	docker exec -it kb-kam sh -c "apk add mysql-client"
	# docker exec -it kb-mysql mysql -uroot -e \
	# 	"use mysql;update user set host='%' where user='root'"
	docker exec -it kb-kam sh -c "kamdbctl create";

up-fs:
	docker compose $(shell if [ -f docker/local.yml ]; then echo -f docker/local.yml; fi) -f docker/fs.yml up -d

down-fs:
	docker compose -f docker/fs.yml down

up-pg:
	docker compose -f docker/db.yml up -d kb-pg
down-pg:
	docker stop kb-pg
bash-pg:
	docker exec -it kb-pg bash

up-mysql:
	docker compose -f docker/db.yml up -d kb-mysql
down-mysql:
	docker stop kb-mysql
bash-mysql:
	docker exec -it kb-mysql bash

up-db:
	docker compose -f docker/db.yml up -d
down-db:
	docker compose -f docker/db.yml down

bash-fs1:
	docker exec -it kb-fs1 bash
log-fs1:
	docker logs -f kb-fs1

up:
	docker compose -f kam.yaml up -d
down:
	docker compose -f kam.yaml down
sh:
	docker exec -it kb-kam sh

up-siremis:
	docker run --rm --name siremisdev-debian10 -p 8080:80 --network kamailio-example siremisdev-debian10

build-rtpe:
	cd docker && docker build -t kb-rtpe -f Dockerfile-rtpe .

up-rtpe:
	docker compose -f docker/rtpe.yml up -d

bash-rtpe:
	docker exec -it kb-rtpe bash

up-perf:
	docker compose -f docker/perf.yml up -d

bash-perf:
	docker exec -it kb-voip-perf bash

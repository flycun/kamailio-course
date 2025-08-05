FROM debian:trixie-20230725
# 清理可能存在的其他源
# ===== 第一步：删除 Debian 默认的 .sources 配置（关键！）=====
RUN rm -f /etc/apt/sources.list.d/debian.sources || true

# ===== 第二步：清空其他可能的 .list 文件 =====
RUN rm -f /etc/apt/sources.list.d/*.list || true
COPY sources.list.163.bullseye /etc/apt/sources.list


RUN apt-get update \
  && apt-get -y --quiet --force-yes upgrade curl iproute2 \
  && apt-get install -y --no-install-recommends ca-certificates gcc g++ make build-essential git libxtables-dev libavfilter-dev \
  libevent-dev libpcap-dev libxmlrpc-core-c3-dev python3-markdown bash\
  libjson-glib-dev default-libmysqlclient-dev libhiredis-dev libssl-dev  libiptc-dev pandoc\
  libcurl4-openssl-dev libavcodec-extra gperf libspandsp-dev libwebsockets-dev libpcre2-dev libopus-dev libmosquitto-dev libwebsockets-dev libbcg729-dev\
  libmnl-dev libnftnl-dev libncurses5-dev libncursesw5-dev\
  && cd /usr/local/src \
  && git clone https://github.com/sipwise/rtpengine.git \
  && cd rtpengine/daemon \
  && make && make install \
  && cp /usr/local/src/rtpengine/daemon/rtpengine /usr/local/bin/rtpengine \
  && rm -Rf /usr/local/src/rtpengine \
  && apt-get purge -y --quiet --force-yes --auto-remove \
  ca-certificates gcc g++ make build-essential git markdown \
  && rm -rf /var/lib/apt/* \
  && rm -rf /var/lib/dpkg/* \
  && rm -rf /var/lib/cache/* \
  && rm -Rf /var/log/* \
  && rm -Rf /usr/local/src/* \
  && rm -Rf /var/lib/apt/lists/* 

VOLUME ["/tmp"]

EXPOSE 23000-32768/udp 22222/udp

COPY ./entrypoint.sh /entrypoint.sh

CMD ["rtpengine", "--config-file", "/etc/rtpengine/rtpengine.conf"]

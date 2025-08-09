# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository is for a Kamailio SIP proxy course that teaches how to build a Session Initiation Protocol (SIP) proxy server. The project implements a complete SIP infrastructure with:

- Kamailio SIP proxy server with topology hiding
- MySQL database for storing configuration and CDRs
- RTPEngine for media handling
- Multiple B2BUA (Back-to-Back User Agent) endpoints
- DNS/ENUM server for routing
- REST API for dynamic routing
- TLS support for secure SIP communication

## Architecture

The system is composed of multiple Docker containers:

1. **kamailio-edge** - Main SIP proxy server
2. **rtpengine-edge** - Media processing engine
3. **db** - MySQL database for Kamailio
4. **Multiple B2BUA containers** - Endpoint SIP clients
5. **bind** - DNS server for ENUM lookups
6. **api** - REST API for dynamic routing decisions
7. **sngrep** - SIP traffic analyzer

The network is separated into internal (172.16.254.0/24) and external (192.168.254.0/24) networks for security isolation.

## Common Development Commands

### Initial Setup
```bash
chmod +x initial_setup.sh
./initial_setup.sh
```

### Starting/Stopping Services
```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# View logs
docker compose logs kamailio-edge
```

### Database Management
```bash
# Access database
docker exec -it db01 mysql -u kamailio -pkamailiorw kamailio

# Reinitialize database
docker exec kamailio-edge sh -c "yes y | kamdbctl reinit kamailio"

# Add users
docker exec kamailio-edge kamctl add username@domain password

# Manage dispatcher entries
docker exec kamailio-edge kamctl dispatcher add 1 sip:172.16.254.100:5060 0 0 '' 'internal_b2bua_01'
```

### Kamailio Management
```bash
# Restart Kamailio
docker restart kamailio-edge

# Check Kamailio status
docker exec kamailio-edge kamctl ul show
docker exec kamailio-edge kamctl dispatcher show

# View configuration
docker exec kamailio-edge cat /etc/kamailio/kamailio.cfg
```

## Code Structure

### Kamailio Configuration
- `kamailio-default/etc/kamailio/` - Main configuration files
- `kamailio.cfg` - Main configuration file that includes other configs
- `globals.cfg` - Global parameters and environment variables
- `modules.cfg` - Module loading configuration
- `routes.cfg` - Routing logic includes
- `routes/*.cfg` - Individual routing logic files
- `modules/*.cfg` - Individual module configurations

### Key Routing Logic Files
- `request_main.cfg` - Main request routing logic
- `handle_register.cfg` - Registration handling
- `remove_codecs_inbound.cfg` - Codec filtering
- `set_rtp_request.cfg` - RTP handling
- `blacklist.cfg` - Security filtering

### Database Schema
The MySQL database contains tables for:
- User locations (subscriber, location)
- Call accounting (acc, acc_cdrs)
- Dispatcher configuration (dispatcher)
- Security filtering (secfilter, htable)
- ENUM records (domain, uri)
- RTP engine configuration (rtpengine)

### API Service
- `api/app/routing.py` - Flask application for dynamic routing
- Provides REST endpoint at `/api/routing` for routing decisions

## Development Workflow

1. Make configuration changes in `kamailio-default/etc/kamailio/`
2. Restart Kamailio service: `docker restart kamailio-edge`
3. Test with B2BUA clients on ports 5091-5094
4. Monitor logs: `docker compose logs kamailio-edge`
5. View traffic with sngrep: `docker exec -it sngrep sngrep`

## Testing

Use the B2BUA containers as SIP endpoints:
- b2bua_internal_01: port 5091
- b2bua_internal_02: port 5092
- b2bua_external_01: port 5093
- b2bua_external_02: port 5094

Monitor traffic with sngrep:
```bash
docker exec -it sngrep sngrep
```
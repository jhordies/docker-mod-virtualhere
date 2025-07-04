[![linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)](https://linuxserver.io)

# [linuxserver/code-server](https://github.com/linuxserver/docker-code-server) VirtualHere Mod

A [Docker Mod](https://github.com/linuxserver/docker-mods) for the LinuxServer Code-Server container that adds VirtualHere USB client support for remote USB device access.

## Mod Installation

Add the docker mod to your container via the `DOCKER_MODS` environment variable.

### docker-compose (recommended)

```yaml
version: "2.1"
services:
  code-server:
    image: lscr.io/linuxserver/code-server:latest
    container_name: code-server
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - DOCKER_MODS=ghcr.io/jhordies/mods:code-server-virtualhere
    volumes:
      - /path/to/appdata/config:/config
      - /lib/modules:/lib/modules:ro
    ports:
      - 8443:8443
    privileged: true
    cap_add:
      - SYS_MODULE
    restart: unless-stopped
```

### docker cli

```bash
docker run -d \
  --name=code-server \
  --privileged \
  --cap-add=SYS_MODULE \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e DOCKER_MODS=ghcr.io/jhordies/mods:code-server-virtualhere \
  -p 8443:8443 \
  -v /path/to/appdata/config:/config \
  -v /lib/modules:/lib/modules:ro \
  --restart unless-stopped \
  lscr.io/linuxserver/code-server:latest
```

## ⚠️ Important Requirements

**This mod requires special privileges and host access:**

- **Privileged mode**: Required for USB kernel module access
- **SYS_MODULE capability**: Needed to load the `vhci-hcd` kernel module
- **Host kernel modules**: Must mount `/lib/modules:/lib/modules:ro` for driver access

**Without these requirements, the VirtualHere client will fail to start.**

## Configuration

The VirtualHere client configuration is automatically created at `/config/virtualhere/config.ini` with default settings:

```ini
# VirtualHere Client Configuration
AutoFind=1
EnableLogging=1
LogLevel=2
```

You can customize this file to:
- Manually specify VirtualHere servers: `ManualHubs=192.168.1.100:7575`
- Adjust logging levels
- Configure client behavior

Logs are stored in `/config/log/virtualhere/`.

## What does this mod do?

This mod:
- Installs the VirtualHere USB client binary
- Configures it to run as a system service
- Enables auto-discovery of VirtualHere servers on your DOCKER network ONLY
- Provides persistent configuration and logging
- Loads required USB/IP kernel modules for device sharing

## Use Cases

- **PlatformIO Development**: Flash firmware to microcontrollers connected to a remote machine
- **Hardware Development**: Access USB devices from a headless development environment  
- **Remote Labs**: Share USB instruments and devices across the network
- **IoT Development**: Program devices connected to a different machine on your network

## Troubleshooting

### Common Issues

**"modprobe: FATAL: Module vhci-hcd not found"**
- Ensure `/lib/modules:/lib/modules:ro` volume is mounted
- Verify container has `--privileged` and `--cap-add=SYS_MODULE`

**"Operation not permitted" when loading modules**
- Container must run in privileged mode
- Host must have the required kernel modules available

**Server not auto detected**
- Multicast didn't reach the container
- Server Host must be set manually with vhclient -t ... or config.ini

### Check Service Status

```bash
# View VirtualHere logs
docker exec code-server tail -f /config/log/virtualhere/vhclient.log

# Check if service is running
docker exec code-server s6-svstat /run/service/vhclient
```

## Requirements

- LinuxServer code-server container
- VirtualHere USB server running on the machine with USB devices  
- Network connectivity between client and server
- Host system with USB/IP kernel modules (`vhci-hcd`)

## Support Info

- Shell access while the container is running: `docker exec -it code-server /bin/bash`
- To monitor the logs of the container in realtime: `docker logs -f code-server`
- Container version number: `docker inspect -f '{{ index .Config.Labels "build_version" }}' code-server`
- Image version number: `docker inspect -f '{{ index .Config.Labels "build_version" }}' lscr.io/linuxserver/code-server:latest`

## Updating Info

Most of our images are static, versioned, and require an image update and container recreation to update the app inside. We do not recommend or support updating apps inside the container. Please consult the [Application Setup](#application-setup) section above to see if it is recommended for the image.

Below are the instructions for updating containers:

### Via Docker Compose

- Update images: `docker-compose pull`
- Update containers: `docker-compose up -d`
- Remove old images: `docker image prune`

### Via Docker Run

- Update the image: `docker pull lscr.io/linuxserver/code-server:latest`
- Stop the running container: `docker stop code-server`
- Delete the container: `docker rm code-server`
- Recreate a new container with the same docker run parameters as instructed above
- Remove old images: `docker image prune`

## Building locally

If you want to make local modifications to this mod for development purposes or just to customize the logic:

```bash
git clone https://github.com/jhordies/docker-mod-virtualhere.git
cd docker-mod-virtualhere
docker build \
  --no-cache \
  --pull \
  -t ghcr.io/jhordies/mods:code-server-virtualhere .
```
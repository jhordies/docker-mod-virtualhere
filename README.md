# VirtualHere USB Client Docker Mod for LinuxServer Code-Server

This docker-mod adds VirtualHere USB client support to LinuxServer's code-server container, enabling USB device sharing over the network for remote development scenarios like PlatformIO firmware flashing.

## Features

- Installs VirtualHere USB client (x64 CLI version)
- Runs as a daemon service with auto-restart
- Persistent configuration storage
- Auto-discovery of VirtualHere servers on local network
- Logging support

## Usage

### Docker Compose

Add the docker-mod to your code-server service:

```yaml
services:
  code-server:
    image: lscr.io/linuxserver/code-server:latest
    environment:
      - DOCKER_MODS=ghcr.io/jhordies/mods:code-server-virtualhere
    volumes:
      - /path/to/config:/config
      - /lib/modules:/lib/modules:ro
    ports:
      - 8443:8443
    privileged: true
    cap_add:
      - SYS_MODULE
```

### Docker Run

```bash
docker run -d \
  --name=code-server \
  --privileged \
  --cap-add=SYS_MODULE \
  -e DOCKER_MODS=ghcr.io/jhordies/mods:code-server-virtualhere \
  -p 8443:8443 \
  -v /path/to/config:/config \
  -v /lib/modules:/lib/modules:ro \
  lscr.io/linuxserver/code-server:latest
```

## Configuration

The VirtualHere client configuration is stored in `/config/virtualhere/config.ini`. The default configuration enables:

- Auto-discovery of VirtualHere servers
- Logging (stored in `/config/log/virtualhere/`)

### Manual Configuration

Edit `/config/virtualhere/config.ini` to customize:

```ini
# VirtualHere Client Configuration
AutoFind=1
EnableLogging=1
LogLevel=2

# Manual server specification (optional)
# ManualHubs=192.168.1.100:7575
```

## Building the Docker Mod

```bash
docker build -t your-registry/virtualhere-mod:latest .
docker push your-registry/virtualhere-mod:latest
```

## Use Cases

- **PlatformIO Development**: Flash firmware to microcontrollers connected to a remote machine
- **Hardware Development**: Access USB devices from a headless development environment
- **Remote Labs**: Share USB instruments and devices across the network

## VS Code Extension Integration

This mod is designed to work with a VS Code extension for device management. The extension can interact with the VirtualHere client through:

- Configuration file manipulation (`/config/virtualhere/config.ini`)
- Log file monitoring (`/config/log/virtualhere/`)
- CLI commands via integrated terminal

## Troubleshooting

### Check Service Status

```bash
# Inside the container
s6-rc -v2 -u change vhclient
```

### View Logs

```bash
# VirtualHere logs
tail -f /config/log/virtualhere/vhclient.log

# Container logs
docker logs code-server
```

### Manual Client Control

```bash
# Inside the container
/usr/local/bin/vhclient -h  # Help
/usr/local/bin/vhclient -t  # List available devices
```

## Requirements

- LinuxServer code-server container
- VirtualHere USB server running on the machine with USB devices
- Network connectivity between client and server
- Host kernel modules access (`/lib/modules` volume mount)
- Privileged container mode with `SYS_MODULE` capability for kernel module loading

## License

This docker-mod follows the same licensing as the base LinuxServer images. VirtualHere client software has its own licensing terms.

## Contributing

1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Test with your code-server setup
5. Submit a pull request

## Support

For issues specific to this docker-mod, please open an issue in this repository.
For VirtualHere client issues, refer to the [VirtualHere documentation](https://www.virtualhere.com/usb_client_software).
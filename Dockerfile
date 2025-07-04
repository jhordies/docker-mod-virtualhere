FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy AS buildstage

ARG TARGETARCH

# Install dependencies
RUN apt-get update && apt-get install -y wget kmod

# Prepare directories and copy system files
RUN mkdir -p /tmp/root/usr/local/bin /tmp/root/usr/local/sbin /tmp/root/usr/lib && \
    cp /sbin/modprobe /tmp/root/usr/local/sbin/ && \
    cp /usr/lib/*/libkmod.so.* /tmp/root/usr/lib/ 2>/dev/null || true

# Download VirtualHere client based on architecture
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        wget -O /tmp/root/usr/local/bin/vhclient https://www.virtualhere.com/sites/default/files/usbclient/vhclientx86_64; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        wget -O /tmp/root/usr/local/bin/vhclient https://www.virtualhere.com/sites/default/files/usbclient/vhclientaarch64; \
    else \
        echo "Unsupported architecture: $TARGETARCH" && exit 1; \
    fi

# Make executable
RUN chmod +x /tmp/root/usr/local/bin/vhclient

# Copy service files
COPY root/ /tmp/root/

FROM scratch
COPY --from=buildstage /tmp/root/ /
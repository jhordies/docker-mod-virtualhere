FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy AS buildstage

# Install VirtualHere USB Client
RUN apt-get update && \
    apt-get install -y wget kmod && \
    mkdir -p /tmp/root/usr/local/bin /tmp/root/usr/local/sbin /tmp/root/usr/lib && \
    cp /sbin/modprobe /tmp/root/usr/local/sbin/ && \
    cp /usr/lib/*/libkmod.so.* /tmp/root/usr/lib/ 2>/dev/null || true && \
    if [ "$(uname -m)" = "x86_64" ]; then \
        wget https://www.virtualhere.com/sites/default/files/usbclient/vhclientx86_64 -O /tmp/root/usr/local/bin/vhclient; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
        wget https://www.virtualhere.com/sites/default/files/usbclient/vhclientaarch64 -O /tmp/root/usr/local/bin/vhclient; \
    fi && \
    chmod +x /tmp/root/usr/local/bin/vhclient

# Copy service files
COPY root/ /tmp/root/

FROM scratch
COPY --from=buildstage /tmp/root/ /
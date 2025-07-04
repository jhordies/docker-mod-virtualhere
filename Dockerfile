FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy AS buildstage

ARG TARGETARCH

# Install dependencies
RUN apt-get update && apt-get install -y wget curl kmod

# Prepare directories and copy system files
RUN mkdir -p /tmp/root/usr/local/bin /tmp/root/usr/local/sbin /tmp/root/usr/lib && \
    cp /sbin/modprobe /tmp/root/usr/local/sbin/ && \
    cp /usr/lib/*/libkmod.so.* /tmp/root/usr/lib/ 2>/dev/null || true

# Download VirtualHere client based on architecture
RUN echo "Building for architecture: $TARGETARCH" && \
    if [ "$TARGETARCH" = "amd64" ]; then \
        URL="https://www.virtualhere.com/sites/default/files/usbclient/vhclientx86_64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        URL="https://www.virtualhere.com/sites/default/files/usbclient/vhclientaarch64"; \
    else \
        echo "Unsupported architecture: $TARGETARCH" && exit 1; \
    fi && \
    echo "Downloading from: $URL" && \
    curl -L -o /tmp/root/usr/local/bin/vhclient "$URL" && \
    echo "Download completed"

# Make executable
RUN chmod +x /tmp/root/usr/local/bin/vhclient

# Copy service files
COPY root/ /tmp/root/

FROM scratch
COPY --from=buildstage /tmp/root/ /
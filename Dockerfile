FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    unzip \
    ca-certificates \
    openssl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create directories
WORKDIR /root
RUN mkdir -p /usr/local/share/xray /usr/local/etc/xray /var/log/xray /etc/xray

# Download and install Xray core
RUN curl -L -H "Cache-Control: no-cache" -o /root/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /root/xray.zip -d /root && \
    mv /root/xray /usr/local/bin/ && \
    mv /root/geosite.dat /usr/local/share/xray/ && \
    mv /root/geoip.dat /usr/local/share/xray/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /root/xray.zip

# Generate a UUID for VLESS (will be used if no UUID is provided in the volume)
RUN echo `/usr/local/bin/xray uuid` > /etc/xray/default_uuid.txt

# Copy config.json template and certificate generation script
COPY config.json.template /usr/local/etc/xray/config.json.template
COPY gen_cert.sh /root/gen_cert.sh
RUN chmod +x /root/gen_cert.sh

# Generate the actual config.json on container start
RUN echo '#!/bin/bash \n\
# Generate SSL certificate if not exists \n\
if [ ! -f /etc/xray/server.crt ] || [ ! -f /etc/xray/server.key ]; then \n\
  echo "Generating self-signed certificate..." \n\
  /root/gen_cert.sh \n\
fi \n\
\n\
# Check if a fixed UUID is provided, otherwise use the default \n\
if [ -f /etc/xray/uuid.txt ]; then \n\
  echo "Using provided UUID from volume..." \n\
  UUID=$(cat /etc/xray/uuid.txt) \n\
else \n\
  echo "Using default generated UUID..." \n\
  UUID=$(cat /etc/xray/default_uuid.txt) \n\
  # Save the UUID for clients to reference \n\
  echo $UUID > /etc/xray/uuid.txt \n\
fi \n\
\n\
# Set up configuration \n\
sed "s/USER_UUID/$UUID/g" /usr/local/etc/xray/config.json.template > /usr/local/etc/xray/config.json \n\
\n\
echo "=============================================" \n\
echo "VLESS Server Configuration:" \n\
echo "Protocol: VLESS" \n\
echo "Port: 443" \n\
echo "UUID: $UUID" \n\
echo "Flow: xtls-rprx-direct" \n\
echo "Network: tcp" \n\
echo "Security: tls" \n\
echo "=============================================" \n\
echo "Starting Xray server..." \n\
exec /usr/local/bin/xray run -config /usr/local/etc/xray/config.json' > /root/start.sh && \
    chmod +x /root/start.sh

# Expose ports
EXPOSE 443

# Start Xray
CMD ["/root/start.sh"] 
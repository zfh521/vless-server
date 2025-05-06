#!/bin/bash

# Get the SNI value or use default
if [ -f /etc/xray/sni.txt ]; then
  SNI=$(cat /etc/xray/sni.txt)
else
  SNI="vless-server"
fi

# Generate a self-signed certificate
openssl req -x509 -newkey rsa:4096 -keyout /etc/xray/server.key -out /etc/xray/server.crt -days 365 -nodes -subj "/CN=$SNI" 
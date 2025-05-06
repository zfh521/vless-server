#!/bin/bash

# Generate a self-signed certificate
openssl req -x509 -newkey rsa:4096 -keyout /etc/xray/server.key -out /etc/xray/server.crt -days 365 -nodes -subj "/CN=vless-server" 
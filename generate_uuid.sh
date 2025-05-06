#!/bin/bash

# Check if uuidgen is available
if command -v uuidgen &> /dev/null; then
    UUID=$(uuidgen)
elif command -v docker &> /dev/null; then
    # Use docker to generate UUID via Xray
    UUID=$(docker run --rm xray-temp 2>/dev/null || docker run --rm --entrypoint /usr/local/bin/xray vless-server uuid)
else
    echo "Error: Neither uuidgen nor docker is available."
    echo "Please install uuidgen or docker to generate a UUID."
    exit 1
fi

# Create certs directory if it doesn't exist
mkdir -p certs

# Save the UUID to file
echo "$UUID" > certs/uuid.txt

echo "Generated UUID: $UUID"
echo "This UUID has been saved to certs/uuid.txt and will be used by the VLESS server."
echo "You'll need this UUID when configuring your VLESS client." 
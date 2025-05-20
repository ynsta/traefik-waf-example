#!/bin/bash

# Check if .env file exists
if [ ! -f .env ]; then
    touch .env
fi

# Retrieve Cloudflare IP ranges
CF_IPS=$(curl -s https://api.cloudflare.com/client/v4/ips | jq -r '.result | (.ipv4_cidrs + .ipv6_cidrs) | join(",")')

# Check if curl command succeeded
if [ -z "$CF_IPS" ]; then
    echo "Error: Unable to retrieve Cloudflare IPs"
    exit 1
fi

# Remove all lines starting with CLOUDFLARE_IPS= using sed
sed -i.old -e '/^CLOUDFLARE_IPS=/d' .env

# Add the new definition
echo "CLOUDFLARE_IPS=,$CF_IPS" >> .env

echo ".env file updated with new Cloudflare IPs"

echo "Restart Traefik to apply changes"

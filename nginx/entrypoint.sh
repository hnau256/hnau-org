#!/bin/sh

set -e

CONFIG_HTTP="/etc/nginx/nginx-http.conf"
CONFIG_HTTPS="/etc/nginx/nginx-https.conf"
CONFIG_MAIN="/etc/nginx/nginx.conf"

# Check if SSL certificates exist
if [ -f "/etc/nginx/ssl/live/upchain.hnau.org/fullchain.pem" ]; then
    echo "SSL certificates found, enabling HTTPS..."
    cp "$CONFIG_HTTPS" "$CONFIG_MAIN"
else
    echo "SSL certificates not found, running in HTTP mode (for certbot)..."
    cp "$CONFIG_HTTP" "$CONFIG_MAIN"
fi

# Start nginx
exec nginx -g 'daemon off;'
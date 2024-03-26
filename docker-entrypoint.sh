#!/bin/sh

set -e

echo "============= ENTRY-POINT ============="

envsubst < /tmp/cgitrc.tmpl > /etc/cgitrc

sudo chown www-data:www-data -R /var/www/cgit/

/usr/bin/dumb-init --rewrite "28:0" -- "$@"
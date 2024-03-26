#!/bin/bash

if [ -z "${SSH_KEY}" ]; then
	echo "=> Please pass your public key in the SSH_KEY environment variable"
	exit 1
fi


echo "=> Adding SSH key"

[ -f "/var/www/.ssh/authorized_keys" ] && rm "/var/www/.ssh/authorized_keys"

mkdir -p            /var/www/.ssh
chmod go-rwx        /var/www/.ssh
echo "${SSH_KEY}" > /var/www/.ssh/authorized_keys
chmod go-rw         /var/www/.ssh/authorized_keys

echo "=> Done!"


chown -R git:git /var/www/.ssh
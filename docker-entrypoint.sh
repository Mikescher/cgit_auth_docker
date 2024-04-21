#!/bin/bash



    set -o nounset   # disallow usage of unset vars  ( set -u )
    set -o errexit   # Exit immediately if a pipeline returns non-zero.  ( set -e )
    set -o errtrace  # Allow the above trap be inherited by all functions in the script.  ( set -E )
    set -o pipefail  # Return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status
    IFS=$'\n\t'      # Set $IFS to only newline and tab.

    # shellcheck disable=SC2034
    cr=$'\n'

    function black() { if [ -t 1 ] && [ -n "$(tput colors)" ] && [ "$(tput colors)" -ge 8 ]; then echo -e "\\x1B[30m$1\\x1B[0m"; else echo "$1"; fi  }
    function red()   { if [ -t 1 ] && [ -n "$(tput colors)" ] && [ "$(tput colors)" -ge 8 ]; then echo -e "\\x1B[31m$1\\x1B[0m"; else echo "$1"; fi; }
    function green() { if [ -t 1 ] && [ -n "$(tput colors)" ] && [ "$(tput colors)" -ge 8 ]; then echo -e "\\x1B[32m$1\\x1B[0m"; else echo "$1"; fi; }
    function yellow(){ if [ -t 1 ] && [ -n "$(tput colors)" ] && [ "$(tput colors)" -ge 8 ]; then echo -e "\\x1B[33m$1\\x1B[0m"; else echo "$1"; fi; }
    function blue()  { if [ -t 1 ] && [ -n "$(tput colors)" ] && [ "$(tput colors)" -ge 8 ]; then echo -e "\\x1B[34m$1\\x1B[0m"; else echo "$1"; fi; }
    function purple(){ if [ -t 1 ] && [ -n "$(tput colors)" ] && [ "$(tput colors)" -ge 8 ]; then echo -e "\\x1B[35m$1\\x1B[0m"; else echo "$1"; fi; }
    function cyan()  { if [ -t 1 ] && [ -n "$(tput colors)" ] && [ "$(tput colors)" -ge 8 ]; then echo -e "\\x1B[36m$1\\x1B[0m"; else echo "$1"; fi; }
    function white() { if [ -t 1 ] && [ -n "$(tput colors)" ] && [ "$(tput colors)" -ge 8 ]; then echo -e "\\x1B[37m$1\\x1B[0m"; else echo "$1"; fi; }


echo ""
echo "============= SETUP CGIT ============="
echo ""

export DOLLAR='$'
envsubst < /tmp/cgitrc.tmpl > /etc/cgitrc

if [ "${CGIT_CACHE:-1}" == "1" ]; then
    echo "[CGIT_CACHE := 1]"
    perl -0777 -i -pe 's|#\{\{BEGIN CGIT_CACHE=0\}\}.*?\{\{END\}\}||gs' /etc/cgitrc
else
    echo "[CGIT_CACHE := 0]"
    perl -0777 -i -pe 's|#\{\{BEGIN CGIT_CACHE=1\}\}.*?\{\{END\}\}||gs' /etc/cgitrc
fi

if [ "${CGIT_AUTH:-1}" == "1" ]; then
    echo "[CGIT_AUTH := 1]"

    perl -0777 -i -pe 's|#\{\{BEGIN CGIT_AUTH=0\}\}.*?\{\{END\}\}||gs' /etc/cgitrc

    [ -z "${DEFAULT_USER:-}" ] && { red "missing env DEFAULT_USER -- cannot setup auth"; exit 1; }
    [ -z "${DEFAULT_PASS:-}" ] && { red "missing env DEFAULT_PASS -- cannot setup auth"; exit 1; }
    [ -z "${AUTH_TTL:-}" ]     && { red "missing env AUTH_TTL -- cannot setup auth"; exit 1; }

    envsubst < /tmp/auth.lua > /opt/auth.lua

    chmod +Xx /opt/auth.lua

else
    echo "[CGIT_AUTH := 0]"
    perl -0777 -i -pe 's|#\{\{BEGIN CGIT_AUTH=1\}\}.*?\{\{END\}\}||gs' /etc/cgitrc
fi

sudo chown git:git -R /cgit/

echo ""

/usr/share/webapps/cgit/cgit --version

echo ""
echo "============= SETUP GIT ============="
echo ""

touch /var/www/.gitconfig       && chown git:git /var/www/.gitconfig
touch /var/www/.git-credentials && chown git:git /var/www/.git-credentials
touch /var/www/.bash_profile    && chown git:git /var/www/.bash_profile

su -c 'git config --global init.defaultBranch master' git

echo "cd /cgit" >> "/var/www/.bash_profile"

echo ""
echo "============ SSHD KEYGEN ============"
echo ""

if find "/etc/ssh" | grep -E         "^ssh_host_"; then

    echo "Keys already exist ??!?"

elif [ -d "/config/ssh_host" ]; then

    cp -v /config/ssh_host/* "/etc/ssh"
    chown root:root /etc/ssh/ssh_host_*
    chmod 600 /etc/ssh/ssh_host_*
    chmod 644 /etc/ssh/ssh_host_*.pub

else

    mkdir -p "/config/ssh_host"
    cd "/etc/ssh"
    ssh-keygen -A
    cp /etc/ssh/ssh_host_* "/config/ssh_host/"

fi

echo ""
echo "=========== SET SSHD ROOT PW =========="
echo ""

/set_root_pw.sh

echo ""
echo "================= SSHD ================"
echo ""

mkdir -p /var/run/sshd
chmod 0755 /var/run/sshd

/usr/sbin/sshd

echo ""
echo "================ HTTPD ================"
echo ""

/usr/bin/dumb-init --rewrite "28:0" -- "$@"

echo ""
echo "============== FINISHED ==============="
echo ""

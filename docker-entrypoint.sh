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

envsubst < /tmp/cgitrc.tmpl > /etc/cgitrc

sudo chown git:git -R /cgit/

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

/usr/sbin/sshd

echo ""
echo "================ HTTPD ================"
echo ""

/usr/bin/dumb-init --rewrite "28:0" -- "$@"

echo ""
echo "============== FINISHED ==============="
echo ""

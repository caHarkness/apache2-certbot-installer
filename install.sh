#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "This installation script must be ran as root"
  exit
fi

export CURRENT_DIR="$(dirname "$0")"
export CERTBOT_URL="https://github.com/letsencrypt/letsencrypt"
export CERTBOT_DIR="$CURRENT_DIR/certbot"
export SSL_DIR="$CURRENT_DIR/ssl"
export CSR_PATH="${SSL_DIR}/csr.pem"
export CERT_PATH="${SSL_DIR}/cert.pem"
export KEY_PATH="${SSL_DIR}/privkey.pem"
export FULLCHAIN_PATH="${SSL_DIR}/fullchain.pem"
export CHAIN_PATH="${SSL_DIR}/chain.pem"
export CONFIG_DIR="${SSL_DIR}/config"

cd "$CURRENT_DIR"

source settings.sh

#
#   Warn about deleting the Certbot directory
#
echo "WARNING:"
echo "This script is about to delete the contents of the following directories:"
echo $CERTBOT_DIR
echo ""

read -p "Type 'Y' if you wish to continue " PROMPT
if [[ $PROMPT == "Y" ]]
then
    echo "OK."
else
    echo "Aborted."
    exit 0
fi

rm -rf "$CERTBOT_DIR"

#
#   Warn about cloning Certbot and writing to the certificate directory
#
echo "WARNING:"
echo "This script is about to: "
echo "...clone '$CERTBOT_URL' to '$CERTBOT_DIR'"
echo "...write to '$SSL_DIR'"
echo ""

read -p "Type 'Y' if you wish to continue " PROMPT
if [[ $PROMPT == "Y" ]]
then
    echo "OK."
else
    echo "Aborted."
    exit 0
fi

if [ ! -d "${CERTBOT_DIR}" ];
then
    echo "Cloning Certbot..."
    git clone "$CERTBOT_URL" "$CERTBOT_DIR"
fi

source update-www.sh
source update-www-ssl.sh $(source list-www.sh)

chown -R www-data:www-data "$WEB_ROOT"
chmod -R 0755 "$WEB_ROOT"
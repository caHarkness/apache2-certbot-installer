#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "This installation script must be ran as root"
  exit
fi

export REAL_PATH="$(realpath "$0")"
export CURRENT_DIR="$(dirname "$REAL_PATH")"
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

if [ ! -d "${CERTBOT_DIR}" ];
then
    #
    #   Warn about cloning Certbot and writing to the certificate directory
    #
    echo ""
    echo "WARNING:"
    echo "This script is about to clone '$CERTBOT_URL' to '$CERTBOT_DIR'"
    echo ""

    read -p "Type 'YES' if you wish to continue " PROMPT
    if [[ $PROMPT == "YES" ]]
    then
        echo "OK."
    else
        echo "Aborted."
        exit 0
    fi

    echo "Cloning Certbot..."
    git clone "$CERTBOT_URL" "$CERTBOT_DIR"
fi

source update-www.sh
source update-www-ssl.sh $(source list-www.sh)

chown -R www-data:www-data "$SSL_DIR"
chmod -R 0755 "$SSL_DIR"

chown -R www-data:www-data "$WEB_ROOT"
chmod -R 0755 "$WEB_ROOT"
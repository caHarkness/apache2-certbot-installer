#!/bin/bash

if [ "$#" -lt 1 ]
then
    echo "Usage: $0 domain [domain...]" >&2
    exit 1
fi

echo ""
echo "WARNING:"
echo "This script is about to STOP the apache2 service in order to create Let's Encrypt certificates and verify domain authenticity. The apache2 service will restart after this completes."
echo ""
echo "Is '$CERTBOT_EMAIL' the correct e-mail address?"
echo ""

read -p "Type 'YES' if you wish to continue " PROMPT
if [[ $PROMPT == "YES" ]]
then
    echo "OK."
else
    echo "Aborted."
    exit 0
fi

OPENSSL_DOMAINS="DNS:$1"
CERTBOT_DOMAINS="$1"

shift
for x in "$@"
do
    OPENSSL_DOMAINS="${OPENSSL_DOMAINS},DNS:${x}"
    CERTBOT_DOMAINS="${CERTBOT_DOMAINS},${x}"
done

echo ""
echo "WARNING:"
echo "The following files are going to be deleted if they already exist:"
echo "$CSR_PATH"
echo "$CERT_PATH"
echo "$KEY_PATH"
echo "$FULLCHAIN_PATH"
echo "$CHAIN_PATH"
echo ""

read -p "Type 'YES' if you wish to continue " PROMPT
if [[ $PROMPT == "YES" ]]
then
    echo "OK."
else
    echo "Aborted."
    exit 0
fi

rm -rf ${CSR_PATH}
rm -rf ${CERT_PATH}
rm -rf ${KEY_PATH}
rm -rf ${FULLCHAIN_PATH}
rm -rf ${CHAIN_PATH}

mkdir ${SSL_DIR}

service apache2 stop

openssl req \
    -new -nodes -subj "/" \
    -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=${OPENSSL_DOMAINS}")) \
    -out ${CSR_PATH} \
    -keyout ${KEY_PATH} \
    -newkey rsa:2048 \
    -outform DER

bash ${CERTBOT_DIR}/certbot-auto certonly \
    --standalone \
    --non-interactive \
    --agree-tos \
    --email ${CERTBOT_EMAIL} \
    --force-renewal \
    --expand \
    --no-self-upgrade \
    -d ${CERTBOT_DOMAINS} \
    --csr ${CSR_PATH} \
    --cert-path ${CERT_PATH} \
    --key-path ${KEY_PATH} \
    --fullchain-path ${FULLCHAIN_PATH} \
    --chain-path ${CHAIN_PATH} \
    --config-dir ${CONFIG_DIR}

service apache2 start
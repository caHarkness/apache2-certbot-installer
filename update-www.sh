#!/bin/bash

TEMP=""

#
#   Permit www-data to the site configuration directories
#
chown -R www-data:www-data $SITES_ENABLED_DIR
chown -R www-data:www-data $SITES_AVAILABLE_DIR
chown -R www-data:www-data $WEB_ROOT
chmod -R 0755 $WEB_ROOT

#
#   Warn about deleting the site configuration files
#
echo "WARNING:"
echo "This script is about to delete the contents of the following directories:"
echo $SITES_ENABLED_DIR
echo $SITES_AVAILABLE_DIR
echo ""

read -p "Type 'Y' if you wish to continue " PROMPT
if [[ $PROMPT == "Y" ]]
then
    # Continue
else
    echo "Aborted."
    exit 0
fi

rm -rf "$SITES_ENABLED_DIR/*"
rm -rf "$SITES_AVAILABLE_DIR/*"

#
#   Read the sites.list file and create both HTTP and HTTPS configurations for them
#
while read LINE;
do
    #
    #   Read the template configuration files for both HTTP and HTTPS versions of the site
    #
    HTTP_CONFIG="$(<template.conf)"
    HTTPS_CONFIG="$(<template-ssl.conf)"
    
    #
    #   Extrapolate which site is being processed from the line being read from the sites.list file
    #
    IFS=" "
    set - $LINE
    SERVER_NAME=$1
    DOCUMENT_ROOT=$2

    #
    #   Replace the placeholder occurrences with their respective values
    #
    HTTP_CONFIG=${HTTP_CONFIG//__SERVER_NAME__/$SERVER_NAME}
    HTTP_CONFIG=${HTTP_CONFIG//__DOCUMENT_ROOT__/$DOCUMENT_ROOT}

    HTTPS_CONFIG=${HTTPS_CONFIG//__SERVER_NAME__/$SERVER_NAME}
    HTTPS_CONFIG=${HTTPS_CONFIG//__DOCUMENT_ROOT__/$DOCUMENT_ROOT}

    HTTPS_CONFIG=${HTTPS_CONFIG//__CERT_PATH__/$CERT_PATH}
    HTTPS_CONFIG=${HTTPS_CONFIG//__KEY_PATH__/$KEY_PATH}
    HTTPS_CONFIG=${HTTPS_CONFIG//__CHAIN_PATH__/$CHAIN_PATH}

    #
    #   Declare the target destinations for each file and symlink
    #
    HTTP_FILE="$SITES_AVAILABLE_DIR/${SERVER_NAME}.conf"
    HTTPS_FILE="$SITES_AVAILABLE_DIR/${SERVER_NAME}-ssl.conf"
    HTTP_SYMLINK="$SITES_ENABLED_DIR/${SERVER_NAME}.conf"
    HTTPS_SYMLINK="$SITES_ENABLED_DIR/${SERVER_NAME}-ssl.conf"

    #
    #   Create both the HTTP and HTTPS site definitions
    #
    echo "$HTTP_CONFIG" > "$HTTP_FILE"
    echo "Created '$HTTP_FILE'"

    echo "$HTTPS_CONFIG" > "$HTTPS_FILE"
    echo "Created '$HTTPS_FILE'"

    #
    #   Create the symbolic links to "enable" the sites in Apache
    #
    ln -s "$HTTP_FILE" "$HTTP_SYMLINK"
    echo "Linked '$HTTP_FILE' to '$HTTP_SYMLINK'"

    ln -s "$HTTPS_FILE" "$HTTPS_SYMLINK"
    echo "Linked '$HTTPS_FILE' to '$HTTPS_SYMLINK'"

    #
    #   Create the document root for the current site being processed
    #
    if [[ ! -e $DOCUMENT_ROOT ]];
    then
        mkdir $DOCUMENT_ROOT
        echo "Created directory '$DOCUMENT_ROOT'"
    elif [[ ! -d $DOCUMENT_ROOT ]];
    then
        echo "Directory '$DOCUMENT_ROOT' already exists"
    fi

done < "sites.list"
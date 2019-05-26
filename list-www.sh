#!/bin/bash

#
#   Read each site definition and print them sequentially
#   Note: The output of this script is used to supply update-www-ssl.sh
#
TEMP=""

while read LINE;
do
    HTTP_CONFIG="$(<template.conf)"
    HTTPS_CONFIG="$(<template-ssl.conf)"
    
    IFS=" "
    set - $LINE
    SRV_NAME=$1
    DOC_ROOT=$2

    TEMP="$TEMP$SRV_NAME "
done < "sites.list"

echo "$TEMP"
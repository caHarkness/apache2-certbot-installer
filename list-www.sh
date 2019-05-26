#!/bin/bash

#
#   Read each site definition and print them sequentially
#   Note: The output of this script is used to supply update-www-ssl.sh
#
TEMP=""

while read LINE;
do
    IFS=" "
    set - $LINE
    SERVER_NAME=$1
    DOCUMENT_ROOT=$2

    TEMP="$TEMP$SERVER_NAME "
done < "sites.list"

echo "$TEMP"
#!/bin/bash

message=$(ruby ${ROOTDIR}/find.rb)

if [ -z ${message+x} ]; then
  exit 0
fi

echo -e "${message}" | curl -s --url 'smtps://smtp.gmail.com:465' --ssl-reqd \
  --mail-from ${MAILFROM} \
  --mail-rcpt ${MAILTO} \
  --user ${MAILFROM}:${MAILPASSWD} \
  -T -

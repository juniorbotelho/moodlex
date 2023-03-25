#!/bin/sh

# List of extensions to validate
extensions="
  session
  xmlreader
  fileinfo
  sodium
  exif
  iconv
  mbstring
  curl
  openssl
  tokenizer
  xmlrpc
  soap
  ctype
  zip
  gd
  simplexml
  dom
  xml
  intl
  json
  pgsql
  mysqli
  pdo_pgsql
  pdo_mysql
  ldap
  sockets
"

# Loop through the extensions and validate if they are enabled
for ext in $extensions; do
  if ! php7 -m | grep -i -q "^$ext$"; then
    echo "[Error]: Extension $ext is not enabled"
    exit 1
  fi
done

echo "[OK] Extensions are enabled"
exit 0

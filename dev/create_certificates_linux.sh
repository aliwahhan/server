#!/usr/bin/env bash
# Script for generating and installing the Deepsafer development certificates on Linux.

IDENTITY_SERVER_KEY=identity_server_dev.key
IDENTITY_SERVER_CERT=identity_server_dev.crt
IDENTITY_SERVER_CN="Deepsafer Identity Server Dev"
CONFIG_FILE=identity_server_dev.cnf

cat > $CONFIG_FILE <<EOL
[req]
default_bits       = 4096
prompt             = no
default_md         = sha256
req_extensions     = req_ext
x509_extensions    = v3_req
distinguished_name = dn

[dn]
CN = $IDENTITY_SERVER_CN

[req_ext]
subjectAltName = @alt_names

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
IP.1 = 127.0.0.1
IP.2 = 192.168.168.40
EOL

openssl req -x509 -newkey rsa:4096 -sha256 -nodes -days 3650 \
    -keyout $IDENTITY_SERVER_KEY \
    -out $IDENTITY_SERVER_CERT \
    -config $CONFIG_FILE

# 
if [ -x "$(command -v update-ca-certificates)" ]; then
  sudo cp $IDENTITY_SERVER_CERT /usr/local/share/ca-certificates/
  sudo update-ca-certificates
elif [ -x "$(command -v update-ca-trust)" ]; then
  sudo cp $IDENTITY_SERVER_CERT /etc/pki/ca-trust/source/anchors/
  sudo update-ca-trust
else
  echo 'Error: Update manager for CA certificates not found!'
  exit 1
fi

openssl x509 -in $IDENTITY_SERVER_CERT -noout -fingerprint -sha1
echo "Certificate created and trusted successfully!"
echo "   - Key:  $IDENTITY_SERVER_KEY"
echo "   - Cert: $IDENTITY_SERVER_CERT"

# 
rm -f $CONFIG_FILE

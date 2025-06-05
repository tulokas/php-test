#!/bin/bash
set -e

echo "🔐 Generating self-signed MySQL SSL certs..."

mkdir -p mysql/certs client-cert

# Generate CA
openssl req -new -x509 -days 365 -nodes -out mysql/certs/ca.pem -keyout mysql/certs/ca-key.pem -subj "/CN=Test CA"

# Generate MySQL server key and cert
openssl req -newkey rsa:2048 -days 365 -nodes -keyout mysql/certs/server-key.pem -out mysql/certs/server-req.pem -subj "/CN=mysql"
openssl x509 -req -in mysql/certs/server-req.pem -CA mysql/certs/ca.pem -CAkey mysql/certs/ca-key.pem -set_serial 01 -out mysql/certs/server-cert.pem -days 365

# Generate PHP client key and cert
cp mysql/certs/ca.pem client-cert/

openssl req -newkey rsa:2048 -days 365 -nodes -keyout client-cert/client-key.pem -out client-cert/client-req.pem -subj "/CN=Client"
openssl x509 -req -in client-cert/client-req.pem -CA client-cert/ca.pem -CAkey mysql/certs/ca-key.pem -set_serial 02 -out client-cert/client-cert.pem -days 365

echo "✅ Certs generated in ./mysql/certs and ./client-cert"
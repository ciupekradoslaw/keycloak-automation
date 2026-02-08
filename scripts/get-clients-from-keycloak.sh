#!/bin/bash

REALM="demo"
TOKEN=$(./get-keycloak-token.sh)

CLIENTS_IN_KEYCLOAK=$(curl -s \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:8080/admin/realms/$REALM/clients \
  | yq -r '.[].clientId')

echo "Existing clients in Keycloak:"
echo "$CLIENTS_IN_KEYCLOAK"
echo "-----------------------"
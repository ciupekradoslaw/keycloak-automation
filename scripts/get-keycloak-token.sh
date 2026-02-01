#!/bin/bash

KEYCLOAK_URL="http://localhost:8080"
REALM="master"
USERNAME="admin"
PASSWORD="password"
CLIENT_ID="admin-cli"

TOKEN=$(curl -s \
  -d "client_id=$CLIENT_ID" \
  -d "username=$USERNAME" \
  -d "password=$PASSWORD" \
  -d "grant_type=password" \
  "$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/token" \
  | yq -r '.access_token')

echo $TOKEN
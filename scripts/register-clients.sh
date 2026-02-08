#!/bin/bash

REALM="demo"
KC_URL="http://localhost:8080"
TOKEN=$(./get-keycloak-token.sh)

save_to_env() {
  ENV_FILE="$(cd "$(dirname "$0")/.." && pwd)/.env"
  local KEY=$1
  local VALUE=$2

  if grep -q "^$KEY=" "$ENV_FILE" 2>/dev/null; then
    # update existing key
    sed -i.bak "s|^$KEY=.*|$KEY=$VALUE|" "$ENV_FILE"
  else
    # append new key
    echo "$KEY=$VALUE" >> "$ENV_FILE"
  fi
}

YAML_FILE="$(cd "$(dirname "$0")/.." && pwd)/charts/services.yaml"

echo "Reading services from $YAML_FILE"
SERVICES=$(yq -r '.services[].name' "$YAML_FILE")

EXISTING_CLIENTS=$(./get-clients-from-keycloak.sh)

for SERVICE in $SERVICES; do
  if echo "$EXISTING_CLIENTS" | grep -qx "$SERVICE"; then
    echo "Client '$SERVICE' already exists in Keycloak ✅"
    continue
  fi

  echo "Creating client '$SERVICE'"

  curl -s -X POST "$KC_URL/admin/realms/$REALM/clients" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"clientId\": \"$SERVICE\",
      \"enabled\": true,
      \"protocol\": \"openid-connect\",
      \"publicClient\": false,
      \"serviceAccountsEnabled\": true
    }"

  CLIENT_UUID=$(curl -s \
    -H "Authorization: Bearer $TOKEN" \
    "$KC_URL/admin/realms/$REALM/clients?clientId=$SERVICE" \
    | yq -r '.[0].id')

  SECRET=$(curl -s \
    -H "Authorization: Bearer $TOKEN" \
    "$KC_URL/admin/realms/$REALM/clients/$CLIENT_UUID/client-secret" \
    | yq -r '.value')

  ENV_KEY_ID=$(echo "$SERVICE" | tr 'a-z-' 'A-Z_')_CLIENT_ID
  ENV_KEY_SECRET=$(echo "$SERVICE" | tr 'a-z-' 'A-Z_')_CLIENT_SECRET

  save_to_env "$ENV_KEY_ID" "$SERVICE"
  save_to_env "$ENV_KEY_SECRET" "$SECRET"
done
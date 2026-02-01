#!/bin/bash

YAML_FILE="$(cd "$(dirname "$0")/.." && pwd)/charts/services.yaml"
echo "Clients from YAML:"
yq -r '.services[].keycloak.clientId' "$YAML_FILE"
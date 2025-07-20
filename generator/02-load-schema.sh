#!/bin/bash
# shellcheck disable=SC2034,SC2154

custom_fields='[]'
schema_content='{}'
SCHEMA_JSON="./generator/entity-scheme.json" # Default

# Parseo de flags
while [[ $# -gt 0 ]]; do
  case $1 in
  -y)
    AUTO_CONFIRM=true
    shift
    ;;
  --json)
    USE_JSON=true
    shift
    ;;
  --scheme-dir)
    read -r -p "📄 Ingrese el path completo al archivo JSON del esquema (ej. ./generator/entity-schemes/user-scheme.json): " SCHEMA_JSON
    shift
    ;;
  *)
    shift
    ;;
  esac
done

if [[ "$USE_JSON" == true ]]; then
  command -v jq >/dev/null 2>&1 || {
    echo >&2 "❌ Error: jq no está instalado."
    exit 1
  }

  if [[ ! -f "$SCHEMA_JSON" ]]; then
    echo "❌ No se encontró el archivo de esquema en: $SCHEMA_JSON"
    exit 1
  fi

  entity=$(jq -r '.name' "$SCHEMA_JSON")
  custom_fields=$(jq -c '.fields' "$SCHEMA_JSON")
  schema_content=$(cat "$SCHEMA_JSON")
else
  read -r -p "📝 Nombre de la entidad (ej. user, product): " entity
fi

EntityPascal="$(tr '[:lower:]' '[:upper:]' <<<"${entity:0:1}")${entity:1}"

#!/bin/bash
custom_fields='[]'
schema_content='{}'

if $USE_JSON; then
  command -v jq >/dev/null 2>&1 || {
    echo >&2 "❌ Error: jq no está instalado."
    exit 1
  }

  SCHEMA_JSON="./entity-schema.json"
  if [[ ! -f "$SCHEMA_JSON" ]]; then
    echo "❌ No se encontró entity-schema.json en el directorio actual."
    exit 1
  fi

  entity=$(jq -r '.name' "$SCHEMA_JSON")
  custom_fields=$(jq -c '.fields' "$SCHEMA_JSON")
  schema_content=$(cat "$SCHEMA_JSON")
else
  read -r -p "Nombre de la entidad (ej. user, product): " entity
fi

EntityPascal="$(tr '[:lower:]' '[:upper:]' <<<"${entity:0:1}")${entity:1}"

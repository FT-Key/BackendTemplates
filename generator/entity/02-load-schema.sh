#!/bin/bash
# shellcheck disable=SC2034,SC2154

custom_fields='[]'
schema_content='{}'

SCHEMA_JSON="./generator/entity/entity-schema.json"
SCHEMA_DIR="./generator/entity/entity-schemas"

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
  --schema-dir)
    echo "📁 Ingrese path al directorio de esquemas JSON"
    echo "   (presione Enter para usar el default: $SCHEMA_DIR y listar archivos disponibles):"
    read -r input_dir
    if [[ -n "$input_dir" ]]; then
      SCHEMA_DIR="$input_dir"
    fi

    if [[ ! -d "$SCHEMA_DIR" ]]; then
      echo "❌ Directorio no existe: $SCHEMA_DIR"
      exit 1
    fi

    mapfile -t json_files < <(find "$SCHEMA_DIR" -maxdepth 1 -type f -name '*.json' | sort)
    if [[ ${#json_files[@]} -eq 0 ]]; then
      echo "❌ No se encontraron archivos JSON en $SCHEMA_DIR"
      exit 1
    fi

    echo "Seleccione el archivo JSON para usar:"
    for i in "${!json_files[@]}"; do
      fname=$(basename "${json_files[i]}")
      echo "  $((i + 1))) $fname"
    done

    read -r -p "Ingrese número (1-${#json_files[@]}): " selected_num

    if ! [[ "$selected_num" =~ ^[0-9]+$ ]] || ((selected_num < 1 || selected_num > ${#json_files[@]})); then
      echo "❌ Selección inválida"
      exit 1
    fi

    SCHEMA_JSON="${json_files[selected_num - 1]}"
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
else
  read -r -p "📝 Nombre de la entidad (ej. user, product): " entity
fi

# ---------------------
# ✅ VALIDACIÓN DEL NOMBRE
# ---------------------

# Trim inicio y fin
entity=$(echo "$entity" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
# Eliminar espacios internos
entity=$(echo "$entity" | tr -d '[:space:]')
# Eliminar caracteres no alfanuméricos
entity=$(echo "$entity" | tr -cd '[:alnum:]')
# Convertir a minúscula
entity="${entity,,}"

if [[ -z "$entity" ]]; then
  echo "❌ Error: El nombre de la entidad no puede estar vacío o inválido."
  exit 1
fi

# PascalCase para nombre de clase
EntityPascal="$(tr '[:lower:]' '[:upper:]' <<<"${entity:0:1}")${entity:1}"

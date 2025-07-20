#!/bin/bash
# shellcheck disable=SC2154
# 1. DOMAIN
ENTITY_PASCAL="$(tr '[:lower:]' '[:upper:]' <<<"${entity:0:1}")${entity:1}"
DOMAIN_PATH="src/domain/$entity"
mkdir -p "$DOMAIN_PATH"
domain_file="$DOMAIN_PATH/$ENTITY_PASCAL.js"

# Método más robusto para construir los arrays
declare -a names
declare -a defaults
declare -a requireds

# Obtener la cantidad de campos
field_count=$(echo "$fields" | jq '. | length')

# Llenar arrays campo por campo
for ((i = 0; i < field_count; i++)); do
  names[i]=$(echo "$fields" | jq -r ".[$i].name")
  defaults[i]=$(echo "$fields" | jq -r ".[$i].default // empty")
  requireds[i]=$(echo "$fields" | jq -r ".[$i].required // false")
done

# Procesar métodos si existen - CORREGIDO
declare -a method_lines
if echo "$schema_content" | jq -e '.methods' >/dev/null 2>&1; then
  method_count=$(echo "$schema_content" | jq '.methods | length')

  for ((i = 0; i < method_count; i++)); do
    method_name=$(echo "$schema_content" | jq -r ".methods[$i].name")
    method_params=$(echo "$schema_content" | jq -r ".methods[$i].params | join(\", \")")
    method_body=$(echo "$schema_content" | jq -r ".methods[$i].body")

    # Construir el método
    method_lines+=("") # línea vacía antes del método
    method_lines+=("  $method_name($method_params) {")
    method_lines+=("    $method_body")
    method_lines+=("  }")
  done
fi

constructor_params=""
declare -a constructor_body_lines
declare -a getter_lines
declare -a setter_lines
declare -a tojson_lines

for i in "${!names[@]}"; do
  name="${names[i]}"
  default="${defaults[i]}"
  required="${requireds[i]}"

  # Saltar si el nombre está vacío
  [[ -z "$name" || "$name" == "null" ]] && continue

  constructor_params+="$name, "

  if [[ "$required" == "true" && (-z "$default" || "$default" == "empty") ]]; then
    constructor_body_lines+=("    if ($name === undefined) throw new Error('$name is required');")
  fi

  if [[ -n "$default" && "$default" != "empty" ]]; then
    constructor_body_lines+=("    this._$name = $name !== undefined ? $name : $default;")
  else
    constructor_body_lines+=("    this._$name = $name;")
  fi

  getter_lines+=("  get $name() { return this._$name; }")
  setter_lines+=("  set $name(value) { this._$name = value; this._touchUpdatedAt(); }")
  tojson_lines+=("      $name: this._$name,")
done

# Limpiar params y última coma del toJSON
constructor_params="${constructor_params%, }"
if [[ ${#tojson_lines[@]} -gt 0 ]]; then
  tojson_lines[-1]="${tojson_lines[-1]%,}"
fi

# Escritura del archivo
{
  echo "export class $ENTITY_PASCAL {"
  echo "  /**"
  echo "   * @param {Object} params"
  echo "   */"
  echo "  constructor({ $constructor_params }) {"
  printf "%s\n" "${constructor_body_lines[@]}"
  echo "  }"
  echo ""
  printf "%s\n" "${getter_lines[@]}"
  printf "%s\n" "${setter_lines[@]}"
  echo ""
  echo "  _touchUpdatedAt() {"
  echo "    this._updatedAt = new Date();"
  echo "  }"

  # Agregar métodos personalizados si existen
  if [[ ${#method_lines[@]} -gt 0 ]]; then
    printf "%s\n" "${method_lines[@]}"
  fi

  echo ""
  echo "  toJSON() {"
  echo "    return {"
  printf "%s\n" "${tojson_lines[@]}"
  echo "    };"
  echo "  }"
  echo "}"
} >"$domain_file"

echo "✅ Clase generada: $domain_file"

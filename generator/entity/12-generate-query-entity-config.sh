#!/bin/bash
# 13-generate-query-entity-config.sh

json_file="$1"

if [ -z "$json_file" ]; then
  echo "Uso: $0 ruta/al/archivo-entity.json"
  exit 1
fi

if ! [ -f "$json_file" ]; then
  echo "❌ El archivo JSON no existe: $json_file"
  exit 1
fi

# Usar variable si está definida, sino extraer
entity="${entity:-$(jq -r '.name' "$json_file")}"
if [ "$entity" == "null" ] || [ -z "$entity" ]; then
  echo "❌ No se encontró el campo 'name' en el JSON."
  exit 1
fi

entity_lc="${entity,,}"  # minúscula

generic_fields=(id createdAt updatedAt deletedAt active ownedBy)

fields=$(jq -r '.fields[] | select(.sensible != true) | .name' "$json_file")

declare -A all_fields_map
for f in "${generic_fields[@]}"; do
  all_fields_map["$f"]=1
done

while IFS= read -r field; do
  all_fields_map["$field"]=1
done <<< "$fields"

all_fields=()
for k in "${!all_fields_map[@]}"; do
  all_fields+=("$k")
done

mapfile -t sorted_fields < <(printf '%s\n' "${all_fields[@]}" | sort)

array_to_js_list() {
  local arr=("$@")
  local res=""
  for e in "${arr[@]}"; do
    res+="\"$e\", "
  done
  echo "${res%, }"
}

searchable_js=$(array_to_js_list "${sorted_fields[@]}")
sortable_js=$(array_to_js_list "${sorted_fields[@]}")
filterable_js=$(array_to_js_list "${sorted_fields[@]}")

output_file="src/interfaces/http/middlewares/query-${entity_lc}-config.js"

cat >"$output_file" <<EOF
// Configuración de query para la entidad $entity

export const ${entity_lc}QueryConfig = {
  searchableFields: [${searchable_js}],  // campos para búsqueda por texto (q)
  sortableFields: [${sortable_js}], // campos permitidos para ordenar
  filterableFields: [${filterable_js}],  // campos permitidos para filtro exacto
};
EOF

echo "✅ Archivo generado: $output_file"

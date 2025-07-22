#!/bin/bash
# shellcheck disable=SC2154
# 1.5 VALIDATE
validate_file="src/domain/$entity/validate-$entity.js"

# Preguntar si sobrescribir si el archivo existe
if [[ -f "$validate_file" && "$AUTO_CONFIRM" != true ]]; then
  read -r -p "⚠️  El archivo $validate_file ya existe. ¿Desea sobrescribirlo? [y/n]: " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "⏭️  Se omitió la generación de $validate_file"
    exit 0
  fi
fi

# Generar validación
field_count=$(echo "$fields" | jq '. | length')

declare -a val_names
declare -a val_requireds

for ((i = 0; i < field_count; i++)); do
  val_names[i]=$(echo "$fields" | jq -r ".[$i].name")
  val_requireds[i]=$(echo "$fields" | jq -r ".[$i].required // false")
done

validation_lines=""
for i in "${!val_names[@]}"; do
  name="${val_names[i]}"
  required="${val_requireds[i]}"

  [[ -z "$name" || "$name" == "null" ]] && continue

  if [[ "$required" == "true" ]]; then
    validation_lines+="  if (!data.$name) throw new Error('$name is required');"$'\n'
  fi
done

cat <<EOF >"$validate_file"
export function validate${EntityPascal}(data) {
$validation_lines  return true;
}
EOF

echo "✅ Validación generada: $validate_file"

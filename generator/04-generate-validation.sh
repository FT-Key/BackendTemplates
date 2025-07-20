#!/bin/bash
# shellcheck disable=SC2154
# 1.5 VALIDATE
validate_file="src/domain/$entity/validate-$entity.js"
if confirm_action "¿Generar validate ($validate_file)?"; then
  # Usar el mismo método que ya funciona en el constructor
  field_count=$(echo "$fields" | jq '. | length')

  declare -a val_names
  declare -a val_requireds

  # Llenar arrays campo por campo (mismo método que funciona arriba)
  for ((i = 0; i < field_count; i++)); do
    val_names[i]=$(echo "$fields" | jq -r ".[$i].name")
    val_requireds[i]=$(echo "$fields" | jq -r ".[$i].required // false")
  done

  validation_lines=""

  for i in "${!val_names[@]}"; do
    name="${val_names[i]}"
    required="${val_requireds[i]}"

    # Saltar si el nombre está vacío
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
fi

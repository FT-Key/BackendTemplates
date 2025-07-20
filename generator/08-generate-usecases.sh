#!/bin/bash
# shellcheck disable=SC2154
# Función para generar casos de uso
generate_use_case() {
  action=$1
  file_path="src/application/$entity/use-cases/${action}-${entity}.js"
  mkdir -p "$(dirname "$file_path")"

  {
    echo "import { $EntityPascal } from '../../../domain/$entity/$entity.js';"
    echo ""
    echo "export async function ${action}${EntityPascal}(repository, $([[ $action == "create" ]] && echo "data" || echo "id, data")) {"
    echo "  // Lógica base"
  } >"$file_path"

  if [ "$action" == "create" ]; then
    echo "  const item = new $EntityPascal({ id: Date.now().toString(), ...data });" >>"$file_path"
    echo "  return await repository.save(item);" >>"$file_path"
  elif [ "$action" == "get" ]; then
    echo "  return await repository.findById(id);" >>"$file_path"
  elif [ "$action" == "update" ]; then
    echo "  return await repository.update(id, data);" >>"$file_path"
  elif [ "$action" == "delete" ]; then
    echo "  return await repository.deleteById(id);" >>"$file_path"
  elif [ "$action" == "deactivate" ]; then
    echo "  return await repository.deactivateById(id);" >>"$file_path"
  fi

  echo "}" >>"$file_path"
}
# 3. USE CASES
for action in create get update delete deactivate; do
  usecase_file="src/application/$entity/use-cases/${action}-${entity}.js"
  if confirm_action "¿Generar caso de uso $action ($usecase_file)?"; then
    generate_use_case "$action"
  fi
done

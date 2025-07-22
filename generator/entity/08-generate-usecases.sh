#!/bin/bash
# shellcheck disable=SC2154

# Función para generar casos de uso
generate_use_case() {
  local action=$1
  local file_path="src/application/$entity/use-cases/${action}-${entity}.js"
  mkdir -p "$(dirname "$file_path")"

  if [[ "$action" == "create" ]]; then
    {
      echo "import { ${EntityPascal}Factory } from '../../../domain/$entity/${entity}-factory.js';"
      echo "import crypto from 'crypto';"
      echo ""
      echo "export class Create${EntityPascal} {"
      echo "  constructor(repository) {"
      echo "    this.repository = repository;"
      echo "  }"
      echo ""
      echo "  async execute(data) {"
      if $has_json; then
        echo "    const entity = ${EntityPascal}Factory.create({"
        echo "      ...data,"
        echo "      id: crypto.randomUUID(),"
        echo "    });"
        echo "    return this.repository.save(entity);"
      else
        echo "    // TODO: completar lógica con atributos personalizados"
        echo "    const entity = { id: crypto.randomUUID(), ...data };"
        echo "    return this.repository.save(entity);"
      fi
      echo "  }"
      echo "}"
    } >"$file_path"

  elif [[ "$action" == "update" ]]; then
    {
      echo "import { ${EntityPascal}Factory } from '../../../domain/$entity/${entity}-factory.js';"
      echo ""
      echo "export class Update${EntityPascal} {"
      echo "  constructor(repository) {"
      echo "    this.repository = repository;"
      echo "  }"
      echo ""
      echo "  async execute(id, data) {"
      echo "    if (!id) throw new Error('${EntityPascal} id is required');"
      echo ""
      echo "    const existing = await this.repository.findById(id);"
      echo "    if (!existing) throw new Error('${EntityPascal} not found');"
      echo ""
      if $has_json; then
        echo "    const updated = ${EntityPascal}Factory.create({"
        echo "      ...existing,"
        echo "      ...data,"
        echo "      id: existing.id,"
        echo "    });"
        echo "    return this.repository.save(updated);"
      else
        echo "    // TODO: completar lógica con atributos personalizados"
        echo "    const updated = { ...existing, ...data };"
        echo "    return this.repository.save(updated);"
      fi
      echo "  }"
      echo "}"
    } >"$file_path"

  elif [[ "$action" == "get" ]]; then
    {
      echo "export class Get${EntityPascal} {"
      echo "  /**"
      echo "   * @param {Object} repository  Debe tener método findById(id)"
      echo "   */"
      echo "  constructor(repository) {"
      echo "    this.repository = repository;"
      echo "  }"
      echo ""
      echo "  /**"
      echo "   * @param {string} id"
      echo "   * @returns {Promise<${EntityPascal}|null>}"
      echo "   */"
      echo "  async execute(id) {"
      echo "    if (!id) throw new Error('${EntityPascal} id is required');"
      echo "    return this.repository.findById(id);"
      echo "  }"
      echo "}"
    } >"$file_path"

  elif [[ "$action" == "delete" ]]; then
    {
      echo "export class Delete${EntityPascal} {"
      echo "  /**"
      echo "   * @param {Object} repository Debe tener método deleteById(id)"
      echo "   */"
      echo "  constructor(repository) {"
      echo "    this.repository = repository;"
      echo "  }"
      echo ""
      echo "  /**"
      echo "   * @param {string} id"
      echo "   * @returns {Promise<boolean>} true si ${entity} se eliminó, false si no existe"
      echo "   */"
      echo "  async execute(id) {"
      echo "    if (!id) throw new Error('${EntityPascal} id is required');"
      echo "    return this.repository.deleteById(id);"
      echo "  }"
      echo "}"
    } >"$file_path"

  elif [[ "$action" == "deactivate" ]]; then
    {
      echo "export class Deactivate${EntityPascal} {"
      echo "  /**"
      echo "   * @param {Object} repository Debe tener métodos findById(id) y save(${entity})"
      echo "   */"
      echo "  constructor(repository) {"
      echo "    this.repository = repository;"
      echo "  }"
      echo ""
      echo "  /**"
      echo "   * @param {string} id"
      echo "   * @returns {Promise<${EntityPascal}|null>} Devuelve el ${entity} desactivado o null si no existe"
      echo "   */"
      echo "  async execute(id) {"
      echo "    if (!id) throw new Error('${EntityPascal} id is required');"
      echo "    const result = await this.repository.deactivateById(id);"
      echo "    return result;"
      echo "  }"
      echo "}"
    } >"$file_path"

  fi
}

# 3. USE CASES
for action in create get update delete deactivate; do
  usecase_file="src/application/$entity/use-cases/${action}-${entity}.js"
  if confirm_action "¿Generar caso de uso $action ($usecase_file)?"; then
    generate_use_case "$action"
  fi
done

echo "✅ Casos de uso generados."

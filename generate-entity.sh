#!/bin/bash
set -e

AUTO_CONFIRM=false
USE_JSON=false

for arg in "$@"; do
  case $arg in
  -y)
    AUTO_CONFIRM=true
    ;;
  --json)
    USE_JSON=true
    ;;
  esac
done

confirm_action() {
  local prompt="$1"
  local result
  if $AUTO_CONFIRM; then
    result="y"
  else
    read -r -p "$prompt [y/n] " result
  fi
  [[ "$result" == "y" ]]
}

# ----------------------------------------------
# Obtener entidad desde JSON o por input
custom_fields='[]'

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
  # AGREGAMOS ESTA LÍNEA PARA LEER TODO EL ESQUEMA
  schema_content=$(cat "$SCHEMA_JSON")
else
  read -r -p "Nombre de la entidad (ej. user, product): " entity
  schema_content='{}'
fi

EntityPascal="$(tr '[:lower:]' '[:upper:]' <<<"${entity:0:1}")${entity:1}"
echo "🛠 Generando entidad '$entity'..."

# Campos genéricos
base_fields='[
  { "name": "id", "required": true },
  { "name": "active", "default": true },
  { "name": "createdAt", "default": "new Date()" },
  { "name": "updatedAt", "default": "new Date()" },
  { "name": "deletedAt", "default": null },
  { "name": "ownedBy", "default": null }
]'

# Crear archivos temporales para evitar problemas con <(...)
tmp_base=$(mktemp)
tmp_custom=$(mktemp)

echo "$base_fields" >"$tmp_base"
echo "$custom_fields" >"$tmp_custom"

fields=$(jq -s '.[0] + .[1]' "$tmp_base" "$tmp_custom")

rm "$tmp_base" "$tmp_custom"

# ----------------------------------------------
# Crear carpetas base
mkdir -p "src/domain/$entity"
mkdir -p "src/application/$entity/use-cases"
mkdir -p "src/infrastructure/$entity"
mkdir -p "src/interfaces/http/$entity"
mkdir -p "tests/application/$entity"

# ----------------------------------------------
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

# ----------------------------------------------
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

# 1.6 FACTORY (src/domain/$entity/$entity-factory.js)
factory_file="src/domain/$entity/${entity}-factory.js"
if confirm_action "¿Generar método fábrica ($factory_file)?"; then
  cat <<EOF >"$factory_file"
import { $EntityPascal } from './$entity.js';
import { validate${EntityPascal} } from './validate-$entity.js';

export class ${EntityPascal}Factory {
  /**
   * Crea una instancia de $EntityPascal validando los datos.
   * @param {Object} data
   * @returns {$EntityPascal}
   */
  static create(data) {
    validate${EntityPascal}(data);
    return new $EntityPascal(data);
  }
}
EOF
fi

# 1.7 CONSTANTS (src/domain/$entity/constants.js)
constants_file="src/domain/$entity/constants.js"
if confirm_action "¿Generar archivo constantes ($constants_file)?"; then
  cat <<EOF >"$constants_file"
// Constantes relacionadas con $EntityPascal

export const DEFAULT_ACTIVE = true;
EOF
fi

# 2. INFRASTRUCTURE
infra_file="src/infrastructure/$entity/in-memory-${entity}-repository.js"
if confirm_action "¿Inicializar repositorio InMemory ($infra_file)?"; then
  cat <<EOF >"$infra_file"
import { $EntityPascal } from '../../domain/$entity/$entity.js';

export class InMemory${EntityPascal}Repository {
  constructor() {
    /** @type {${EntityPascal}[]} */
    this.items = [];
  }

  async save(item) {
    const index = this.items.findIndex(i => i.id === item.id);
    if (index === -1) {
      this.items.push(item);
    } else {
      // Actualizar manteniendo instancia de dominio
      this.items[index] = item;
    }
    return item;
  }

  async findById(id) {
    return this.items.find(i => i.id === id) || null;
  }

  async findAll() {
    return this.items;
  }

  async update(id, data) {
    const item = await this.findById(id);
    if (!item) return null;
    // Usar método update del dominio para respetar lógica y setters
    item.update(data);
    await this.save(item);
    return item;
  }

  async deleteById(id) {
    const length = this.items.length;
    this.items = this.items.filter(i => i.id !== id);
    return this.items.length < length;
  }

  async deactivateById(id) {
    const item = await this.findById(id);
    if (!item) return null;
    item.deactivate(); // usar método de dominio
    await this.save(item);
    return item;
  }
}
EOF
fi

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

# 3.5. SERVICES
services_path="src/application/$entity/services"
if confirm_action "¿Crear carpeta de servicios ($services_path)?"; then
  mkdir -p "$services_path"
  echo "// Servicios para la entidad $EntityPascal" >"$services_path/README.md"
fi
service_file="src/application/$entity/services/get-active-${entity}.js"
if confirm_action "¿Agregar servicio getActive? ($service_file)"; then
  cat <<EOF >"$service_file"
export async function getActive${EntityPascal}s(repository) {
  const all = await repository.findAll();
  return all.filter(item => item.active);
}
EOF
fi

# 4. CONTROLLER
controller_file="src/interfaces/http/$entity/${entity}.controller.js"
if confirm_action "¿Generar controller ($controller_file)?"; then
  cat <<EOF >"$controller_file"
import { InMemory${EntityPascal}Repository } from '../../../infrastructure/$entity/in-memory-${entity}-repository.js';
import { create${EntityPascal} } from '../../../application/$entity/use-cases/create-${entity}.js';
import { get${EntityPascal} } from '../../../application/$entity/use-cases/get-${entity}.js';
import { update${EntityPascal} } from '../../../application/$entity/use-cases/update-${entity}.js';
import { delete${EntityPascal} } from '../../../application/$entity/use-cases/delete-${entity}.js';
import { deactivate${EntityPascal} } from '../../../application/$entity/use-cases/deactivate-${entity}.js';

const repository = new InMemory${EntityPascal}Repository();

export const create${EntityPascal}Controller = async (req, res) => {
  const item = await create${EntityPascal}(repository, req.body);
  res.status(201).json(item);
};

export const get${EntityPascal}Controller = async (req, res) => {
  const item = await get${EntityPascal}(repository, req.params.id);
  if (!item) return res.status(404).json({ error: '${EntityPascal} not found' });
  res.json(item);
};

export const update${EntityPascal}Controller = async (req, res) => {
  const item = await update${EntityPascal}(repository, req.params.id, req.body);
  res.json(item);
};

export const delete${EntityPascal}Controller = async (req, res) => {
  const success = await delete${EntityPascal}(repository, req.params.id);
  res.status(success ? 204 : 404).send();
};

export const deactivate${EntityPascal}Controller = async (req, res) => {
  const item = await deactivate${EntityPascal}(repository, req.params.id);
  res.json(item);
};
EOF
fi

# 5. ROUTES
routes_file="src/interfaces/http/$entity/${entity}.routes.js"
if confirm_action "¿Generar archivo de rutas ($routes_file)?"; then
  cat <<EOF >"$routes_file"
import express from 'express';
import {
  create${EntityPascal}Controller,
  get${EntityPascal}Controller,
  update${EntityPascal}Controller,
  delete${EntityPascal}Controller,
  deactivate${EntityPascal}Controller
} from './${entity}.controller.js';

const router = express.Router();

router.post('/', create${EntityPascal}Controller);
router.get('/:id', get${EntityPascal}Controller);
router.put('/:id', update${EntityPascal}Controller);
router.delete('/:id', delete${EntityPascal}Controller);
router.patch('/:id/deactivate', deactivate${EntityPascal}Controller);

export default router;
EOF
fi

# 6. TESTS
for action in create get update delete deactivate; do

  test_file="tests/application/$entity/${action}-${entity}.test.js"
  if confirm_action "¿Generar test base para $action? ($test_file)"; then
    cat <<EOF >"$test_file"
import { InMemory${EntityPascal}Repository } from '../../../src/infrastructure/$entity/in-memory-${entity}-repository.js';
import { ${action}${EntityPascal} } from '../../../src/application/$entity/use-cases/${action}-${entity}.js';

describe('${action^} ${EntityPascal}', () => {
  it('debería ejecutar correctamente', async () => {
    const repo = new InMemory${EntityPascal}Repository();
    // TODO: Agregar prueba real
  });
});
EOF
  fi
done

echo "✔️  Estructura generada para '$entity'"

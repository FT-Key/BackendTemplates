#!/bin/bash

# ----------------------------------------------
# Modo automático con -y
AUTO_CONFIRM=false
if [[ "$1" == "-y" ]]; then
  AUTO_CONFIRM=true
fi

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
# Pedir nombre de entidad
read -r -p "Nombre de la entidad (ej. user, product): " entity
EntityPascal="$(tr '[:lower:]' '[:upper:]' <<<"${entity:0:1}")${entity:1}"

echo "Generando estructura para entidad '$entity'..."

# Carpetas base
mkdir -p "src/domain/$entity"
mkdir -p "src/application/$entity/use-cases"
mkdir -p "src/infrastructure/$entity"
mkdir -p "src/interfaces/http/$entity"
mkdir -p "tests/application/$entity"

# 1. DOMAIN
domain_file="src/domain/$entity/$entity.js"
if confirm_action "¿Inicializar clase Domain ($domain_file)?"; then
  cat <<EOF >"$domain_file"
export class $EntityPascal {
  /**
   * @param {Object} params
   * @param {string} params.id
   * @param {boolean} [params.active]
   * @param {Date} [params.createdAt]
   * @param {Date} [params.updatedAt]
   * @param {Date|null} [params.deletedAt]
   * @param {string|null} [params.ownedBy]
   */
  constructor({ id, active = true, createdAt = new Date(), updatedAt = new Date(), deletedAt = null, ownedBy = null }) {
    if (!id) throw new Error('$EntityPascal id is required');

    this._id = id;
    this._active = active;
    this._createdAt = createdAt;
    this._updatedAt = updatedAt;
    this._deletedAt = deletedAt;
    this._ownedBy = ownedBy;
  }

  // Getters
  get id() {
    return this._id;
  }

  get active() {
    return this._active;
  }

  get createdAt() {
    return this._createdAt;
  }

  get updatedAt() {
    return this._updatedAt;
  }

  get deletedAt() {
    return this._deletedAt;
  }
  set deletedAt(value) {
    this._deletedAt = value;
    this._touchUpdatedAt();
  }

  get ownedBy() {
    return this._ownedBy;
  }
  set ownedBy(value) {
    this._ownedBy = value;
    this._touchUpdatedAt();
  }

  // Métodos para activar / desactivar
  activate() {
    this._active = true;
    this._touchUpdatedAt();
  }

  deactivate() {
    this._active = false;
    this._touchUpdatedAt();
  }

  // Método para actualizar propiedades de forma controlada
  update(data) {
    if (data.deletedAt !== undefined) this.deletedAt = data.deletedAt;
    if (data.ownedBy !== undefined) this.ownedBy = data.ownedBy;
    if (data.active !== undefined) {
      this._active = data.active;
    }
    this._touchUpdatedAt();
  }

  // Actualizar updatedAt al modificar algo
  _touchUpdatedAt() {
    this._updatedAt = new Date();
  }

  // Exportar a JSON
  toJSON() {
    return {
      id: this._id,
      active: this._active,
      createdAt: this._createdAt,
      updatedAt: this._updatedAt,
      deletedAt: this._deletedAt,
      ownedBy: this._ownedBy,
    };
  }
}
EOF
fi

# 1.5 VALIDATE (src/domain/$entity/validate-$entity.js)
validate_file="src/domain/$entity/validate-$entity.js"
if confirm_action "¿Generar función validate ($validate_file)?"; then
  cat <<EOF >"$validate_file"
export function validate${EntityPascal}(data) {
  if (!data.id) throw new Error('ID is required');
  // Puedes agregar más validaciones si deseas (por ejemplo, formatos de fecha)
  return true;
}
EOF
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

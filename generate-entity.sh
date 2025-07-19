#!/bin/bash

# Pedir nombre de entidad en singular y en minúscula
read -p "Nombre de la entidad (ej. user, product): " entity
EntityPascal="$(tr '[:lower:]' '[:upper:]' <<< ${entity:0:1})${entity:1}"
EntityCamel="$(tr '-' '_' <<< $entity)"

echo "Generando estructura para entidad '$entity'..."

# Carpetas base
mkdir -p src/domain/$entity
mkdir -p src/application/$entity/use-cases
mkdir -p src/infrastructure/$entity
mkdir -p src/interfaces/http/$entity
mkdir -p tests/application/$entity

# 1. DOMAIN
domain_file="src/domain/$entity/$entity.js"
read -p "¿Inicializar clase Domain ($domain_file)? [y/n] " confirm
if [[ $confirm == "y" ]]; then
cat <<EOF > $domain_file
export class $EntityPascal {
  /**
   * @param {Object} params
   * @param {string} params.id
   * @param {string} params.name
   * @param {boolean} [params.active]
   */
  constructor({ id, name, active = true }) {
    this.id = id;
    this.name = name;
    this.active = active;
  }

  toJSON() {
    return {
      id: this.id,
      name: this.name,
      active: this.active
    };
  }
}
EOF
fi

# 2. INFRASTRUCTURE
infra_file="src/infrastructure/$entity/in-memory-${entity}-repository.js"
read -p "¿Inicializar repositorio InMemory ($infra_file)? [y/n] " confirm
if [[ $confirm == "y" ]]; then
cat <<EOF > $infra_file
import { $EntityPascal } from '../../domain/$entity/$entity.js';

export class InMemory${EntityPascal}Repository {
  constructor() {
    /** @type {${EntityPascal}[]} */
    this.items = [];
  }

  async save(item) {
    this.items.push(item);
    return item;
  }

  async findById(id) {
    return this.items.find(i => i.id === id) || null;
  }

  async findAll() {
    return this.items;
  }

  async update(id, data) {
    const index = this.items.findIndex(i => i.id === id);
    if (index === -1) return null;
    this.items[index] = { ...this.items[index], ...data };
    return this.items[index];
  }

  async deleteById(id) {
    const length = this.items.length;
    this.items = this.items.filter(i => i.id !== id);
    return this.items.length < length;
  }

  async deactivateById(id) {
    const item = await this.findById(id);
    if (item) {
      item.active = false;
      return item;
    }
    return null;
  }
}
EOF
fi

# Función que genera el archivo de use-case con contenido completo
generate_use_case() {
  action=$1
  file_path="src/application/$entity/use-cases/${action}-${entity}.js"
  mkdir -p "$(dirname "$file_path")"

  echo "import { $EntityPascal } from '../../../domain/$entity/$entity.js';" > "$file_path"
  echo "" >> "$file_path"
  echo "export async function ${action}${EntityPascal}(repository, $( [[ $action == "create" ]] && echo "data" || echo "id, data" )) {" >> "$file_path"
  echo "  // Lógica base" >> "$file_path"
  
  if [ "$action" == "create" ]; then
    echo "  const item = new $EntityPascal({ id: Date.now().toString(), ...data });" >> "$file_path"
    echo "  return await repository.save(item);" >> "$file_path"
  elif [ "$action" == "get" ]; then
    echo "  return await repository.findById(id);" >> "$file_path"
  elif [ "$action" == "update" ]; then
    echo "  return await repository.update(id, data);" >> "$file_path"
  elif [ "$action" == "delete" ]; then
    echo "  return await repository.deleteById(id);" >> "$file_path"
  elif [ "$action" == "deactivate" ]; then
    echo "  return await repository.deactivateById(id);" >> "$file_path"
  fi

  echo "}" >> "$file_path"
}

# 3. APPLICATION / USE-CASES
for action in create get update delete deactivate; do
  usecase_file="src/application/$entity/use-cases/${action}-${entity}.js"
  read -p "¿Generar caso de uso $action ($usecase_file)? [y/n] " confirm
  if [[ $confirm == "y" ]]; then
    generate_use_case "$action"
  fi
done

# 3.5. APPLICATION / SERVICES
services_path="src/application/$entity/services"
read -p "¿Crear carpeta de servicios ($services_path)? [y/n] " confirm
if [[ $confirm == "y" ]]; then
  mkdir -p "$services_path"
  echo "// Servicios para la entidad $EntityPascal" > "$services_path/README.md"
fi

# 4. CONTROLLER
controller_file="src/interfaces/http/$entity/${entity}.controller.js"
read -p "¿Generar controller ($controller_file)? [y/n] " confirm
if [[ $confirm == "y" ]]; then
cat <<EOF > $controller_file
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
read -p "¿Generar archivo de rutas ($routes_file)? [y/n] " confirm
if [[ $confirm == "y" ]]; then
cat <<EOF > $routes_file
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
  read -p "¿Generar test base para $action? ($test_file) [y/n] " confirm
  if [[ $confirm == "y" ]]; then
cat <<EOF > $test_file
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

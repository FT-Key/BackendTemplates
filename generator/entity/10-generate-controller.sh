#!/bin/bash
# shellcheck disable=SC2154
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

  echo "✅ Controlador generado: $controller_file"
fi

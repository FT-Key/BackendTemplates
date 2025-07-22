#!/bin/bash
# shellcheck disable=SC2154
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

  echo "✅ Rutas generadas: $routes_file"
fi

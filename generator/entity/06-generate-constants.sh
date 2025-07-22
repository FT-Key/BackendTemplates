#!/bin/bash
# shellcheck disable=SC2154
# 1.7 CONSTANTS (src/domain/$entity/constants.js) y MOCKS (src/domain/$entity/mocks.js)

constants_file="src/domain/$entity/constants.js"
mocks_file="src/domain/$entity/mocks.js"

if confirm_action "¿Generar archivo constantes ($constants_file)?"; then
  cat <<EOF >"$constants_file"
// Constantes relacionadas con $EntityPascal

export const DEFAULT_ACTIVE = true;
EOF

  echo "✅ Constantes generadas: $constants_file"
fi

if confirm_action "¿Generar archivo mocks ($mocks_file)?"; then
  cat <<EOF >"$mocks_file"
// Mocks y datos de prueba para $EntityPascal

export const mock${EntityPascal} = {
  id: 'mock-id-123',
  active: true,
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
  deletedAt: null,
  ownedBy: 'mock-owner',
  // Agregá acá más campos mock según la entidad
};
EOF

  echo "✅ Mocks generados: $mocks_file"
fi

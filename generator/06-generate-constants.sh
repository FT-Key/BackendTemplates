#!/bin/bash
# shellcheck disable=SC2154
# 1.7 CONSTANTS (src/domain/$entity/constants.js)
constants_file="src/domain/$entity/constants.js"
if confirm_action "¿Generar archivo constantes ($constants_file)?"; then
  cat <<EOF >"$constants_file"
// Constantes relacionadas con $EntityPascal

export const DEFAULT_ACTIVE = true;
EOF
fi

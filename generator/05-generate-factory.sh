#!/bin/bash
# shellcheck disable=SC2154
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

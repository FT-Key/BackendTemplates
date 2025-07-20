#!/bin/bash
# shellcheck disable=SC2154
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

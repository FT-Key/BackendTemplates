#!/bin/bash

# shellcheck disable=SC2154,SC2086

TEST_PATH="tests/application/$entity"
mkdir -p "$TEST_PATH"

# Función para generar datos dummy para los campos del schema
generate_dummy_value() {
  local field_name=$1
  echo "\"${field_name}_test\""
}

fields_js=$(jq -c '.fields' <<<"$schema_content")

# Construir input con campos dummy para usar en tests
input_entries=""
for row in $(echo "$fields_js" | jq -c '.[]'); do
  name=$(jq -r '.name' <<<"$row")
  dummy_value=$(generate_dummy_value "$name")
  input_entries+="    $name: $dummy_value,\n"
done
input_entries=$(echo -e "$input_entries" | sed '$s/,\n$//')

# ------------- GENERAR TESTS -------------------

# CREATE test (incluye factory test)
cat >"$TEST_PATH/create-$entity.test.js" <<EOF
import assert from 'assert';
import { $EntityPascal } from '../../../src/domain/$entity/${entity}.js';
import { InMemory${EntityPascal}Repository } from '../../../src/infrastructure/$entity/in-memory-${entity}-repository.js';
import { Create$EntityPascal } from '../../../src/application/$entity/use-cases/create-$entity.js';

async function test${EntityPascal}Factory() {
  const data = {
    id: '123',
    active: true,
    createdAt: new Date('2025-01-01T00:00:00Z'),
    updatedAt: new Date('2025-01-01T00:00:00Z'),
    deletedAt: null,
    ownedBy: null,
$input_entries
  };

  const entity = new $EntityPascal(data);

  assert.strictEqual(entity.id, data.id);
  assert.strictEqual(entity.active, data.active);
  assert.strictEqual(entity.deletedAt, null);
  assert.strictEqual(entity.ownedBy, null);
EOF

# Agregar asserts para cada campo (excepto id, active, deletedAt, ownedBy)
for row in $(echo "$fields_js" | jq -c '.[]'); do
  name=$(jq -r '.name' <<<"$row")
  cat >>"$TEST_PATH/create-$entity.test.js" <<EOF
  assert.strictEqual(entity.$name, data.$name);
EOF
done

cat >>"$TEST_PATH/create-$entity.test.js" <<EOF
  console.log('✅ $EntityPascal factory test passed');
}

async function testCreate${EntityPascal}() {
  const repo = new InMemory${EntityPascal}Repository();
  const create = new Create$EntityPascal(repo);

  const input = {
$input_entries
  };

  const entity = await create.execute(input);

  assert.ok(entity.id, 'Debe asignar id');
  assert.strictEqual(entity.active, true);
  assert.strictEqual(entity.deletedAt, null);
  assert.strictEqual(entity.ownedBy, null);
EOF

for row in $(echo "$fields_js" | jq -c '.[]'); do
  name=$(jq -r '.name' <<<"$row")
  cat >>"$TEST_PATH/create-$entity.test.js" <<EOF
  assert.strictEqual(entity.$name, input.$name);
EOF
done

cat >>"$TEST_PATH/create-$entity.test.js" <<EOF
  console.log('✅ create-$entity passed');
}

test${EntityPascal}Factory().catch(err => {
  console.error('❌ factory-$entity failed', err);
  process.exit(1);
});

testCreate${EntityPascal}().catch(err => {
  console.error('❌ create-$entity failed', err);
  process.exit(1);
});
EOF

# GET test
cat >"$TEST_PATH/get-$entity.test.js" <<EOF
import assert from 'assert';
import { InMemory${EntityPascal}Repository } from '../../../src/infrastructure/$entity/in-memory-${entity}-repository.js';
import { Create$EntityPascal } from '../../../src/application/$entity/use-cases/create-$entity.js';
import { Get$EntityPascal } from '../../../src/application/$entity/use-cases/get-$entity.js';

async function testGet${EntityPascal}() {
  const repo = new InMemory${EntityPascal}Repository();
  const create = new Create$EntityPascal(repo);
  const get = new Get$EntityPascal(repo);

  const input = {
$input_entries
  };

  const created = await create.execute(input);
  const fetched = await get.execute(created.id);

  assert.strictEqual(fetched.id, created.id);
  console.log('✅ get-$entity passed');
}

testGet${EntityPascal}().catch(err => {
  console.error('❌ get-$entity failed', err);
  process.exit(1);
});
EOF

# UPDATE test
cat >"$TEST_PATH/update-$entity.test.js" <<EOF
import assert from 'assert';
import { InMemory${EntityPascal}Repository } from '../../../src/infrastructure/$entity/in-memory-${entity}-repository.js';
import { Create$EntityPascal } from '../../../src/application/$entity/use-cases/create-$entity.js';
import { Update$EntityPascal } from '../../../src/application/$entity/use-cases/update-$entity.js';

async function testUpdate${EntityPascal}() {
  const repo = new InMemory${EntityPascal}Repository();
  const create = new Create$EntityPascal(repo);
  const update = new Update$EntityPascal(repo);

  const input = {
$input_entries
  };

  const created = await create.execute(input);

  const updateInput = {
EOF

# Para updateInput solo vamos a cambiar los valores, agregando _updated para distinguir
for row in $(echo "$fields_js" | jq -c '.[]'); do
  name=$(jq -r '.name' <<<"$row")
  echo "    $name: \"${name}_updated\"," >>"$TEST_PATH/update-$entity.test.js"
done

cat >>"$TEST_PATH/update-$entity.test.js" <<EOF
  };

  const updated = await update.execute(created.id, updateInput);

EOF

# Asserts para update
for row in $(echo "$fields_js" | jq -c '.[]'); do
  name=$(jq -r '.name' <<<"$row")
  echo "  assert.strictEqual(updated.$name, updateInput.$name);" >>"$TEST_PATH/update-$entity.test.js"
done

cat >>"$TEST_PATH/update-$entity.test.js" <<EOF
  console.log('✅ update-$entity passed');
}

testUpdate${EntityPascal}().catch(err => {
  console.error('❌ update-$entity failed', err);
  process.exit(1);
});
EOF

# DELETE test
cat >"$TEST_PATH/delete-$entity.test.js" <<EOF
import assert from 'assert';
import { InMemory${EntityPascal}Repository } from '../../../src/infrastructure/$entity/in-memory-${entity}-repository.js';
import { Create$EntityPascal } from '../../../src/application/$entity/use-cases/create-$entity.js';
import { Delete$EntityPascal } from '../../../src/application/$entity/use-cases/delete-$entity.js';
import { Get$EntityPascal } from '../../../src/application/$entity/use-cases/get-$entity.js';

async function testDelete${EntityPascal}() {
  const repo = new InMemory${EntityPascal}Repository();
  const create = new Create$EntityPascal(repo);
  const del = new Delete$EntityPascal(repo);
  const get = new Get$EntityPascal(repo);

  const input = {
$input_entries
  };

  const created = await create.execute(input);
  const deleted = await del.execute(created.id);
  assert.strictEqual(deleted, true);

  const fetched = await get.execute(created.id);
  assert.strictEqual(fetched, null);

  console.log('✅ delete-$entity passed');
}

testDelete${EntityPascal}().catch(err => {
  console.error('❌ delete-$entity failed', err);
  process.exit(1);
});
EOF

# DEACTIVATE test
cat >"$TEST_PATH/deactivate-$entity.test.js" <<EOF
import assert from 'assert';
import { InMemory${EntityPascal}Repository } from '../../../src/infrastructure/$entity/in-memory-${entity}-repository.js';
import { Create$EntityPascal } from '../../../src/application/$entity/use-cases/create-$entity.js';
import { Deactivate$EntityPascal } from '../../../src/application/$entity/use-cases/deactivate-$entity.js';
import { Get$EntityPascal } from '../../../src/application/$entity/use-cases/get-$entity.js';

async function testDeactivate${EntityPascal}() {
  const repo = new InMemory${EntityPascal}Repository();
  const create = new Create$EntityPascal(repo);
  const deactivate = new Deactivate$EntityPascal(repo);
  const get = new Get$EntityPascal(repo);

  const input = {
$input_entries
  };

  const created = await create.execute(input);
  const deactivated = await deactivate.execute(created.id);

  assert.ok(deactivated, 'Debe devolver la entidad desactivada');
  assert.strictEqual(deactivated.active, false);

  const fetched = await get.execute(created.id);
  assert.strictEqual(fetched.active, false);

  console.log('✅ deactivate-$entity passed');
}

testDeactivate${EntityPascal}().catch(err => {
  console.error('❌ deactivate-$entity failed', err);
  process.exit(1);
});
EOF

echo "✅ Tests generados: $TEST_PATH"

import assert from 'assert';
import { InMemoryUserRepository } from '../../../src/infrastructure/user/in-memory-user-repository.js';
import { CreateUser } from '../../../src/application/user/use-cases/create-user.js';
import { DeactivateUser } from '../../../src/application/user/use-cases/deactivate-user.js';
import { GetUser } from '../../../src/application/user/use-cases/get-user.js';

async function testDeactivateUser() {
  const repo = new InMemoryUserRepository();
  const createUser = new CreateUser(repo);
  const deactivateUser = new DeactivateUser(repo);
  const getUser = new GetUser(repo);

  // Crear usuario
  const user = await createUser.execute({
    name: 'Franco',
    email: 'franco@example.com',
  });

  // Desactivar usuario
  const deactivatedUser = await deactivateUser.execute(user.id);

  // Verificar que devuelve el usuario desactivado (objeto)
  assert.ok(deactivatedUser, 'Debe devolver el usuario desactivado');
  assert.strictEqual(deactivatedUser.active, false);

  // Obtener usuario y verificar que esté desactivado
  const fetched = await getUser.execute(user.id);
  assert.strictEqual(fetched.active, false);

  console.log('✅ deactivate-user passed');
}

testDeactivateUser().catch(err => {
  console.error('❌ deactivate-user failed', err);
  process.exit(1);
});
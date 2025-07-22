import assert from 'assert';
import { InMemoryUserRepository } from '../../../src/infrastructure/user/in-memory-user-repository.js';
import { CreateUser } from '../../../src/application/user/use-cases/create-user.js';
import { DeactivateUser } from '../../../src/application/user/use-cases/deactivate-user.js';
import { GetUser } from '../../../src/application/user/use-cases/get-user.js';

async function testDeactivateUser() {
  const repo = new InMemoryUserRepository();
  const create = new CreateUser(repo);
  const deactivate = new DeactivateUser(repo);
  const get = new GetUser(repo);

  const input = {

  };

  const created = await create.execute(input);
  const deactivated = await deactivate.execute(created.id);

  assert.ok(deactivated, 'Debe devolver la entidad desactivada');
  assert.strictEqual(deactivated.active, false);

  const fetched = await get.execute(created.id);
  assert.strictEqual(fetched.active, false);

  console.log('✅ deactivate-user passed');
}

testDeactivateUser().catch(err => {
  console.error('❌ deactivate-user failed', err);
  process.exit(1);
});

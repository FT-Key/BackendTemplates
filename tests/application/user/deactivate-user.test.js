import assert from 'assert';
import { InMemoryUserRepository } from '../../../src/infrastructure/user/in-memory-user-repository.js';
import { CreateUser } from '../../../src/application/user/use-cases/create-user.js';
import { DeactivateUser } from '../../../src/application/user/use-cases/deactivate-user.js';

async function testDeactivateUser() {
  const repo = new InMemoryUserRepository();
  const createUser = new CreateUser(repo);
  const deactivateUser = new DeactivateUser(repo);
  const getUser = new (await import('../../../src/application/user/use-cases/get-user.js')).GetUser(repo);

  const user = await createUser.execute({
    name: 'Franco',
    email: 'franco@example.com',
  });

  const deactivated = await deactivateUser.execute(user.id);
  assert.strictEqual(deactivated, true);

  const fetched = await getUser.execute(user.id);
  assert.strictEqual(fetched.isActive, false);

  console.log('✅ deactivate-user passed');
}

testDeactivateUser().catch(err => {
  console.error('❌ deactivate-user failed', err);
  process.exit(1);
});

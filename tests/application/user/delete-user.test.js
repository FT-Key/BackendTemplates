import assert from 'assert';
import { InMemoryUserRepository } from '../../../src/infrastructure/user/in-memory-user-repository.js';
import { CreateUser } from '../../../src/application/user/use-cases/create-user.js';
import { DeleteUser } from '../../../src/application/user/use-cases/delete-user.js';

async function testDeleteUser() {
  const repo = new InMemoryUserRepository();
  const createUser = new CreateUser(repo);
  const deleteUser = new DeleteUser(repo);
  const getUser = new (await import('../../../src/application/user/use-cases/get-user.js')).GetUser(repo);

  const user = await createUser.execute({
    name: 'Franco',
    email: 'franco@example.com',
  });

  const deleted = await deleteUser.execute(user.id);
  assert.strictEqual(deleted, true);

  const fetched = await getUser.execute(user.id);
  assert.strictEqual(fetched, null);

  console.log('✅ delete-user passed');
}

testDeleteUser().catch(err => {
  console.error('❌ delete-user failed', err);
  process.exit(1);
});

import assert from 'assert';
import { InMemoryUserRepository } from '../../../src/infrastructure/user/in-memory-user-repository.js';
import { CreateUser } from '../../../src/application/user/use-cases/create-user.js';
import { DeleteUser } from '../../../src/application/user/use-cases/delete-user.js';
import { GetUser } from '../../../src/application/user/use-cases/get-user.js';

async function testDeleteUser() {
  const repo = new InMemoryUserRepository();
  const create = new CreateUser(repo);
  const del = new DeleteUser(repo);
  const get = new GetUser(repo);

  const input = {

  };

  const created = await create.execute(input);
  const deleted = await del.execute(created.id);
  assert.strictEqual(deleted, true);

  const fetched = await get.execute(created.id);
  assert.strictEqual(fetched, null);

  console.log('✅ delete-user passed');
}

testDeleteUser().catch(err => {
  console.error('❌ delete-user failed', err);
  process.exit(1);
});

import assert from 'assert';
import { InMemoryUserRepository } from '../../../src/infrastructure/user/in-memory-user-repository.js';
import { CreateUser } from '../../../src/application/user/use-cases/create-user.js';
import { GetUser } from '../../../src/application/user/use-cases/get-user.js';

async function testGetUser() {
  const repo = new InMemoryUserRepository();
  const create = new CreateUser(repo);
  const get = new GetUser(repo);

  const input = {

  };

  const created = await create.execute(input);
  const fetched = await get.execute(created.id);

  assert.strictEqual(fetched.id, created.id);
  console.log('✅ get-user passed');
}

testGetUser().catch(err => {
  console.error('❌ get-user failed', err);
  process.exit(1);
});

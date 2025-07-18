import assert from 'assert';
import { InMemoryUserRepository } from '../../../src/infrastructure/user/in-memory-user-repository.js';
import { CreateUser } from '../../../src/application/user/use-cases/create-user.js';
import { GetUser } from '../../../src/application/user/use-cases/get-user.js';

async function testGetUser() {
  const repo = new InMemoryUserRepository();
  const createUser = new CreateUser(repo);
  const getUser = new GetUser(repo);

  const userCreated = await createUser.execute({
    name: 'Franco Toledo',
    email: 'franco@example.com',
  });

  const userFetched = await getUser.execute(userCreated.id);

  assert.strictEqual(userFetched.id, userCreated.id);
  console.log('✅ get-user passed');
}

testGetUser().catch(err => {
  console.error('❌ get-user failed', err);
  process.exit(1);
});

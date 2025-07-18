import assert from 'assert';
import { InMemoryUserRepository } from '../../../src/infrastructure/user/in-memory-user-repository.js';
import { CreateUser } from '../../../src/application/user/use-cases/create-user.js';

async function testCreateUser() {
  const repo = new InMemoryUserRepository();
  const createUser = new CreateUser(repo);

  const user = await createUser.execute({
    name: 'Franco Toledo',
    email: 'franco@example.com',
    password: '1234',
  });

  assert.strictEqual(user.name, 'Franco Toledo');
  assert.strictEqual(user.email, 'franco@example.com');
  console.log('✅ create-user passed');
}

testCreateUser().catch(err => {
  console.error('❌ create-user failed', err);
  process.exit(1);
});

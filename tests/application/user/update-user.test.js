import assert from 'assert';
import { InMemoryUserRepository } from '../../../src/infrastructure/user/in-memory-user-repository.js';
import { CreateUser } from '../../../src/application/user/use-cases/create-user.js';
import { UpdateUser } from '../../../src/application/user/use-cases/update-user.js';

async function testUpdateUser() {
  const repo = new InMemoryUserRepository();
  const createUser = new CreateUser(repo);
  const updateUser = new UpdateUser(repo);

  const user = await createUser.execute({
    name: 'Franco',
    email: 'franco@example.com',
  });

  const updatedUser = await updateUser.execute(user.id, {
    name: 'Franco T.',
    email: 'franco.t@example.com',
  });

  assert.strictEqual(updatedUser.name, 'Franco T.');
  assert.strictEqual(updatedUser.email, 'franco.t@example.com');
  console.log('✅ update-user passed');
}

testUpdateUser().catch(err => {
  console.error('❌ update-user failed', err);
  process.exit(1);
});

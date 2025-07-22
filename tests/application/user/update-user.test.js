import assert from 'assert';
import { InMemoryUserRepository } from '../../../src/infrastructure/user/in-memory-user-repository.js';
import { CreateUser } from '../../../src/application/user/use-cases/create-user.js';
import { UpdateUser } from '../../../src/application/user/use-cases/update-user.js';

async function testUpdateUser() {
  const repo = new InMemoryUserRepository();
  const create = new CreateUser(repo);
  const update = new UpdateUser(repo);

  const input = {

  };

  const created = await create.execute(input);

  const updateInput = {
  };

  const updated = await update.execute(created.id, updateInput);

  console.log('✅ update-user passed');
}

testUpdateUser().catch(err => {
  console.error('❌ update-user failed', err);
  process.exit(1);
});

import assert from 'assert';
import { User } from '../../../src/domain/user/user.js';
import { InMemoryUserRepository } from '../../../src/infrastructure/user/in-memory-user-repository.js';
import { CreateUser } from '../../../src/application/user/use-cases/create-user.js';

async function testUserFactory() {
  const data = {
    id: '123',
    active: true,
    createdAt: new Date('2025-01-01T00:00:00Z'),
    updatedAt: new Date('2025-01-01T00:00:00Z'),
    deletedAt: null,
    ownedBy: null,

  };

  const entity = new User(data);

  assert.strictEqual(entity.id, data.id);
  assert.strictEqual(entity.active, data.active);
  assert.strictEqual(entity.deletedAt, null);
  assert.strictEqual(entity.ownedBy, null);
  console.log('✅ User factory test passed');
}

async function testCreateUser() {
  const repo = new InMemoryUserRepository();
  const create = new CreateUser(repo);

  const input = {

  };

  const entity = await create.execute(input);

  assert.ok(entity.id, 'Debe asignar id');
  assert.strictEqual(entity.active, true);
  assert.strictEqual(entity.deletedAt, null);
  assert.strictEqual(entity.ownedBy, null);
  console.log('✅ create-user passed');
}

testUserFactory().catch(err => {
  console.error('❌ factory-user failed', err);
  process.exit(1);
});

testCreateUser().catch(err => {
  console.error('❌ create-user failed', err);
  process.exit(1);
});

import assert from 'assert';
import { User } from '../../../src/domain/user/user.js';
import { InMemoryUserRepository } from '../../../src/infrastructure/user/in-memory-user-repository.js';
import { CreateUser } from '../../../src/application/user/use-cases/create-user.js';

async function testUserFactory() {
  // Datos de ejemplo completos, incluyendo todos los campos opcionales
  const data = {
    id: '123',
    name: 'Franco Toledo',
    email: 'franco@example.com',
    password: null,
    active: true,
    createdAt: new Date('2025-01-01T00:00:00Z'),
    updatedAt: new Date('2025-01-01T00:00:00Z'),
    deletedAt: null,
    ownedBy: null,
  };
  const user = new User(data);

  assert.strictEqual(user.id, data.id);
  assert.strictEqual(user.name, data.name);
  assert.strictEqual(user.email, data.email);
  assert.strictEqual(user.active, data.active);
  assert.strictEqual(user.password, data.password);
  assert.strictEqual(user.deletedAt, data.deletedAt);
  assert.strictEqual(user.ownedBy, data.ownedBy);
  assert.deepStrictEqual(user.toJSON(), data);

  console.log('✅ User factory test passed');
}

async function testCreateUserUseCase() {
  const repo = new InMemoryUserRepository();
  const createUser = new CreateUser(repo);

  const input = {
    name: 'Franco Toledo',
    email: 'franco@example.com',
    password: '1234',
  };

  const user = await createUser.execute(input);

  assert.strictEqual(user.name, input.name);
  assert.strictEqual(user.email, input.email);
  assert.strictEqual(user.password, input.password);
  assert.ok(user.id, 'User id should be set');
  assert.strictEqual(user.active, true); // valor por defecto

  // Verificamos que deletedAt y ownedBy estén presentes y sean null
  assert.strictEqual(user.deletedAt, null);
  assert.strictEqual(user.ownedBy, null);

  console.log('✅ CreateUser use case test passed');
}

async function runTests() {
  await testUserFactory();
  await testCreateUserUseCase();
}

runTests().catch(err => {
  console.error('❌ Test failed:', err);
  process.exit(1);
});
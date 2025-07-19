import assert from 'assert';
import { User } from '../../../src/domain/user/user.js';
import { InMemoryUserRepository } from '../../../src/infrastructure/user/in-memory-user-repository.js';
import { CreateUser } from '../../../src/application/user/use-cases/create-user.js';

async function testUserFactory() {
  // Prueba directa de la entidad User (fábrica)
  const data = {
    id: '123',
    name: 'Franco Toledo',
    active: true,
  };
  const user = new User(data);

  assert.strictEqual(user.id, data.id);
  assert.strictEqual(user.name, data.name);
  assert.strictEqual(user.active, data.active);
  assert.deepStrictEqual(user.toJSON(), data);

  console.log('✅ User factory test passed');
}

async function testCreateUserUseCase() {
  // Prueba del caso de uso CreateUser
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
  assert.strictEqual(user.active, true); // o el valor default que pongas

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
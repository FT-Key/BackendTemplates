import { checkRole, checkRoleOrOwner } from '../../../../src/interfaces/http/middlewares/check-role.middleware.js';

function assertEqual(actual, expected, message) {
  if (actual !== expected) {
    throw new Error(`${message} | Esperado: ${expected}, Recibido: ${actual}`);
  }
}

function testCheckRolePermiteRolCorrecto() {
  let llamado = false;
  const req = { user: { role: 'admin' } };
  const res = {};
  const next = () => { llamado = true; };

  checkRole('admin')(req, res, next);

  assertEqual(llamado, true, 'Debe llamar a next si el rol es correcto');
}

function testCheckRoleRechazaRolIncorrecto() {
  const req = { user: { role: 'user' } };
  const res = {
    status(code) {
      assertEqual(code, 403, 'Debe devolver 403 si el rol es incorrecto');
      return {
        json(obj) {
          assertEqual(obj.message, 'Acceso denegado', 'Mensaje incorrecto');
        },
      };
    },
  };

  checkRole('admin')(req, res, () => {
    throw new Error('No debería llamar a next');
  });
}

function testCheckRoleSinUsuario() {
  const req = {};
  const res = {
    status(code) {
      assertEqual(code, 401, 'Debe devolver 401 si no hay usuario');
      return {
        json(obj) {
          assertEqual(obj.message, 'No autorizado', 'Mensaje incorrecto');
        },
      };
    },
  };

  checkRole('admin')(req, res, () => {
    throw new Error('No debería llamar a next');
  });
}

function runTests() {
  const tests = [
    testCheckRolePermiteRolCorrecto,
    testCheckRoleRechazaRolIncorrecto,
    testCheckRoleSinUsuario,
  ];

  for (const test of tests) {
    try {
      test();
      console.log(`✅ ${test.name} pasó correctamente`);
    } catch (err) {
      console.error(`❌ ${test.name} falló: ${err.message}`);
    }
  }
}

runTests();
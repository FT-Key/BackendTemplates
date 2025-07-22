import express from 'express';
import {
  createUserController,
  getUserController,
  updateUserController,
  deleteUserController,
  deactivateUserController,
  listUsersController,   // IMPORTAR EL NUEVO CONTROLADOR
} from './user.controller.js';

const router = express.Router();

router.post('/', createUserController);
router.get('/', listUsersController);  // <-- Aquí la ruta para listar usuarios
router.get('/:id', getUserController);
router.put('/:id', updateUserController);
router.delete('/:id', deleteUserController);
router.patch('/:id/deactivate', deactivateUserController);

export default router;
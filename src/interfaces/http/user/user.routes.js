import express from 'express';
import { createUser } from './UserController.js';

const router = express.Router();

router.post('/', createUser);

export default router;

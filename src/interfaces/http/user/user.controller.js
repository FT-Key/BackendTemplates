import { InMemoryUserRepository } from '../../../infrastructure/user/in-memory-user-repository.js';
import { createUser } from '../../../application/user/use-cases/create-user.js';
import { getUserById } from '../../../application/user/use-cases/get-user.js';
import { updateUser } from '../../../application/user/use-cases/update-user.js';
import { deleteUser } from '../../../application/user/use-cases/delete-user.js';
import { deactivateUser } from '../../../application/user/use-cases/deactivate-user.js';

const userRepository = new InMemoryUserRepository();

export const createUserController = async (req, res) => {
  try {
    const { name, email } = req.body;
    const user = await createUser(userRepository, { name, email });
    res.status(201).json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

export const getUserController = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await getUserById(userRepository, id);
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

export const updateUserController = async (req, res) => {
  try {
    const { id } = req.params;
    const data = req.body;
    const user = await updateUser(userRepository, id, data);
    res.json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

export const deleteUserController = async (req, res) => {
  try {
    const { id } = req.params;
    const success = await deleteUser(userRepository, id);
    if (!success) return res.status(404).json({ error: 'User not found' });
    res.status(204).send(); // No content
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

export const deactivateUserController = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await deactivateUser(userRepository, id);
    res.json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};
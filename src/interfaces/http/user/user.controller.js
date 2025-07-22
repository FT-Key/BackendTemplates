import { InMemoryUserRepository } from '../../../infrastructure/user/in-memory-user-repository.js';

import { CreateUser } from '../../../application/user/use-cases/create-user.js';
import { GetUser } from '../../../application/user/use-cases/get-user.js';
import { UpdateUser } from '../../../application/user/use-cases/update-user.js';
import { DeleteUser } from '../../../application/user/use-cases/delete-user.js';
import { DeactivateUser } from '../../../application/user/use-cases/deactivate-user.js';

const userRepository = new InMemoryUserRepository();

export const createUserController = async (req, res) => {
  try {
    const { name, email } = req.body;
    const useCase = new CreateUser(userRepository);
    const user = await useCase.execute({ name, email });
    res.status(201).json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

export const getUserController = async (req, res) => {
  try {
    const { id } = req.params;
    const useCase = new GetUser(userRepository);
    const user = await useCase.execute(id);
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
    const useCase = new UpdateUser(userRepository);
    const user = await useCase.execute(id, data);
    res.json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

export const deleteUserController = async (req, res) => {
  try {
    const { id } = req.params;
    const useCase = new DeleteUser(userRepository);
    const success = await useCase.execute(id);
    if (!success) return res.status(404).json({ error: 'User not found' });
    res.status(204).send(); // No content
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

export const deactivateUserController = async (req, res) => {
  try {
    const { id } = req.params;
    const useCase = new DeactivateUser(userRepository);
    const user = await useCase.execute(id);
    res.json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

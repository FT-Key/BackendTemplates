import { InMemoryUserRepository } from '../../../infrastructure/user/in-memory-user-repository.js';

import { CreateUser } from '../../../application/user/use-cases/create-user.js';
import { GetUser } from '../../../application/user/use-cases/get-user.js';
import { UpdateUser } from '../../../application/user/use-cases/update-user.js';
import { DeleteUser } from '../../../application/user/use-cases/delete-user.js';
import { DeactivateUser } from '../../../application/user/use-cases/deactivate-user.js';
import { ListUsers } from '../../../application/user/use-cases/list-users.js';

const repository = new InMemoryUserRepository();

export const createUserController = async (req, res) => {
  const useCase = new CreateUser(repository);
  const item = await useCase.execute(req.body);
  res.status(201).json(item);
};

export const getUserController = async (req, res) => {
  const useCase = new GetUser(repository);
  const item = await useCase.execute(req.params.id);
  if (!item) return res.status(404).json({ error: 'User not found' });
  res.json(item);
};

export const updateUserController = async (req, res) => {
  const useCase = new UpdateUser(repository);
  const item = await useCase.execute(req.params.id, req.body);
  res.json(item);
};

export const deleteUserController = async (req, res) => {
  const useCase = new DeleteUser(repository);
  const success = await useCase.execute(req.params.id);
  res.status(success ? 204 : 404).send();
};

export const deactivateUserController = async (req, res) => {
  const useCase = new DeactivateUser(repository);
  const item = await useCase.execute(req.params.id);
  res.json(item);
};

export const listUsersController = async (req, res) => {
  const useCase = new ListUsers(repository);
  const users = await useCase.execute({
    filters: req.filters,
    search: req.search,
    pagination: req.pagination,
    sort: req.sort,
  });
  res.json(users);
};

import { UserFactory } from '../../../domain/user/user-factory.js';
import crypto from 'crypto';

export class CreateUser {
  constructor(repository) {
    this.repository = repository;
  }

  async execute(data) {
    const entity = UserFactory.create({
      ...data,
      id: crypto.randomUUID(),
    });
    return this.repository.save(entity);
  }
}

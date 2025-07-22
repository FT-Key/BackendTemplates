import { UserFactory } from '../../../domain/user/user-factory.js';

export class UpdateUser {
  constructor(repository) {
    this.repository = repository;
  }

  async execute(id, data) {
    if (!id) throw new Error('User id is required');

    const existing = await this.repository.findById(id);
    if (!existing) throw new Error('User not found');

    const updated = UserFactory.create({
      ...existing,
      ...data,
      id: existing.id,
    });
    return this.repository.save(updated);
  }
}

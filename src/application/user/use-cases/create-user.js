// create-user.js
import { UserFactory } from '../../../domain/user/user-factory.js';
import crypto from 'crypto';

export class CreateUser {
  /**
   * @param {Object} userRepository  Debe tener método save(user)
   */
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  /**
   * @param {Object} data
   * @param {string} data.name
   * @param {string} data.email
   * @param {string} [data.password]
   * @returns {Promise<User>}
   */
  async execute(data) {
    // Usamos la fábrica para crear y validar
    const user = UserFactory.create({
      ...data,
      id: crypto.randomUUID(),
    });

    return this.userRepository.save(user);
  }
}
import { User } from '../../../domain/user/user.js';
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
    // Validaciones básicas
    if (!data.name) throw new Error('Name is required');
    if (!data.email) throw new Error('Email is required');

    const user = new User({
      id: crypto.randomUUID(),
      name: data.name,
      email: data.email,
      password: data.password || null,
    });

    return this.userRepository.save(user);
  }
}

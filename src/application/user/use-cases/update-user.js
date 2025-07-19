// update-user.js
import { UserFactory } from '../../../domain/user/user-factory.js';

export class UpdateUser {
  /**
   * @param {Object} userRepository  Debe tener métodos findById(id) y save(user)
   */
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  /**
   * @param {string} id
   * @param {Object} data
   * @param {string} [data.name]
   * @param {string} [data.email]
   * @param {string} [data.password]
   * @returns {Promise<User>}
   */
  async execute(id, data) {
    if (!id) throw new Error('User id is required');

    const existingUser = await this.userRepository.findById(id);
    if (!existingUser) throw new Error('User not found');

    // Construimos el nuevo estado de la entidad con la fábrica para validar
    const updatedUser = UserFactory.create({
      ...existingUser,
      ...data,
      id: existingUser.id, // aseguramos que el id no cambie
    });

    return this.userRepository.save(updatedUser);
  }
}

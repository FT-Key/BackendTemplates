export class DeactivateUser {
  /**
   * @param {Object} userRepository Debe tener métodos findById(id) y save(user)
   */
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  /**
   * @param {string} id
   * @returns {Promise<User|null>} Devuelve el usuario desactivado o null si no existe
   */
  async execute(id) {
    if (!id) throw new Error('User id is required');

    const user = await this.userRepository.deactivateById(id);
    return user; // usuario desactivado o null
  }
}
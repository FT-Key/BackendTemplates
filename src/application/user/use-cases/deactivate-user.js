export class DeactivateUser {
  /**
   * @param {Object} userRepository Debe tener métodos findById(id) y save(user)
   */
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  /**
   * @param {string} id
   * @returns {Promise<boolean>} true si usuario se desactivó, false si no existe
   */
  async execute(id) {
    if (!id) throw new Error('User id is required');

    return this.userRepository.deactivateById(id);
  }
}

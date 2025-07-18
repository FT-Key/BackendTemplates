export class DeleteUser {
  /**
   * @param {Object} userRepository Debe tener método deleteById(id)
   */
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  /**
   * @param {string} id
   * @returns {Promise<boolean>} true si usuario se eliminó, false si no existe
   */
  async execute(id) {
    if (!id) throw new Error('User id is required');

    return this.userRepository.deleteById(id);
  }
}

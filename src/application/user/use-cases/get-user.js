export class GetUser {
  /**
   * @param {Object} userRepository  Debe tener método findById(id)
   */
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  /**
   * @param {string} id
   * @returns {Promise<User|null>}
   */
  async execute(id) {
    if (!id) throw new Error('User id is required');
    return this.userRepository.findById(id);
  }
}

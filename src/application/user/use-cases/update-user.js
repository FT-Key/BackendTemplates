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

    const user = await this.userRepository.findById(id);
    if (!user) throw new Error('User not found');

    if (data.name) user.name = data.name;
    if (data.email) user.email = data.email;
    if (data.password) user.password = data.password;

    return this.userRepository.save(user);
  }
}

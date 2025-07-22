export class GetUser {
  /**
   * @param {Object} repository  Debe tener método findById(id)
   */
  constructor(repository) {
    this.repository = repository;
  }

  /**
   * @param {string} id
   * @returns {Promise<User|null>}
   */
  async execute(id) {
    if (!id) throw new Error('User id is required');
    return this.repository.findById(id);
  }
}

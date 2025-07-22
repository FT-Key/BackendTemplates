export class DeactivateUser {
  /**
   * @param {Object} repository Debe tener métodos findById(id) y save(user)
   */
  constructor(repository) {
    this.repository = repository;
  }

  /**
   * @param {string} id
   * @returns {Promise<User|null>} Devuelve el user desactivado o null si no existe
   */
  async execute(id) {
    if (!id) throw new Error('User id is required');
    const result = await this.repository.deactivateById(id);
    return result;
  }
}

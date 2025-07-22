export class DeleteUser {
  /**
   * @param {Object} repository Debe tener método deleteById(id)
   */
  constructor(repository) {
    this.repository = repository;
  }

  /**
   * @param {string} id
   * @returns {Promise<boolean>} true si user se eliminó, false si no existe
   */
  async execute(id) {
    if (!id) throw new Error('User id is required');
    return this.repository.deleteById(id);
  }
}

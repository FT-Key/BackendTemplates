export class ListUsers {
  constructor(repository) {
    this.repository = repository;
  }

  /**
   * @param {Object} options
   * @param {Object} options.filters
   * @param {string} options.search
   * @param {Object} options.pagination
   * @param {Object} options.sort
   * @returns {Promise<User[]>}
   */
  async execute({ filters, search, pagination, sort }) {
    console.log("entra al middleware")
    return this.repository.findAll({ filters, search, pagination, sort });
  }
}

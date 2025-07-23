import { User } from '../../domain/user/user.js';
import { mockUser } from '../../domain/user/mocks.js';
import { applyFilters, applySearch, applySort, applyPagination } from '../../utils/query-utils.js';

export class InMemoryUserRepository {
  constructor() {
    /** @type {User[]} */
    this.items = [
      new User({ id: '1', active: true, ownedBy: 'franco', createdAt: new Date('2024-01-01') }),
      new User({ id: '2', active: true, ownedBy: 'admin', createdAt: new Date('2024-02-15') }),
      new User({ id: '3', active: false, ownedBy: 'guest', createdAt: new Date('2023-12-10') }),
    ];

  }

  async save(item) {
    const index = this.items.findIndex(i => i.id === item.id);
    if (index === -1) {
      this.items.push(item);
    } else {
      // Actualizar manteniendo instancia de dominio
      this.items[index] = item;
    }
    return item;
  }

  async findById(id) {
    return this.items.find(i => i.id === id) || null;
  }

  /**
   * Buscar todos con opciones de filtros, búsqueda, paginación y orden
   * @param {Object} [options]
   * @param {Object} [options.filters] - pares { campo: valor } para filtrar exacto (case-insensitive para strings)
   * @param {Object} [options.search] - { query: string, fields: string[] } para búsqueda por texto libre
   * @param {Object} [options.pagination] - { limit: number, offset: number }
   * @param {Object} [options.sort] - { sortBy: string, order: 'asc' | 'desc' }
   */
  async findAll(options = {}) {
    const { filters = {}, search = null, pagination = null, sort = null } = options;
    let result = [...this.items];

    // Aplicar filtros exactos (case-insensitive para strings)
    result = applyFilters(result, options.filters);

    // Aplicar búsqueda por texto libre
    result = applySearch(result, options.search);

    // Aplicar orden solo si sort está definido
    result = applySort(result, options.sort);

    // Aplicar paginación si está definida
    result = applyPagination(result, options.pagination);

    return result;
  }

  async update(id, data) {
    const item = await this.findById(id);
    if (!item) return null;
    // Usar método update del dominio para respetar lógica y setters
    item.update(data);
    await this.save(item);
    return item;
  }

  async deleteById(id) {
    const length = this.items.length;
    this.items = this.items.filter(i => i.id !== id);
    return this.items.length < length;
  }

  async deactivateById(id) {
    const item = await this.findById(id);
    if (!item) return null;
    item.deactivate(); // usar método de dominio
    await this.save(item);
    return item;
  }
}

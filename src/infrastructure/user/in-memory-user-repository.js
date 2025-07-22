import { User } from '../../domain/user/user.js';
import { mockUsers } from '../../domain/user/mocks.js';

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
    console.log("repositorio 1", result);

    // Aplicar filtros exactos (case-insensitive para strings)
    for (const key in filters) {
      const filterVal = filters[key];
      result = result.filter(user => {
        const userVal = user[key]; // accede al getter público
        if (typeof userVal === 'string' && typeof filterVal === 'string') {
          return userVal.toLowerCase() === filterVal.toLowerCase();
        }
        if (typeof userVal === 'boolean') {
          return userVal === (filterVal === 'true');
        }
        return userVal === filterVal;
      });
    }

    // Aplicar búsqueda por texto libre
    if (search && search.query && Array.isArray(search.fields)) {
      const q = search.query.toLowerCase();
      result = result.filter(user =>
        search.fields.some(field => {
          const val = user[field];
          if (typeof val === 'string') {
            return val.toLowerCase().includes(q);
          }
          return false;
        })
      );
    }

    // Aplicar orden solo si sort está definido
    if (sort && sort.sortBy) {
      const { sortBy, order = 'asc' } = sort;
      result.sort((a, b) => {
        const aVal = a[sortBy];
        const bVal = b[sortBy];
        if (aVal == null && bVal != null) return order === 'asc' ? -1 : 1;
        if (aVal != null && bVal == null) return order === 'asc' ? 1 : -1;
        if (aVal == null && bVal == null) return 0;

        if (typeof aVal === 'string' && typeof bVal === 'string') {
          return order === 'asc' ? aVal.localeCompare(bVal) : bVal.localeCompare(aVal);
        }

        return order === 'asc'
          ? (aVal < bVal ? -1 : aVal > bVal ? 1 : 0)
          : (aVal > bVal ? -1 : aVal < bVal ? 1 : 0);
      });
    }

    // Aplicar paginación si está definida
    if (pagination) {
      const offset = pagination.offset ?? 0;
      const limit = pagination.limit ?? result.length;
      result = result.slice(offset, offset + limit);
    }

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

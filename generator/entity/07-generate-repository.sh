#!/bin/bash
# shellcheck disable=SC2154
# 2. INFRASTRUCTURE/REPOSITORY

infra_file="src/infrastructure/$entity/in-memory-${entity}-repository.js"

if [[ -f "$infra_file" && "$AUTO_CONFIRM" != true ]]; then
  read -r -p "⚠️  El archivo $infra_file ya existe. ¿Deseas sobrescribirlo? [y/n]: " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "⏭️  Repositorio omitido: $infra_file"
    exit 0
  fi
fi

cat <<EOF >"$infra_file"
import { $EntityPascal } from '../../domain/$entity/$entity.js';
import { mock${EntityPascal} } from '../../domain/$entity/mocks.js';

export class InMemory${EntityPascal}Repository {
  constructor() {
    /** @type {${EntityPascal}[]} */
    this.items = [];
  }

  async save(item) {
    const index = this.items.findIndex(i => i.id === item.id);
    if (index === -1) {
      this.items.push(item);
    } else {
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

    // Aplicar filtros exactos
    for (const key in filters) {
      const filterVal = filters[key];
      result = result.filter(item => {
        const val = item[key];
        if (typeof val === 'string' && typeof filterVal === 'string') {
          return val.toLowerCase() === filterVal.toLowerCase();
        }
        if (typeof val === 'boolean') {
          return val === (filterVal === 'true');
        }
        return val === filterVal;
      });
    }

    // Búsqueda por texto libre
    if (search && search.query && Array.isArray(search.fields)) {
      const q = search.query.toLowerCase();
      result = result.filter(item =>
        search.fields.some(field => {
          const val = item[field];
          if (typeof val === 'string') {
            return val.toLowerCase().includes(q);
          }
          return false;
        })
      );
    }

    // Ordenamiento
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

    // Paginación
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
    item.deactivate();
    await this.save(item);
    return item;
  }
}
EOF

echo "✅ Adaptador generado: $infra_file"

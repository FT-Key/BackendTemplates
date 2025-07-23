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
import {
  applyFilters,
  applySearch,
  applySort,
  applyPagination
} from '../../utils/query-utils.js';

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
   * @param {Object} [options.filters]
   * @param {Object} [options.search]
   * @param {Object} [options.pagination]
   * @param {Object} [options.sort]
   */
  async findAll(options = {}) {
    let result = [...this.items];

    result = applyFilters(result, options.filters);
    result = applySearch(result, options.search);
    result = applySort(result, options.sort);
    result = applyPagination(result, options.pagination);

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

#!/bin/bash
# shellcheck disable=SC2154
# 2. INFRASTRUCTURE/REPOSITORY
infra_file="src/infrastructure/$entity/in-memory-${entity}-repository.js"
if confirm_action "¿Inicializar repositorio InMemory ($infra_file)?"; then
  cat <<EOF >"$infra_file"
import { $EntityPascal } from '../../domain/$entity/$entity.js';

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
      // Actualizar manteniendo instancia de dominio
      this.items[index] = item;
    }
    return item;
  }

  async findById(id) {
    return this.items.find(i => i.id === id) || null;
  }

  async findAll() {
    return this.items;
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
EOF

  echo "✅ Adaptador generado: $infra_file"
fi

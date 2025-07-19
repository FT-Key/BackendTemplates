import { User } from '../../domain/user/user.js';

export class InMemoryUserRepository {
  constructor() {
    /** @type {User[]} */
    this.users = [];
  }

  /**
   * Guarda un usuario en memoria
   * @param {User} user
   * @returns {Promise<User>}
   */
  async save(user) {
    this.users.push(user);
    return user;
  }

  /**
   * Busca un usuario por id
   * @param {string} id
   * @returns {Promise<User | null>}
   */
  async findById(id) {
    const user = this.users.find(u => u.id === id);
    return user || null;
  }

  /**
   * Devuelve todos los usuarios
   * @returns {Promise<User[]>}
   */
  async findAll() {
    return this.users;
  }

  /**
   * Baja física: elimina usuario
   * Elimina un usuario por id
   * @param {string} id
   * @returns {Promise<boolean>} true si se eliminó, false si no existe
   */
  async deleteById(id) {
    const initialLength = this.users.length;
    this.users = this.users.filter(u => u.id !== id);
    return this.users.length < initialLength;
  }

  /**
 * Baja lógica: marca usuario como inactivo
 * Desactiva un usuario por id
 * @param {string} id
 * @returns {Promise<boolean>} true si se desactivó, false si no existe
 */
  async deactivateById(id) {
    const user = await this.findById(id);
    if (!user) return null; // o false
    user.deactivate();
    await this.save(user);
    return user;
  }
}

import { User } from './user.js';
import { validateUser } from './validate-user.js';

export class UserFactory {
  /**
   * Crea una instancia de User validando los datos.
   * @param {Object} data
   * @returns {User}
   */
  static create(data) {
    validateUser(data);
    return new User(data);
  }
}

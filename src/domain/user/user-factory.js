// domain/user/user-factory.js
import { User } from './user.js';
import { validateUser } from './validate-user.js';

export class UserFactory {
  static create(data) {
    validateUser(data); // puede lanzar error si no valida
    return new User(data);
  }
}
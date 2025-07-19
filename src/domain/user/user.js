export class User {
  /**
   * @param {Object} params
   * @param {string} params.id
   * @param {string} params.name
   * @param {string} params.email
   * @param {string|null} [params.password]
   * @param {boolean} [params.active]
   * @param {Date} [params.createdAt]
   * @param {Date} [params.updatedAt]
   * @param {Date|null} [params.deletedAt]
   * @param {string|null} [params.ownedBy]
   */
  constructor({
    id,
    name,
    email,
    password = null,
    active = true,
    createdAt = new Date(),
    updatedAt = new Date(),
    deletedAt = null,
    ownedBy = null,
  }) {
    if (!id) throw new Error('User id is required');
    if (!name) throw new Error('User name is required');
    if (!email) throw new Error('User email is required');

    this._id = id;
    this._name = name;
    this._email = email;
    this._password = password;
    this._active = active;
    this._createdAt = createdAt;
    this._updatedAt = updatedAt;
    this._deletedAt = deletedAt;
    this._ownedBy = ownedBy;
  }

  // Getters y setters

  get id() {
    return this._id;
  }

  get name() {
    return this._name;
  }
  set name(value) {
    if (!value) throw new Error('Name cannot be empty');
    this._name = value;
    this._touchUpdatedAt();
  }

  get email() {
    return this._email;
  }
  set email(value) {
    if (!value) throw new Error('Email cannot be empty');
    this._email = value;
    this._touchUpdatedAt();
  }

  get password() {
    return this._password;
  }
  set password(value) {
    this._password = value;
    this._touchUpdatedAt();
  }

  get active() {
    return this._active;
  }

  get createdAt() {
    return this._createdAt;
  }

  get updatedAt() {
    return this._updatedAt;
  }

  get deletedAt() {
    return this._deletedAt;
  }
  set deletedAt(value) {
    this._deletedAt = value;
    this._touchUpdatedAt();
  }

  get ownedBy() {
    return this._ownedBy;
  }
  set ownedBy(value) {
    this._ownedBy = value;
    this._touchUpdatedAt();
  }

  // Métodos para activar / desactivar
  activate() {
    this._active = true;
    this._touchUpdatedAt();
  }

  deactivate() {
    this._active = false;
    this._touchUpdatedAt();
  }

  // Actualizar updatedAt
  _touchUpdatedAt() {
    this._updatedAt = new Date();
  }

  // Exportar a JSON
  toJSON() {
    return {
      id: this._id,
      name: this._name,
      email: this._email,
      password: this._password,
      active: this._active,
      createdAt: this._createdAt,
      updatedAt: this._updatedAt,
      deletedAt: this._deletedAt,
      ownedBy: this._ownedBy,
    };
  }
}
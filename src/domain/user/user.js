export class User {
  /**
   * @param {Object} props
   * @param {string} props.id
   * @param {string} props.name
   * @param {string} props.email
   * @param {string} [props.password]         // Hasheada idealmente
   * @param {boolean} [props.isActive]
   * @param {Date} [props.createdAt]
   * @param {Date} [props.updatedAt]
   * @param {Object} [props.metadata]         // Para agregar campos extra dinámicos
   */
  constructor(props) {
    if (!props) throw new Error('Props is required');
    if (!props.id) throw new Error('User id is required');
    if (!props.name) throw new Error('User name is required');
    if (!props.email) throw new Error('User email is required');

    this._id = props.id;
    this._name = props.name;
    this._email = props.email;
    this._password = props.password || null;
    this._isActive = props.isActive !== undefined ? props.isActive : true;
    this._createdAt = props.createdAt || new Date();
    this._updatedAt = props.updatedAt || new Date();
    this._metadata = props.metadata || {};
  }

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
    // Aquí podrías agregar validación o hashing fuera de esta clase
    this._password = value;
    this._touchUpdatedAt();
  }

  get isActive() {
    return this._isActive;
  }

  activate() {
    this._isActive = true;
    this._touchUpdatedAt();
  }

  deactivate() {
    this._isActive = false;
    this._touchUpdatedAt();
  }

  get createdAt() {
    return this._createdAt;
  }

  get updatedAt() {
    return this._updatedAt;
  }

  get metadata() {
    return this._metadata;
  }

  setMetadata(key, value) {
    this._metadata[key] = value;
    this._touchUpdatedAt();
  }

  _touchUpdatedAt() {
    this._updatedAt = new Date();
  }

  toJSON() {
    return {
      id: this._id,
      name: this._name,
      email: this._email,
      isActive: this._isActive,
      createdAt: this._createdAt,
      updatedAt: this._updatedAt,
      metadata: this._metadata,
    };
  }
}

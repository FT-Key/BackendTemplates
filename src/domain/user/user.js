export class User {
  /**
   * @param {Object} params
   */
  constructor({ id, active = true, createdAt = new Date(), updatedAt = new Date(), deletedAt = null, ownedBy = null }) {
    if (id === undefined) throw new Error('id is required');
    this._id = id;
    this._active = active;
    this._createdAt = createdAt;
    this._updatedAt = updatedAt;
    this._deletedAt = deletedAt;
    this._ownedBy = ownedBy;
  }

  get id() { return this._id; }
  get active() { return this._active; }
  get createdAt() { return this._createdAt; }
  get updatedAt() { return this._updatedAt; }
  get deletedAt() { return this._deletedAt; }
  get ownedBy() { return this._ownedBy; }
  set id(value) { this._id = value; this._touchUpdatedAt(); }
  set active(value) { this._active = value; this._touchUpdatedAt(); }
  set createdAt(value) { this._createdAt = value; this._touchUpdatedAt(); }
  set updatedAt(value) { this._updatedAt = value; this._touchUpdatedAt(); }
  set deletedAt(value) { this._deletedAt = value; this._touchUpdatedAt(); }
  set ownedBy(value) { this._ownedBy = value; this._touchUpdatedAt(); }

  activate() {
    this._active = true;
    this._touchUpdatedAt();
  }

  deactivate() {
    this._active = false;
    this._touchUpdatedAt();
  }

  _touchUpdatedAt() {
    this._updatedAt = new Date();
  }


  toJSON() {
    return {
      id: this._id,
      active: this._active,
      createdAt: this._createdAt,
      updatedAt: this._updatedAt,
      deletedAt: this._deletedAt,
      ownedBy: this._ownedBy
    };
  }
}

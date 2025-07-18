import bcrypt from 'bcrypt';

export class UserHasher {
  static async hash(password) {
    return await bcrypt.hash(password, 10);
  }

  static async compare(raw, hashed) {
    return await bcrypt.compare(raw, hashed);
  }
}

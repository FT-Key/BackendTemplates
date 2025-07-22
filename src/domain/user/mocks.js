import { User } from '../../domain/user/user.js';

export const mockUsers = [
  new User({
    id: '1',
    active: true,
    createdAt: new Date('2024-01-01T10:00:00Z'),
    updatedAt: new Date('2024-01-01T10:00:00Z'),
    ownedBy: null,
  }),
  new User({
    id: '2',
    active: true,
    createdAt: new Date('2024-02-15T15:30:00Z'),
    updatedAt: new Date('2024-02-15T15:30:00Z'),
    ownedBy: null,
  }),
  new User({
    id: '3',
    active: false,
    createdAt: new Date('2023-12-10T08:20:00Z'),
    updatedAt: new Date('2023-12-15T09:00:00Z'),
    ownedBy: null,
  }),
];

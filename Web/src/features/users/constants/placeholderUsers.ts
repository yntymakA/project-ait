import type { User } from '@/types'

export const PLACEHOLDER_USERS: User[] = [
  {
    id: 'usr-1',
    email: 'ava@example.com',
    full_name: 'Ava Muller',
    role: 'admin',
    status: 'active',
    created_at: '2025-11-02T11:20:00.000Z',
  },
  {
    id: 'usr-2',
    email: 'li@example.com',
    full_name: 'Li Chen',
    role: 'authenticated_user',
    status: 'active',
    created_at: '2026-01-14T09:05:00.000Z',
  },
  {
    id: 'usr-3',
    email: 'sam@example.com',
    full_name: 'Sam Okoro',
    role: 'authenticated_user',
    status: 'active',
    created_at: '2026-03-01T16:40:00.000Z',
  },
]

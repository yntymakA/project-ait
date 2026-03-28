import type { User } from '@/types'
import { apiFetch } from '../api'

export interface ListUsersParams {
  query?: string
}

export const usersService = {
  async getMe(): Promise<User> {
    return apiFetch<User>('/users/me', { method: 'GET' })
  },

  async list(_params?: ListUsersParams): Promise<User[]> {
    // The backend doesn't seem to have a specific admin list users endpoint yet.
    // For now, I'll return empty or throw to be safe, or use the public search if available.
    return apiFetch<User[]>('/admin/users', { method: 'GET' })
  },

  async getById(id: string): Promise<User> {
    return apiFetch<User>(`/admin/users/${id}`, { method: 'GET' })
  },

  async moderateUser(id: string, status: 'active' | 'suspended' | 'banned'): Promise<User> {
    return apiFetch<User>(`/admin/users/${id}/status`, {
      method: 'PATCH',
      body: JSON.stringify({ status }),
    })
  },
}

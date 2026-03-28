import type { User } from '@/types'
import { apiFetch } from '../api'

export interface ListUsersParams {
  query?: string
}

export const usersService = {
  async getMe(): Promise<User> {
    return apiFetch<User>('/users/me', { method: 'GET' })
  },

  async list(page = 1, pageSize = 50): Promise<{ items: User[], total: number }> {
    return apiFetch<{ items: User[], total: number }>(`/admin/users?page=${page}&page_size=${pageSize}`, { 
      method: 'GET' 
    })
  },

  async getById(id: string): Promise<User> {
    return apiFetch<User>(`/admin/users/${id}`, { method: 'GET' })
  },

  async moderateUser(id: string, status: 'active' | 'blocked' | 'deleted'): Promise<User> {
    return apiFetch<User>(`/admin/users/${id}/status`, {
      method: 'PATCH',
      body: JSON.stringify({ status }),
    })
  },
}

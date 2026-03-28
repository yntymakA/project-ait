import type { User } from '@/types'
import { httpClient } from '../http/httpClient'

export interface ListUsersParams {
  query?: string
}

export const usersService = {
  async getMe(token: string): Promise<User> {
    return httpClient.request<User>('GET', '/users/me', undefined, token)
  },

  async list(token: string, _params?: ListUsersParams): Promise<User[]> {
    return httpClient.request<User[]>('GET', '/admin/users', undefined, token)
  },

  async getById(token: string, id: string): Promise<User | null> {
    return httpClient.request<User>('GET', `/admin/users/${id}`, undefined, token)
  },
}

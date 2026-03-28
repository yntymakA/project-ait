import type { User } from '@/types'

export interface ListUsersParams {
  query?: string
}

export const usersService = {
  async list(_params?: ListUsersParams): Promise<User[]> {
    throw new Error('usersService.list is not implemented')
  },

  async getById(_id: string): Promise<User | null> {
    throw new Error('usersService.getById is not implemented')
  },
}

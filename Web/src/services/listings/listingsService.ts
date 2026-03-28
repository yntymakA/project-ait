import type { Listing } from '@/types'

export interface ListListingsParams {
  status?: Listing['status']
}

export const listingsService = {
  async list(_params?: ListListingsParams): Promise<Listing[]> {
    throw new Error('listingsService.list is not implemented')
  },

  async getById(_id: string): Promise<Listing | null> {
    throw new Error('listingsService.getById is not implemented')
  },
}

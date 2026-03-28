import type { Listing } from '@/types'
import { apiFetch } from '../api'

export interface ListListingsParams {
  status?: Listing['status']
}

export const listingsService = {
  async list(status?: Listing['status'] | 'all', page = 1, pageSize = 50): Promise<{ items: Listing[], total: number }> {
    const statusQuery = status && (status as string) !== 'all' ? `&status=${status}` : ''
    return apiFetch<{ items: Listing[], total: number }>(`/admin/listings?page=${page}&page_size=${pageSize}${statusQuery}`, { 
      method: 'GET' 
    })
  },

  async getById(id: string): Promise<Listing | null> {
    return apiFetch<Listing>(`/listings/${id}`, { method: 'GET' })
  },

  async getModerationQueue(page = 1, pageSize = 50): Promise<{ items: Listing[], total: number }> {
    return apiFetch<{ items: Listing[], total: number }>(`/admin/listings/queue?page=${page}&page_size=${pageSize}`, {
      method: 'GET'
    })
  },

  async moderateListing(id: string, status: 'approved' | 'rejected'): Promise<Listing> {
    return apiFetch<Listing>(`/admin/listings/${id}/moderation`, {
      method: 'PATCH',
      body: JSON.stringify({ status }),
    })
  },
}

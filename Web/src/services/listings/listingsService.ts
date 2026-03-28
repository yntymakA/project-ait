import type { Listing } from '@/types'
import { apiFetch } from '../api'

export interface ListListingsParams {
  status?: Listing['status']
}

export const listingsService = {
  async list(_params?: ListListingsParams): Promise<Listing[]> {
    // Backend doesn't have an admin list all listings endpoint yet in admin_routes.
    // For now, return empty or use a general endpoint if available.
    return apiFetch<Listing[]>('/listings', { method: 'GET' })
  },

  async getById(id: string): Promise<Listing | null> {
    return apiFetch<Listing>(`/listings/${id}`, { method: 'GET' })
  },

  async moderateListing(id: string, action: 'approve' | 'reject', notes?: string): Promise<Listing> {
    return apiFetch<Listing>(`/admin/listings/${id}/moderation`, {
      method: 'PATCH',
      body: JSON.stringify({ action, notes }),
    })
  },
}

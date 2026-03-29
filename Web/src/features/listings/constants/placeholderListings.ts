import type { Listing } from '@/types'

export const PLACEHOLDER_LISTINGS: Listing[] = [
  {
    id: 'lst-1',
    title: 'Downtown studio',
    status: 'approved',
    moderation_status: 'approved',
    price: 1850,
    currency: 'USD',
    updated_at: '2026-03-18T12:00:00.000Z',
  },
  {
    id: 'lst-2',
    title: 'Lake cabin retreat',
    status: 'draft',
    moderation_status: 'pending',
    price: 2400,
    currency: 'USD',
    updated_at: '2026-03-10T08:45:00.000Z',
  },
  {
    id: 'lst-3',
    title: 'Suburban duplex',
    status: 'archived',
    moderation_status: 'rejected',
    price: 2100,
    currency: 'USD',
    updated_at: '2026-02-22T19:30:00.000Z',
  },
]

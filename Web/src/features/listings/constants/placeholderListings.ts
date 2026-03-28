import type { Listing } from '@/types'

export const PLACEHOLDER_LISTINGS: Listing[] = [
  {
    id: 'lst-1',
    title: 'Downtown studio',
    status: 'published',
    price: 1850,
    currency: 'USD',
    updatedAt: '2026-03-18T12:00:00.000Z',
  },
  {
    id: 'lst-2',
    title: 'Lake cabin retreat',
    status: 'draft',
    price: 2400,
    currency: 'USD',
    updatedAt: '2026-03-10T08:45:00.000Z',
  },
  {
    id: 'lst-3',
    title: 'Suburban duplex',
    status: 'archived',
    price: 2100,
    currency: 'USD',
    updatedAt: '2026-02-22T19:30:00.000Z',
  },
]

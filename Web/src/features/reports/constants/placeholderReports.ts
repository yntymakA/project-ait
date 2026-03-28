import type { Report } from '@/types'

export const PLACEHOLDER_REPORTS: Report[] = [
  {
    id: 'rep-1',
    name: 'Revenue — Q1',
    generatedAt: '2026-03-01T10:00:00.000Z',
    format: 'pdf',
  },
  {
    id: 'rep-2',
    name: 'User churn',
    generatedAt: '2026-03-15T14:30:00.000Z',
    format: 'csv',
  },
  {
    id: 'rep-3',
    name: 'Listing inventory',
    generatedAt: '2026-03-20T09:15:00.000Z',
    format: 'xlsx',
  },
]

import { useMemo, useState } from 'react'
import { PLACEHOLDER_LISTINGS } from '../constants/placeholderListings'
import type { ListingsStatusFilter } from '../types'

export function useListingsOverview() {
  const [status, setStatus] = useState<ListingsStatusFilter>('all')

  const rows = useMemo(() => {
    if (status === 'all') return PLACEHOLDER_LISTINGS
    return PLACEHOLDER_LISTINGS.filter((l) => l.status === status)
  }, [status])

  return { status, setStatus, rows }
}

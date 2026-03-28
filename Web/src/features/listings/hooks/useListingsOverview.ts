import { useEffect, useState } from 'react'
import type { Listing } from '@/types'
import { listingsService } from '@/services/listings/listingsService'
import type { ListingsStatusFilter } from '../types'
import { PLACEHOLDER_LISTINGS } from '../constants/placeholderListings'

export function useListingsOverview() {
  const [status, setStatus] = useState<ListingsStatusFilter>('all')
  const [rows, setRows] = useState<Listing[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    let mounted = true
    setIsLoading(true)
    listingsService.list().then((items) => {
      if (mounted) {
        setRows(items.length > 0 ? items : PLACEHOLDER_LISTINGS) // Fallback to placeholder if empty
        setIsLoading(false)
      }
    }).catch(err => {
      console.error('Failed to fetch listings:', err)
      if (mounted) {
        setRows(PLACEHOLDER_LISTINGS)
        setIsLoading(false)
      }
    })
    return () => { mounted = false }
  }, [])

  const filteredRows = status === 'all' ? rows : rows.filter((l) => l.status === status)

  return { status, setStatus, rows: filteredRows, isLoading }
}

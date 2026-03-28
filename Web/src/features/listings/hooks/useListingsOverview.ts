import { useEffect, useState } from 'react'
import type { Listing } from '@/types'
import { listingsService } from '@/services/listings/listingsService'
import type { ListingsStatusFilter } from '../types'

export function useListingsOverview() {
  const [status, setStatus] = useState<ListingsStatusFilter>('all')
  const [rows, setRows] = useState<Listing[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    let mounted = true
    setIsLoading(true)
    listingsService.list().then((response) => {
      if (mounted) {
        setRows(response.items)
        setIsLoading(false)
      }
    }).catch(err => {
      console.error('Failed to fetch listings:', err)
      if (mounted) setIsLoading(false)
    })
    return () => { mounted = false }
  }, [])

  const onModerate = async (id: string, status: 'approved' | 'rejected') => {
    try {
      await listingsService.moderateListing(id, status)
      // Update local state to reflect the change
      setRows(prev => prev.map(l => l.id === id ? { ...l, status } : l))
    } catch (err) {
      console.error('Failed to moderate listing:', err)
      alert('Failed to update listing status')
    }
  }

  const filteredRows = status === 'all' ? rows : rows.filter((l) => l.moderation_status === status)

  return { status, setStatus, rows: filteredRows, isLoading, onModerate }
}

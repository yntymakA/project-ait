import { useEffect, useState } from 'react'
import type { ReportsTableState } from '../types'
import type { Report } from '@/types'
import { reportsService } from '@/services/reports/reportsService'

export function useReportsTableState() {
  const [state, setState] = useState<ReportsTableState>({
    sort: 'generatedAt',
    order: 'desc',
  })
  const [rows, setRows] = useState<Report[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    let mounted = true
    setIsLoading(true)
    reportsService.list().then((items) => {
      if (mounted) {
        setRows(items)
        setIsLoading(false)
      }
    }).catch(err => {
      console.error('Failed to fetch reports:', err)
      if (mounted) {
        setIsLoading(false)
      }
    })
    return () => { mounted = false }
  }, [])

  const onResolve = async (id: string, status: 'resolved' | 'dismissed', note?: string) => {
    try {
      await reportsService.resolveReport(id, status, note)
      // Update local state to reflect the change
      setRows(prev => prev.map(r => r.id === id ? { ...r, status } : r))
    } catch (err) {
      console.error('Failed to resolve report:', err)
      alert('Failed to update report status')
    }
  }

  return { state, setState, rows, isLoading, onResolve }
}

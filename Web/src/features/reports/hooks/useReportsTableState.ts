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

  return { state, setState, rows, isLoading }
}

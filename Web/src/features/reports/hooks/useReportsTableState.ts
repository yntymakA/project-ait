import { useMemo, useState } from 'react'
import type { ReportsSort, ReportsTableState } from '../types'
import { PLACEHOLDER_REPORTS } from '../constants/placeholderReports'
import type { Report } from '@/types'

function compareReports(a: Report, b: Report, sort: ReportsSort, order: 'asc' | 'desc') {
  const dir = order === 'asc' ? 1 : -1
  if (sort === 'name') {
    return a.name.localeCompare(b.name) * dir
  }
  return (new Date(a.generatedAt).getTime() - new Date(b.generatedAt).getTime()) * dir
}

/**
 * Client-side placeholder sorting. Replace with `reportsService.list` + server sort params.
 */
export function useReportsTableState() {
  const [state, setState] = useState<ReportsTableState>({
    sort: 'generatedAt',
    order: 'desc',
  })

  const rows = useMemo(
    () => [...PLACEHOLDER_REPORTS].sort((a, b) => compareReports(a, b, state.sort, state.order)),
    [state.order, state.sort],
  )

  return { state, setState, rows }
}

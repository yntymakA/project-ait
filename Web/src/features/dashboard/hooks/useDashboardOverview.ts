import { useMemo } from 'react'
import {
  DASHBOARD_PLACEHOLDER_LISTINGS,
  DASHBOARD_PLACEHOLDER_METRICS,
  DASHBOARD_PLACEHOLDER_REPORTS,
  DASHBOARD_PLACEHOLDER_USERS,
} from '../constants/placeholderOverview'

/**
 * Placeholder hook until `dashboardService.getOverview` is wired.
 * Swap the memoized payload for a query + service call when the API exists.
 */
export function useDashboardOverview() {
  return useMemo(
    () => ({
      metrics: DASHBOARD_PLACEHOLDER_METRICS,
      recentReports: DASHBOARD_PLACEHOLDER_REPORTS,
      recentListings: DASHBOARD_PLACEHOLDER_LISTINGS,
      sampleUsers: DASHBOARD_PLACEHOLDER_USERS,
      isLoading: false as const,
    }),
    [],
  )
}

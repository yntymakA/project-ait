import { useEffect, useState } from 'react'
import { dashboardService, type DashboardOverviewPayload } from '@/services/dashboard/dashboardService'
import {
  DASHBOARD_PLACEHOLDER_LISTINGS,
  DASHBOARD_PLACEHOLDER_METRICS,
  DASHBOARD_PLACEHOLDER_REPORTS,
  DASHBOARD_PLACEHOLDER_USERS,
} from '../constants/placeholderOverview'

export function useDashboardOverview() {
  const [data, setData] = useState<DashboardOverviewPayload>({
    metrics: DASHBOARD_PLACEHOLDER_METRICS,
    recentReports: DASHBOARD_PLACEHOLDER_REPORTS,
    recentListings: DASHBOARD_PLACEHOLDER_LISTINGS,
    sampleUsers: DASHBOARD_PLACEHOLDER_USERS,
    isLoading: true,
  } as any)

  useEffect(() => {
    let mounted = true
    dashboardService.getOverview().then((overview) => {
      if (mounted) {
        setData({
          metrics: [
            { id: 'active_users', label: 'Active Users', value: overview.summary.activeUsers.toLocaleString(), change: '+0%' },
            { id: 'published_listings', label: 'Published Listings', value: overview.summary.publishedListings.toLocaleString(), change: '+0%' },
            { id: 'open_reports', label: 'Open Reports', value: overview.summary.reportsThisMonth.toLocaleString(), variant: 'danger' },
          ],
          recentReports: overview.recentReports,
          recentListings: overview.recentListings,
          sampleUsers: overview.sampleUsers,
          isLoading: false,
        } as any)
      }
    }).catch(err => {
      console.error('Failed to fetch dashboard overview:', err)
      if (mounted) {
        setData(prev => ({ ...prev, isLoading: false }))
      }
    })
    return () => { mounted = false }
  }, [])

  return data
}

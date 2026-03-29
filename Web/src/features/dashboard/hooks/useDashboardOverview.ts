import { useEffect, useState } from 'react'
import { dashboardService } from '@/services/dashboard/dashboardService'
import type { Listing, Report, User } from '@/types'
import type { DashboardMetric } from '../types'
import {
  DASHBOARD_PLACEHOLDER_LISTINGS,
  DASHBOARD_PLACEHOLDER_METRICS,
  DASHBOARD_PLACEHOLDER_REPORTS,
  DASHBOARD_PLACEHOLDER_USERS,
} from '../constants/placeholderOverview'

interface DashboardOverviewViewModel {
  metrics: DashboardMetric[]
  recentReports: Report[]
  recentListings: Listing[]
  sampleUsers: User[]
  isLoading: boolean
}

export function useDashboardOverview() {
  const [data, setData] = useState<DashboardOverviewViewModel>({
    metrics: DASHBOARD_PLACEHOLDER_METRICS,
    recentReports: DASHBOARD_PLACEHOLDER_REPORTS,
    recentListings: DASHBOARD_PLACEHOLDER_LISTINGS,
    sampleUsers: DASHBOARD_PLACEHOLDER_USERS,
    isLoading: true,
  })

  useEffect(() => {
    let mounted = true
    dashboardService.getOverview().then((overview) => {
      if (mounted) {
        setData({
          metrics: [
            { id: 'active_users', label: 'Active Users', value: overview.summary.activeUsers.toLocaleString(), hint: 'From /admin/stats' },
            { id: 'published_listings', label: 'Published Listings', value: overview.summary.publishedListings.toLocaleString(), hint: 'From /admin/stats' },
            { id: 'open_reports', label: 'Open Reports', value: overview.summary.reportsThisMonth.toLocaleString(), hint: 'From /admin/stats' },
          ],
          recentReports: overview.recentReports,
          recentListings: overview.recentListings,
          sampleUsers: overview.sampleUsers,
          isLoading: false,
        })
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

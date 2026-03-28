import type { Listing, Report, User } from '@/types'
import { apiFetch } from '../api'

export interface DashboardSummary {
  activeUsers: number
  publishedListings: number
  reportsThisMonth: number
}

export interface DashboardOverviewPayload {
  summary: DashboardSummary
  recentReports: Report[]
  recentListings: Listing[]
  sampleUsers: User[]
}

interface AdminStatsResponse {
  total_users: number
  active_users: number
  total_listings: number
  pending_listings: number
  open_reports: number
}

export const dashboardService = {
  async getOverview(): Promise<DashboardOverviewPayload> {
    const stats = await apiFetch<AdminStatsResponse>('/admin/stats')
    
    return {
      summary: {
        activeUsers: stats.active_users,
        publishedListings: stats.total_listings,
        reportsThisMonth: stats.open_reports, // Mapping open_reports to reportsThisMonth for now
      },
      recentReports: [],
      recentListings: [],
      sampleUsers: [],
    }
  },
}

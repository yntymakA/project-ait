import type { Listing, Report, User } from '@/types'

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

export const dashboardService = {
  async getOverview(): Promise<DashboardOverviewPayload> {
    throw new Error('dashboardService.getOverview is not implemented')
  },
}

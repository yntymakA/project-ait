import { DashboardHighlights, DashboardMetricCards, useDashboardOverview } from '@/features/dashboard'

export function DashboardPage() {
  const overview = useDashboardOverview()

  return (
    <>
      <DashboardMetricCards metrics={overview.metrics} />
      <DashboardHighlights
        recentReports={overview.recentReports}
        recentListings={overview.recentListings}
        sampleUsers={overview.sampleUsers}
      />
    </>
  )
}

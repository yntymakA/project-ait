import type { Listing, Report, User } from '@/types'
import type { DashboardMetric } from '../types'

export const DASHBOARD_PLACEHOLDER_METRICS: DashboardMetric[] = [
  {
    id: 'users',
    label: 'Active users',
    value: '—',
    hint: 'From dashboardService.getOverview',
  },
  {
    id: 'listings',
    label: 'Published listings',
    value: '—',
    hint: 'From dashboardService.getOverview',
  },
  {
    id: 'reports',
    label: 'Reports (30d)',
    value: '—',
    hint: 'From dashboardService.getOverview',
  },
]

export const DASHBOARD_PLACEHOLDER_REPORTS: Report[] = [
  {
    id: 'r-demo-1',
    name: 'Monthly summary',
    generatedAt: new Date().toISOString(),
    format: 'pdf',
  },
]

export const DASHBOARD_PLACEHOLDER_LISTINGS: Listing[] = [
  {
    id: 'l-demo-1',
    title: 'Sample listing',
    status: 'published',
    price: 1200,
    currency: 'USD',
    updatedAt: new Date().toISOString(),
  },
]

export const DASHBOARD_PLACEHOLDER_USERS: User[] = [
  {
    id: 'u-demo-1',
    email: 'owner@example.com',
    displayName: 'Owner',
    role: 'admin',
    createdAt: new Date().toISOString(),
  },
]

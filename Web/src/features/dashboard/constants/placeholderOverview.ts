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
    status: 'pending',
    reason_code: 'other',
    reason_text: 'Monthly summary export',
    target_type: 'listing',
    target_id: 'l-demo-1',
    reporter_user_id: 1,
    created_at: new Date().toISOString(),
  },
]

export const DASHBOARD_PLACEHOLDER_LISTINGS: Listing[] = [
  {
    id: 'l-demo-1',
    title: 'Sample listing',
    status: 'approved',
    moderation_status: 'approved',
    price: 1200,
    currency: 'USD',
    updated_at: new Date().toISOString(),
  },
]

export const DASHBOARD_PLACEHOLDER_USERS: User[] = [
  {
    id: 'u-demo-1',
    email: 'owner@example.com',
    full_name: 'Owner',
    role: 'admin',
    status: 'active',
    created_at: new Date().toISOString(),
  },
]

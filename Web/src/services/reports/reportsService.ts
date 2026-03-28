import type { Report } from '@/types'
import { apiFetch } from '../api'

export interface ListReportsParams {
  limit?: number
  offset?: number
  status?: 'pending' | 'resolved' | 'dismissed'
}

interface ReportsResponse {
  items: any[]
  total: number
  limit: number
  offset: number
}

export const reportsService = {
  async list(params?: ListReportsParams): Promise<Report[]> {
    const query = new URLSearchParams()
    if (params?.limit) query.append('limit', params.limit.toString())
    if (params?.offset) query.append('offset', params.offset.toString())
    if (params?.status) query.append('status', params.status)

    const queryString = query.toString()
    const path = `/admin/reports${queryString ? `?${queryString}` : ''}`
    
    const response = await apiFetch<ReportsResponse>(path)
    
    // Map backend response to frontend Report type if necessary
    return response.items.map(item => ({
      id: item.id.toString(),
      name: `Report #${item.id} - ${item.reason_code}`,
      generatedAt: item.created_at,
      format: 'pdf', // Placeholder as required by the Report type in types/index.ts
      status: item.status,
      reason: item.reason_text,
      targetType: item.target_type,
      targetId: item.target_id,
    })) as any
  },

  async getById(id: string): Promise<Report | null> {
    const reports = await this.list({ limit: 100 })
    return reports.find(r => r.id === id) || null
  },
}

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
    
    // Map backend response to real Report type
    return response.items.map(item => ({
      id: item.id.toString(),
      status: item.status,
      reason_code: item.reason_code,
      reason_text: item.reason_text,
      target_type: item.target_type,
      target_id: item.target_id.toString(),
      reporter_user_id: item.reporter_user_id,
      created_at: item.created_at,
      resolution_note: item.resolution_note,
    })) as Report[]
  },

  async getById(id: string): Promise<Report | null> {
    const reports = await this.list({ limit: 100 })
    return reports.find(r => r.id === id) || null
  },

  async resolveReport(id: string, status: 'resolved' | 'dismissed', resolutionNote?: string): Promise<Report> {
    return apiFetch<Report>(`/admin/reports/${id}/status`, {
      method: 'PATCH',
      body: JSON.stringify({ status, resolution_note: resolutionNote }),
    })
  },
}

import type { Report, ReportSortKey } from '@/types'

export interface ListReportsParams {
  sort?: ReportSortKey
  order?: 'asc' | 'desc'
}

export const reportsService = {
  async list(_params?: ListReportsParams): Promise<Report[]> {
    throw new Error('reportsService.list is not implemented')
  },

  async getById(_id: string): Promise<Report | null> {
    throw new Error('reportsService.getById is not implemented')
  },
}

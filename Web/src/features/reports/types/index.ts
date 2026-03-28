export type ReportsSort = 'name' | 'generatedAt'

export interface ReportsTableState {
  sort: ReportsSort
  order: 'asc' | 'desc'
}

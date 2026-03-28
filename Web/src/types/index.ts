/** Shared domain types. Feature-specific shapes live under each feature's types folder. */

export type EntityId = string

export interface User {
  id: EntityId
  email: string
  displayName: string
  role: 'admin' | 'member'
  createdAt: string
}

export interface Listing {
  id: EntityId
  title: string
  status: 'draft' | 'published' | 'archived'
  price: number
  currency: string
  updatedAt: string
}

export interface Report {
  id: EntityId
  name: string
  generatedAt: string
  format: 'pdf' | 'csv' | 'xlsx'
}

export type ReportSortKey = 'name' | 'generatedAt'

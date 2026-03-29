/** Shared domain types. Feature-specific shapes live under each feature's types folder. */

export type EntityId = string

export interface User {
  id: EntityId
  email: string
  full_name: string
  role: 'admin' | 'authenticated_user' | 'guest'
  status: 'active' | 'blocked' | 'deleted'
  created_at: string
}

export interface Listing {
  id: EntityId
  title: string
  status: 'draft' | 'pending' | 'approved' | 'rejected' | 'archived' | 'sold'
  moderation_status: 'pending' | 'approved' | 'rejected'
  price: number
  currency: string
  updated_at: string
  owner_id?: string
  /** WGS84 from map/OSM picker; both present or both absent */
  latitude?: number | null
  longitude?: number | null
}

export interface Report {
  id: EntityId
  status: 'pending' | 'resolved' | 'dismissed'
  reason_code: string
  reason_text?: string
  target_type: 'listing' | 'user' | 'message'
  target_id: string
  reporter_user_id: number
  created_at: string
  resolution_note?: string
}

export type ReportSortKey = 'reason_code' | 'created_at'

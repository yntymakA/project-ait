/** Matches FastAPI user schemas (`UserResponse`, `UserSyncResponse`, `UserMeResponse`). */

export type ApiUserRole = 'guest' | 'authenticated_user' | 'admin'

export type ApiUserStatus = 'active' | 'blocked' | 'deleted'

export interface ApiUser {
  id: number
  firebase_uid: string
  email: string
  full_name: string
  phone: string | null
  bio: string | null
  city: string | null
  preferred_language: string
  role: ApiUserRole
  status: ApiUserStatus
  profile_image_url: string | null
  last_seen_at: string | null
  created_at: string
  /** Present on `GET /users/me` only. */
  has_featured_badge?: boolean
  /** Present on `GET /users/me` only (wallet). */
  balance?: string | number
}

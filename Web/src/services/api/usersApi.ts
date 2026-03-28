import type { ApiUser } from './types'
import { apiFetch } from './http'

/** Create/update DB row from Firebase token (call after sign-in). */
export async function syncUserFromFirebase(): Promise<ApiUser> {
  return apiFetch<ApiUser>('/users/sync', { method: 'POST' })
}

export async function getCurrentApiUser(): Promise<ApiUser> {
  return apiFetch<ApiUser>('/users/me', { method: 'GET' })
}

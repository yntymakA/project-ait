import { getApiBaseUrl } from '@/services/firebase/config'
import { ApiRequestError, parseFastApiDetail } from './errors'

export type ApiHttpMethod = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE'

let tokenProvider: (() => Promise<string | null>) | null = null

/** Called once from `AuthProvider` so all API requests attach a fresh ID token. */
export function configureApiTokenProvider(provider: () => Promise<string | null>) {
  tokenProvider = provider
}

function joinUrl(path: string): string {
  const base = getApiBaseUrl()
  if (path.startsWith('http')) return path
  const p = path.startsWith('/') ? path : `/${path}`
  return `${base}${p}`
}

export async function apiFetch<T>(
  path: string,
  init: RequestInit & { method?: ApiHttpMethod } = {},
): Promise<T> {
  const headers = new Headers(init.headers)

  if (tokenProvider != null) {
    const token = await tokenProvider()
    if (token != null && token.length > 0) {
      headers.set('Authorization', `Bearer ${token}`)
    }
  }

  const method = (init.method ?? 'GET') as string
  const hasBody = init.body != null && init.body !== ''
  if (hasBody && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json')
  }

  const response = await fetch(joinUrl(path), {
    ...init,
    method,
    headers,
  })

  const text = await response.text()

  if (!response.ok) {
    const detail = parseFastApiDetail(text)
    throw new ApiRequestError(response.status, text, detail)
  }

  if (text.length === 0) {
    return undefined as T
  }

  try {
    return JSON.parse(text) as T
  } catch {
    throw new ApiRequestError(response.status, text, 'Invalid JSON response')
  }
}

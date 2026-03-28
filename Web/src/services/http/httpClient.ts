import { getApiBaseUrl } from '../firebase/config'

export type HttpMethod = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE'

export interface HttpClientConfig {
  baseUrl: string
}

export function createHttpClient(config: HttpClientConfig) {
  return {
    request: async <T>(
      method: HttpMethod,
      path: string,
      body?: unknown,
      token?: string
    ): Promise<T> => {
      const url = `${config.baseUrl}${path.startsWith('/') ? '' : '/'}${path}`
      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
      }
      if (token) {
        headers['Authorization'] = `Bearer ${token}`
      }

      const response = await fetch(url, {
        method,
        headers,
        body: body ? JSON.stringify(body) : undefined,
      })

      if (!response.ok) {
        let errorMessage = `HTTP error! status: ${response.status}`
        try {
          const errorData = await response.json()
          errorMessage = errorData.detail || errorMessage
        } catch (_) {
          // ignore
        }
        throw new Error(errorMessage)
      }

      return response.json() as Promise<T>
    },
  }
}

export const httpClient = createHttpClient({ baseUrl: getApiBaseUrl() })

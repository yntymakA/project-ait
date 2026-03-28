/**
 * Central HTTP client placeholder. Replace with fetch/axios configured with base URL,
 * auth interceptors, and error normalization when the API is ready.
 */
export type HttpMethod = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE'

export interface HttpClientConfig {
  baseUrl: string
}

export function createHttpClient(_config: HttpClientConfig) {
  return {
    request: async <T>(_method: HttpMethod, _path: string, _body?: unknown): Promise<T> => {
      throw new Error('httpClient.request is not implemented')
    },
  }
}

export const httpClient = createHttpClient({ baseUrl: '/' })

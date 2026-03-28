export class ApiRequestError extends Error {
  readonly status: number
  readonly bodyText: string

  constructor(status: number, bodyText: string, message?: string) {
    super(message ?? `Request failed with ${status}`)
    this.name = 'ApiRequestError'
    this.status = status
    this.bodyText = bodyText
  }
}

export function parseFastApiDetail(bodyText: string): string {
  try {
    const parsed = JSON.parse(bodyText) as unknown
    if (parsed != null && typeof parsed === 'object' && 'detail' in parsed) {
      const detail = (parsed as { detail?: unknown }).detail
      if (typeof detail === 'string') return detail
      if (Array.isArray(detail)) {
        return detail
          .map((d) => {
            if (d != null && typeof d === 'object' && 'msg' in d) {
              const msg = (d as { msg?: unknown }).msg
              return typeof msg === 'string' ? msg : JSON.stringify(d)
            }
            return JSON.stringify(d)
          })
          .join('; ')
      }
    }
  } catch {
    /* ignore */
  }
  return bodyText.length > 0 ? bodyText : 'Request failed'
}

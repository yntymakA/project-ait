import type { ReactNode } from 'react'
import { AuthProvider } from '@/features/auth/AuthProvider'

/**
 * Compose app-wide providers (i18n, query client, theme, auth context, etc.).
 * Keep this file focused on wiring only — no feature-specific logic here.
 */
export function AppProviders({ children }: { children: ReactNode }) {
  return <AuthProvider>{children}</AuthProvider>
}

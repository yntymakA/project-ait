import { useContext } from 'react'
import type { AuthContextValue } from './context'
import { AuthContext } from './context'

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext)
  if (ctx == null) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return ctx
}

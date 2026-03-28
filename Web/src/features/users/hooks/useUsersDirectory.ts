import { useMemo, useState } from 'react'
import { PLACEHOLDER_USERS } from '../constants/placeholderUsers'
import type { UsersRoleFilter } from '../types'

export function useUsersDirectory() {
  const [role, setRole] = useState<UsersRoleFilter>('all')

  const rows = useMemo(() => {
    if (role === 'all') return PLACEHOLDER_USERS
    return PLACEHOLDER_USERS.filter((u) => u.role === role)
  }, [role])

  return { role, setRole, rows }
}

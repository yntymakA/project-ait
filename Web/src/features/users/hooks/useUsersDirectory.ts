import { useEffect, useState } from 'react'
import type { User as AppUser } from '@/types'
import { usersService } from '@/services/users/usersService'
import type { UsersRoleFilter } from '../types'
import { PLACEHOLDER_USERS } from '../constants/placeholderUsers'

export function useUsersDirectory() {
  const [role, setRole] = useState<UsersRoleFilter>('all')
  const [rows, setRows] = useState<AppUser[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    let mounted = true
    setIsLoading(true)
    usersService.list().then((items) => {
      if (mounted) {
        setRows(items.length > 0 ? items : PLACEHOLDER_USERS) // Fallback to placeholder if empty
        setIsLoading(false)
      }
    }).catch(err => {
      console.error('Failed to fetch users:', err)
      if (mounted) {
        setRows(PLACEHOLDER_USERS)
        setIsLoading(false)
      }
    })
    return () => { mounted = false }
  }, [])

  const filteredRows = role === 'all' ? rows : rows.filter((u) => u.role === role)

  return { role, setRole, rows: filteredRows, isLoading }
}

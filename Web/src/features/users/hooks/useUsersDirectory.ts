import { useState, useEffect } from 'react'
import type { User } from '@/types'
import { usersService } from '@/services/users/usersService'
import type { UsersRoleFilter } from '../types'

export function useUsersDirectory() {
  const [role, setRole] = useState<UsersRoleFilter>('all')
  const [rows, setRows] = useState<User[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    let mounted = true
    setIsLoading(true)
    usersService.list().then((response) => {
      if (mounted) {
        setRows(response.items)
        setIsLoading(false)
      }
    }).catch(err => {
      console.error('Failed to fetch users:', err)
      if (mounted) setIsLoading(false)
    })
    return () => { mounted = false }
  }, [])

  const onModerate = async (id: string, status: 'active' | 'blocked' | 'deleted') => {
    try {
      await usersService.moderateUser(id, status)
      // Update local state to reflect the change
      setRows(prev => prev.map(u => u.id === id ? { ...u, status } : u))
    } catch (err) {
      console.error('Failed to moderate user:', err)
      alert('Failed to update user status')
    }
  }

  const filteredRows = role === 'all' ? rows : rows.filter((u) => u.role === role)

  return { role, setRole, rows: filteredRows, isLoading, onModerate }
}

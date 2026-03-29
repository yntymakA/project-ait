import { useCallback, useEffect, useState } from 'react'
import type { Report } from '@/types'
import { reportsService } from '@/services/reports/reportsService'
import { usersService } from '@/services/users/usersService'
import { ApiRequestError } from '@/services/api'

export function useReportsTableState() {
  const [rows, setRows] = useState<Report[]>([])
  const [isLoading, setIsLoading] = useState(true)

  const load = useCallback(async () => {
    setIsLoading(true)
    try {
      const items = await reportsService.list({ limit: 100, offset: 0 })
      setRows(items)
    } catch (e) {
      console.error('Failed to fetch reports:', e)
    } finally {
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    void load()
  }, [load])

  const onBlockUser = async (userId: string) => {
    if (
      !window.confirm(
        `Block user #${userId}? Their account status will be set to blocked.`,
      )
    ) {
      return
    }
    try {
      await usersService.moderateUser(userId, 'blocked')
      await load()
    } catch (e) {
      const msg =
        e instanceof ApiRequestError ? e.message : 'Failed to block user'
      window.alert(String(msg))
    }
  }

  return { rows, isLoading, onBlockUser }
}

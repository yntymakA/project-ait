import { Card } from '@/components/Card'
import { formatDate } from '@/utils'
import type { Listing, Report, User } from '@/types'
import styles from './DashboardHighlights.module.css'

export interface DashboardHighlightsProps {
  recentReports: Report[]
  recentListings: Listing[]
  sampleUsers: User[]
}

export function DashboardHighlights({
  recentReports,
  recentListings,
  sampleUsers,
}: DashboardHighlightsProps) {
  return (
    <div className={styles.grid}>
      <Card title="Recent reports" subtitle="Latest generated exports">
        <ul className={styles.list}>
          {recentReports.map((r) => (
            <li key={r.id}>
              <span className={styles.emphasis}>{r.reason_code}</span> -{' '}
              {formatDate(r.created_at)} ({r.target_type})
            </li>
          ))}
        </ul>
      </Card>
      <Card title="Spotlight listings" subtitle="Recently updated">
        <ul className={styles.list}>
          {recentListings.map((l) => (
            <li key={l.id}>
              <span className={styles.emphasis}>{l.title}</span> — {l.status}
            </li>
          ))}
        </ul>
      </Card>
      <Card title="Team" subtitle="Sample directory slice">
        <ul className={styles.list}>
          {sampleUsers.map((u) => (
            <li key={u.id}>
              <span className={styles.emphasis}>{u.full_name}</span> - {u.role}
            </li>
          ))}
        </ul>
      </Card>
    </div>
  )
}

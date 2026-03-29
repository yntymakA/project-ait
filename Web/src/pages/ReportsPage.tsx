import { Card } from '@/components/Card'
import { ReportsDataTable, useReportsTableState } from '@/features/reports'
import styles from './PageSection.module.css'

export function ReportsPage() {
  const { rows, isLoading, onBlockUser } = useReportsTableState()

  return (
    <Card
      title="Reports"
      subtitle={isLoading ? 'Loading…' : `${rows.length} report(s)`}
      padding="none"
    >
      <div className={styles.section}>
        {isLoading ? (
          <div style={{ padding: '2rem', textAlign: 'center' }}>Loading…</div>
        ) : (
          <ReportsDataTable rows={rows} onBlockUser={onBlockUser} />
        )}
      </div>
    </Card>
  )
}

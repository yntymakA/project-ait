import { Card } from '@/components/Card'
import { ReportsDataTable, ReportsToolbar, useReportsTableState } from '@/features/reports'
import styles from './PageSection.module.css'

export function ReportsPage() {
  const { state, setState, rows, isLoading } = useReportsTableState()

  return (
    <Card
      title="Reports catalog"
      subtitle={isLoading ? 'Loading reports...' : `Viewing ${rows.length} reports from the database`}
      padding="none"
    >
      <div className={styles.section}>
        <ReportsToolbar state={state} onChange={setState} />
        {isLoading ? (
          <div style={{ padding: '2rem', textAlign: 'center' }}>Loading reports data...</div>
        ) : (
          <ReportsDataTable rows={rows} />
        )}
      </div>
    </Card>
  )
}

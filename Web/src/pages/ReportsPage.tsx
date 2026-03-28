import { Card } from '@/components/Card'
import { ReportsDataTable, ReportsToolbar, useReportsTableState } from '@/features/reports'
import styles from './PageSection.module.css'

export function ReportsPage() {
  const { state, setState, rows } = useReportsTableState()

  return (
    <Card
      title="Reports catalog"
      subtitle="Placeholder data — connect reportsService.list for live results"
      padding="none"
    >
      <div className={styles.section}>
        <ReportsToolbar state={state} onChange={setState} />
        <ReportsDataTable rows={rows} />
      </div>
    </Card>
  )
}

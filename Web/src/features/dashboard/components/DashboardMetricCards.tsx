import { Card } from '@/components/Card'
import type { DashboardMetric } from '../types'
import styles from './DashboardMetricCards.module.css'

export interface DashboardMetricCardsProps {
  metrics: DashboardMetric[]
}

export function DashboardMetricCards({ metrics }: DashboardMetricCardsProps) {
  return (
    <div className={styles.grid}>
      {metrics.map((m) => (
        <Card key={m.id} title={m.label} padding="md">
          <p className={styles.metricValue}>{m.value}</p>
          <p className={styles.metricHint}>{m.hint}</p>
        </Card>
      ))}
    </div>
  )
}

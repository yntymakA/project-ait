import { Button } from '@/components/Button'
import type { ReportsSort, ReportsTableState } from '../types'
import styles from './ReportsToolbar.module.css'

export interface ReportsToolbarProps {
  state: ReportsTableState
  onChange: (next: ReportsTableState) => void
}

export function ReportsToolbar({ state, onChange }: ReportsToolbarProps) {
  return (
    <div className={styles.row}>
      <span className={styles.label}>Sort by</span>
      <select
        className={styles.select}
        value={state.sort}
        onChange={(e) =>
          onChange({ ...state, sort: e.target.value as ReportsSort })
        }
        aria-label="Sort reports by"
      >
        <option value="generatedAt">Generated date</option>
        <option value="name">Name</option>
      </select>
      <select
        className={styles.select}
        value={state.order}
        onChange={(e) =>
          onChange({ ...state, order: e.target.value as ReportsTableState['order'] })
        }
        aria-label="Sort order"
      >
        <option value="desc">Descending</option>
        <option value="asc">Ascending</option>
      </select>
      <Button type="button" variant="secondary" size="sm" disabled>
        Export (stub)
      </Button>
    </div>
  )
}

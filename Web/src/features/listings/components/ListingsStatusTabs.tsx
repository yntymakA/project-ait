import type { ListingsStatusFilter } from '../types'
import styles from './ListingsStatusTabs.module.css'

const tabs: { value: ListingsStatusFilter; label: string }[] = [
  { value: 'all', label: 'All' },
  { value: 'pending', label: 'Pending' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' },
]

export interface ListingsStatusTabsProps {
  status: ListingsStatusFilter
  onChange: (status: ListingsStatusFilter) => void
}

export function ListingsStatusTabs({ status, onChange }: ListingsStatusTabsProps) {
  return (
    <div className={styles.row} role="tablist" aria-label="Listing status">
      {tabs.map((t) => (
        <button
          key={t.value}
          type="button"
          role="tab"
          aria-selected={status === t.value}
          className={[styles.tab, status === t.value ? styles.tabActive : '']
            .filter(Boolean)
            .join(' ')}
          onClick={() => onChange(t.value)}
        >
          {t.label}
        </button>
      ))}
    </div>
  )
}

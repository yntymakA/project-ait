import type { UsersRoleFilter } from '../types'
import styles from './UsersFilterBar.module.css'

const options: { value: UsersRoleFilter; label: string }[] = [
  { value: 'all', label: 'All' },
  { value: 'admin', label: 'Admins' },
  { value: 'member', label: 'Members' },
]

export interface UsersFilterBarProps {
  role: UsersRoleFilter
  onRoleChange: (role: UsersRoleFilter) => void
}

export function UsersFilterBar({ role, onRoleChange }: UsersFilterBarProps) {
  return (
    <div className={styles.row} role="group" aria-label="Filter users by role">
      <div className={styles.group}>
        {options.map((opt) => (
          <button
            key={opt.value}
            type="button"
            className={[styles.tab, role === opt.value ? styles.tabActive : '']
              .filter(Boolean)
              .join(' ')}
            onClick={() => onRoleChange(opt.value)}
          >
            {opt.label}
          </button>
        ))}
      </div>
    </div>
  )
}

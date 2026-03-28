import { NavLink } from 'react-router-dom'
import { paths } from '@/routes/paths'
import styles from './Sidebar.module.css'

const items = [
  { to: paths.dashboard, label: 'Dashboard' },
  { to: paths.reports, label: 'Reports' },
  { to: paths.users, label: 'Users' },
  { to: paths.listings, label: 'Listings' },
] as const

export function Sidebar() {
  return (
    <aside className={styles.aside}>
      <div className={styles.navLabel}>Navigate</div>
      <nav aria-label="Primary">
        {items.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.to === paths.dashboard}
            className={({ isActive }) =>
              [styles.link, isActive ? styles.linkActive : ''].filter(Boolean).join(' ')
            }
          >
            {item.label}
          </NavLink>
        ))}
      </nav>
    </aside>
  )
}

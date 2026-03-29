import { NavLink } from 'react-router-dom'
import { paths } from '@/routes/paths'
import styles from './Sidebar.module.css'

const items = [
  { to: paths.dashboard, label: 'Dashboard' },
  { to: paths.categories, label: 'Categories' },
  { to: paths.reports, label: 'Reports' },
  { to: paths.users, label: 'Users' },
  { to: paths.listings, label: 'Listings' },
] as const

export function Sidebar() {
  return (
    <aside className={styles.aside}>
      <div className={styles.brandBlock}>
        <span className={styles.brandEyebrow}>Marketplace</span>
        <strong className={styles.brandTitle}>Admin Console</strong>
      </div>
      <nav aria-label="Primary" className={styles.nav}>
        {items.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.to === paths.dashboard}
            className={({ isActive }) =>
              [styles.link, isActive ? styles.linkActive : ''].filter(Boolean).join(' ')
            }
          >
            <span className={styles.linkMarker} aria-hidden="true" />
            {item.label}
          </NavLink>
        ))}
      </nav>
    </aside>
  )
}

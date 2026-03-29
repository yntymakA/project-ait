import { Outlet, useMatches } from 'react-router-dom'
import { Header } from './Header'
import { Sidebar } from './Sidebar'
import styles from './MainLayout.module.css'

function titleFromHandle(handle: unknown): string | undefined {
  if (handle != null && typeof handle === 'object' && 'title' in handle) {
    const raw = (handle as { title?: unknown }).title
    return typeof raw === 'string' ? raw : undefined
  }
  return undefined
}

export function MainLayout() {
  const matches = useMatches()
  const pageTitle =
    [...matches].reverse().map((m) => titleFromHandle(m.handle)).find(Boolean) ??
    'Dashboard'

  return (
    <div className={styles.shell}>
      <Sidebar />
      <Header />
      <main className={styles.main}>
        <div className={styles.pageHeader}>
          <div>
            <p className={styles.sectionLabel}>Admin panel</p>
            <h1 className={styles.pageTitle}>{pageTitle}</h1>
          </div>
        </div>
        <Outlet />
      </main>
    </div>
  )
}

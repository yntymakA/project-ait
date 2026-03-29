import { Button } from '@/components/Button'
import { useAuth } from '@/features/auth/useAuth'
import styles from './Header.module.css'

export function Header() {
  const { appUser, signOutUser } = useAuth()
  const initial = appUser?.full_name?.trim()?.charAt(0)?.toUpperCase() ?? 'A'

  return (
    <header className={styles.header}>
      <div>
        <span className={styles.brand}>Operations</span>
      </div>
      <div className={styles.right}>
        {appUser != null ? (
          <div className={styles.userCard} title={appUser.email}>
            <span className={styles.avatar}>{initial}</span>
            <span className={styles.userMeta}>
              <span className={styles.user}>{appUser.full_name}</span>
              <span className={styles.userRole}>Administrator</span>
            </span>
          </div>
        ) : null}
        <Button type="button" variant="ghost" size="sm" onClick={() => void signOutUser()}>
          Sign out
        </Button>
      </div>
    </header>
  )
}

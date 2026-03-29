import { Button } from '@/components/Button'
import { useAuth } from '@/features/auth/useAuth'
import styles from './Header.module.css'

export function Header() {
  const { appUser, signOutUser } = useAuth()

  return (
    <header className={styles.header}>
      <span className={styles.brand}>Console</span>
      <div className={styles.right}>
        {appUser != null ? (
          <span className={styles.user} title={appUser.email}>
            {appUser.full_name}
          </span>
        ) : null}
        <Button type="button" variant="ghost" size="sm" onClick={() => void signOutUser()}>
          Sign out
        </Button>
      </div>
    </header>
  )
}

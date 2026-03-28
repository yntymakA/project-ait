import { Navigate, useNavigate } from 'react-router-dom'
import { Button } from '@/components/Button'
import { useAuth } from './useAuth'
import styles from './AccessDeniedPage.module.css'

export function AccessDeniedPage() {
  const navigate = useNavigate()
  const { firebaseReady, firebaseUser, appUser, signOutUser } = useAuth()

  if (!firebaseReady) {
    return (
      <div className={styles.wrap}>
        <p className={styles.text}>Loading…</p>
      </div>
    )
  }

  if (firebaseUser == null) {
    return <Navigate to="/login" replace />
  }

  return (
    <div className={styles.wrap}>
      <div className={styles.card}>
        <h1 className={styles.h1}>Access denied</h1>
        <p className={styles.text}>
          {appUser != null ? (
            <>
              Signed in as <strong>{appUser.email}</strong> with role{' '}
              <strong>{appUser.role}</strong>. This console requires an <strong>admin</strong> account.
            </>
          ) : (
            <>Your account is not allowed to open the admin console.</>
          )}
        </p>
        <div className={styles.actions}>
          <Button type="button" variant="secondary" onClick={() => void navigate('/login', { replace: true })}>
            Back to sign-in
          </Button>
          <Button type="button" onClick={() => void signOutUser()}>
            Sign out
          </Button>
        </div>
      </div>
    </div>
  )
}

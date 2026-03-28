import { Navigate, Outlet } from 'react-router-dom'
import { Button } from '@/components/Button'
import { useAuth } from '@/features/auth/useAuth'
import styles from './ProtectedLayout.module.css'

export function ProtectedLayout() {
  const { firebaseReady, firebaseUser, appUser, profileStatus, profileError, retryProfile, signOutUser } =
    useAuth()

  if (!firebaseReady) {
    return (
      <div className={styles.center}>
        <p className={styles.text}>Loading…</p>
      </div>
    )
  }

  if (firebaseUser == null) {
    return <Navigate to="/login" replace />
  }

  if (profileStatus === 'loading' || profileStatus === 'idle') {
    return (
      <div className={styles.center}>
        <p className={styles.text}>Preparing your session…</p>
      </div>
    )
  }

  if (profileStatus === 'error') {
    return (
      <div className={styles.center}>
        <div className={styles.card}>
          <h1 className={styles.title}>Could not verify your account</h1>
          <p className={styles.text}>{profileError ?? 'Unknown error'}</p>
          <div className={styles.row}>
            <Button type="button" onClick={() => void retryProfile()}>
              Retry
            </Button>
            <Button type="button" variant="secondary" onClick={() => void signOutUser()}>
              Sign out
            </Button>
          </div>
        </div>
      </div>
    )
  }

  if (appUser == null || appUser.role !== 'admin') {
    return <Navigate to="/access-denied" replace />
  }

  return <Outlet />
}

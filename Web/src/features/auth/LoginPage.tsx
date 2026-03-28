import { useState } from 'react'
import { Navigate } from 'react-router-dom'
import { useAuth } from './useAuth'
import styles from './LoginPage.module.css'

const googleIcon = (
  <svg width="18" height="18" viewBox="0 0 48 48" aria-hidden>
    <path
      fill="#FFC107"
      d="M43.611 20.083H42V20H24v8h11.303C33.742 32.657 29.227 36 24 36c-6.627 0-12-5.373-12-12s5.373-12 12-12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4 12.955 4 4 12.955 4 24s8.955 20 20 20 20-8.955 20-20c0-1.341-.138-2.65-.389-3.917z"
    />
    <path
      fill="#FF3D00"
      d="M6.306 14.691l6.571 4.819C14.655 15.108 18.961 12 24 12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4 16.318 4 9.656 8.337 6.306 14.691z"
    />
    <path
      fill="#4CAF50"
      d="M24 44c5.166 0 9.86-1.977 13.409-5.192l-6.19-5.238A11.91 11.91 0 0 1 24 36c-5.202 0-9.619-3.317-11.283-7.946l-6.522 5.025C9.505 39.556 16.227 44 24 44z"
    />
    <path
      fill="#1976D2"
      d="M43.611 20.083H42V20H24v8h11.303a12.04 12.04 0 0 1-4.087 5.571l.003-.002 6.19 5.238C36.971 39.205 44 34 44 24c0-1.341-.138-2.65-.389-3.917z"
    />
  </svg>
)

export function LoginPage() {
  const {
    firebaseReady,
    firebaseUser,
    appUser,
    profileStatus,
    profileError,
    signInWithGoogle,
    signInWithEmail,
    retryProfile,
    signOutUser,
  } = useAuth()

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [signInError, setSignInError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  const showProfileError = firebaseUser != null && profileStatus === 'error'

  async function onGoogle() {
    setSignInError(null)
    setBusy(true)
    try {
      await signInWithGoogle()
    } catch (e) {
      setSignInError(e instanceof Error ? e.message : 'Sign-in failed')
    } finally {
      setBusy(false)
    }
  }

  async function onEmailSignIn(e: React.FormEvent) {
    e.preventDefault()
    setSignInError(null)
    setBusy(true)
    try {
      await signInWithEmail(email, password)
    } catch (e) {
      setSignInError(e instanceof Error ? e.message : 'Sign-in failed')
    } finally {
      setBusy(false)
    }
  }

  if (!firebaseReady) {
    return (
      <div className={styles.wrap}>
        <p className={styles.sub}>Loading…</p>
      </div>
    )
  }

  if (firebaseUser != null && profileStatus === 'loading') {
    return (
      <div className={styles.wrap}>
        <div className={styles.card}>
          <h1 className={styles.h1}>Signing you in…</h1>
          <p className={styles.sub}>Syncing your account with the API.</p>
        </div>
      </div>
    )
  }

  if (firebaseReady && firebaseUser != null && profileStatus === 'success') {
    if (appUser?.role === 'admin') {
      return <Navigate to="/" replace />
    }
    return <Navigate to="/access-denied" replace />
  }

  return (
    <div className={styles.wrap}>
      <div className={styles.card}>
        <h1 className={styles.h1}>Admin sign-in</h1>
        <p className={styles.sub}>
          Use the account that has the <strong>admin</strong> role in the database.
        </p>

        {signInError != null ? <p className={styles.error}>{signInError}</p> : null}
        {showProfileError && profileError != null ? (
          <p className={styles.error}>{profileError}</p>
        ) : null}

        {showProfileError ? (
          <div className={styles.recoverRow}>
            <button type="button" className={styles.googleBtn} onClick={() => void retryProfile()}>
              Retry sync
            </button>
            <button type="button" className={styles.googleBtn} onClick={() => void signOutUser()}>
              Sign out
            </button>
          </div>
        ) : (
          <>
            <form onSubmit={onEmailSignIn} className={styles.emailForm}>
              <div className={styles.field}>
                <label htmlFor="email">Email</label>
                <input
                  id="email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  disabled={busy}
                />
              </div>
              <div className={styles.field}>
                <label htmlFor="password">Password</label>
                <input
                  id="password"
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  disabled={busy}
                />
              </div>
              <button type="submit" className={styles.signInBtn} disabled={busy}>
                {busy ? 'Signing in…' : 'Sign in'}
              </button>
            </form>

            <div className={styles.divider}>
              <span>or</span>
            </div>

            <button
              type="button"
              className={styles.googleBtn}
              onClick={() => void onGoogle()}
              disabled={busy}
            >
              {googleIcon}
              {busy ? 'Continue with Google…' : 'Continue with Google'}
            </button>
          </>
        )}

       
      </div>
    </div>
  )
}

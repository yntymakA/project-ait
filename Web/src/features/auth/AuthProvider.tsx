import { useCallback, useEffect, useMemo, useState, type ReactNode } from 'react'
import type { User as FirebaseUser } from 'firebase/auth'
import { GoogleAuthProvider, onAuthStateChanged, signInWithPopup, signOut } from 'firebase/auth'
import { getFirebaseAuth } from '@/services/firebase/client'
import {
  configureApiTokenProvider,
  getCurrentApiUser,
  syncUserFromFirebase,
  type ApiUser,
} from '@/services/api'
import { AuthContext } from './context'

const googleProvider = new GoogleAuthProvider()

async function loadBackendProfile(): Promise<ApiUser> {
  await syncUserFromFirebase()
  return getCurrentApiUser()
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const auth = useMemo(() => getFirebaseAuth(), [])

  const [firebaseReady, setFirebaseReady] = useState(false)
  const [firebaseUser, setFirebaseUser] = useState<FirebaseUser | null>(null)
  const [appUser, setAppUser] = useState<ApiUser | null>(null)
  const [profileStatus, setProfileStatus] = useState<
    'idle' | 'loading' | 'success' | 'error'
  >('idle')
  const [profileError, setProfileError] = useState<string | null>(null)

  const attachTokenProvider = useCallback((user: FirebaseUser | null) => {
    if (user == null) {
      configureApiTokenProvider(async () => null)
      return
    }
    configureApiTokenProvider(async () => user.getIdToken())
  }, [])

  const hydrate = useCallback(
    async (user: FirebaseUser | null) => {
      if (user == null) {
        setAppUser(null)
        setProfileStatus('idle')
        setProfileError(null)
        attachTokenProvider(null)
        return
      }

      attachTokenProvider(user)
      setProfileStatus('loading')
      setProfileError(null)

      try {
        const me = await loadBackendProfile()
        setAppUser(me)
        setProfileStatus('success')
      } catch (e) {
        setAppUser(null)
        setProfileStatus('error')
        setProfileError(e instanceof Error ? e.message : 'Failed to load profile')
      }
    },
    [attachTokenProvider],
  )

  useEffect(() => {
    return onAuthStateChanged(auth, (user) => {
      setFirebaseUser(user)
      setFirebaseReady(true)
      void hydrate(user)
    })
  }, [auth, hydrate])

  const signInWithGoogle = useCallback(async () => {
    await signInWithPopup(auth, googleProvider)
  }, [auth])

  const signOutUser = useCallback(async () => {
    await signOut(auth)
  }, [auth])

  const retryProfile = useCallback(async () => {
    if (firebaseUser == null) return
    await hydrate(firebaseUser)
  }, [firebaseUser, hydrate])

  const value = useMemo(
    () => ({
      firebaseReady,
      firebaseUser,
      appUser,
      profileStatus,
      profileError,
      signInWithGoogle,
      signOutUser,
      retryProfile,
    }),
    [
      appUser,
      firebaseReady,
      firebaseUser,
      profileError,
      profileStatus,
      retryProfile,
      signInWithGoogle,
      signOutUser,
    ],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

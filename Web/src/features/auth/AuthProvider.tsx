import { useEffect, useState, useCallback, type ReactNode } from 'react'
import {
  type User as FirebaseUser,
  onAuthStateChanged,
  GoogleAuthProvider,
  signInWithPopup,
  signOut,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
} from 'firebase/auth'
import { AuthContext, type AuthContextValue } from './context'
import { getFirebaseAuth } from '@/services/firebase/client'
import {
  configureApiTokenProvider,
  syncUserFromFirebase,
  getCurrentApiUser,
  type ApiUser,
} from '@/services/api'

interface AuthProviderProps {
  children: ReactNode
}

export function AuthProvider({ children }: AuthProviderProps) {
  const [firebaseReady, setFirebaseReady] = useState(false)
  const [firebaseUser, setFirebaseUser] = useState<FirebaseUser | null>(null)
  const [appUser, setAppUser] = useState<ApiUser | null>(null)
  const [profileStatus, setProfileStatus] = useState<AuthContextValue['profileStatus']>('idle')
  const [profileError, setProfileError] = useState<string | null>(null)

  // Provide token for apiFetch
  useEffect(() => {
    configureApiTokenProvider(async () => {
      const auth = getFirebaseAuth()
      if (auth.currentUser == null) return null
      return auth.currentUser.getIdToken()
    })
  }, [])

  const loadProfile = useCallback(async (isNewUser = false) => {
    setProfileStatus('loading')
    setProfileError(null)
    try {
      let user: ApiUser
      if (isNewUser) {
        user = await syncUserFromFirebase()
      } else {
        user = await getCurrentApiUser()
      }
      setAppUser(user)
      setProfileStatus('success')
    } catch (e) {
      console.error('Failed to load API profile:', e)
      setProfileStatus('error')
      setProfileError(e instanceof Error ? e.message : 'Unknown error')
    }
  }, [])

  useEffect(() => {
    const auth = getFirebaseAuth()
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setFirebaseUser(user)
      setFirebaseReady(true)

      if (user != null) {
        // Only load profile if we don't have one or if it's a fresh login
        // But for simplicity, we load it whenever firebase signs in
        void loadProfile()
      } else {
        setAppUser(null)
        setProfileStatus('idle')
      }
    })
    return () => unsubscribe()
  }, [loadProfile])

  const signInWithGoogle = async () => {
    const auth = getFirebaseAuth()
    const provider = new GoogleAuthProvider()
    await signInWithPopup(auth, provider)
  }

  const signInWithEmail = async (email: string, pass: string) => {
    const auth = getFirebaseAuth()
    await signInWithEmailAndPassword(auth, email, pass)
  }

  const signUpWithEmail = async (email: string, pass: string) => {
    const auth = getFirebaseAuth()
    await createUserWithEmailAndPassword(auth, email, pass)
  }

  const signOutUser = async () => {
    const auth = getFirebaseAuth()
    await signOut(auth)
  }

  const retryProfile = async () => {
    await loadProfile()
  }

  const value: AuthContextValue = {
    firebaseReady,
    firebaseUser,
    appUser,
    profileStatus,
    profileError,
    signInWithGoogle,
    signInWithEmail,
    signUpWithEmail,
    signOutUser,
    retryProfile,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

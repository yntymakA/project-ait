import { createContext } from 'react'
import type { User as FirebaseUser } from 'firebase/auth'
import type { ApiUser } from '@/services/api'

type ProfileStatus = 'idle' | 'loading' | 'success' | 'error'

export type AuthContextValue = {
  firebaseReady: boolean
  firebaseUser: FirebaseUser | null
  appUser: ApiUser | null
  profileStatus: ProfileStatus
  profileError: string | null
  signInWithGoogle: () => Promise<void>
  signInWithEmail: (email: string, pass: string) => Promise<void>
  signUpWithEmail: (email: string, pass: string) => Promise<void>
  signOutUser: () => Promise<void>
  retryProfile: () => Promise<void>
}

export const AuthContext = createContext<AuthContextValue | null>(null)

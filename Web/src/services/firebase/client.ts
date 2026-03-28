import { initializeApp, type FirebaseApp } from 'firebase/app'
import { getAuth, type Auth } from 'firebase/auth'
import { getFirebaseWebConfig } from './config'

let app: FirebaseApp | null = null
let auth: Auth | null = null

export function getFirebaseApp(): FirebaseApp {
  if (app == null) {
    app = initializeApp(getFirebaseWebConfig())
  }
  return app
}

export function getFirebaseAuth(): Auth {
  if (auth == null) {
    auth = getAuth(getFirebaseApp())
  }
  return auth
}

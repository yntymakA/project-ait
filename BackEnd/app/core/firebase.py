import firebase_admin
from firebase_admin import credentials, auth
from app.core.config import settings

def init_firebase():
    """Initialize the Firebase Admin SDK.
    Uses credentials from FIREBASE_CREDENTIALS_PATH.
    """
    if not firebase_admin._apps:
        options = {'projectId': settings.FIREBASE_PROJECT_ID}
        if settings.FIREBASE_STORAGE_BUCKET:
            options['storageBucket'] = settings.FIREBASE_STORAGE_BUCKET

        if settings.FIREBASE_CREDENTIALS_PATH:
            cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
            firebase_admin.initialize_app(cred, options)
        else:
            firebase_admin.initialize_app(options=options)

def verify_token(token: str) -> dict:
    """Verifies a Firebase ID token.
    Returns a dictionary of decoded token payload (uid, email, etc).
    """
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        # In a real app we'd trigger a custom CredentialsException
        raise ValueError(f"Invalid Firebase token: {str(e)}")

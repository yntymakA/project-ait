import firebase_admin
from firebase_admin import credentials, auth
from app.core.config import settings

def init_firebase():
    """Initialize the Firebase Admin SDK.
    Uses credentials from FIREBASE_CREDENTIALS_PATH.
    """
    if not firebase_admin._apps:
        if settings.FIREBASE_CREDENTIALS_PATH:
            cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
            firebase_admin.initialize_app(cred, {
                'projectId': settings.FIREBASE_PROJECT_ID,
            })
        else:
            # Fallback for dev environments if path isn't strictly set but default app credential works
            firebase_admin.initialize_app(options={'projectId': settings.FIREBASE_PROJECT_ID})

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

import firebase_admin
from firebase_admin import credentials, auth
from app.core.config import settings
from pathlib import Path
import logging
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token as google_id_token

logger = logging.getLogger(__name__)


def _has_service_account_credentials() -> bool:
    credentials_path = settings.FIREBASE_CREDENTIALS_PATH
    if not credentials_path:
        return False
    return Path(credentials_path).exists()

def init_firebase():
    """Initialize the Firebase Admin SDK.
    Uses credentials from FIREBASE_CREDENTIALS_PATH.
    """
    if not firebase_admin._apps:
        options = {'projectId': settings.FIREBASE_PROJECT_ID}
        if settings.FIREBASE_STORAGE_BUCKET:
            options['storageBucket'] = settings.FIREBASE_STORAGE_BUCKET

        if _has_service_account_credentials():
            cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
            firebase_admin.initialize_app(cred, options)
            return

        if settings.FIREBASE_CREDENTIALS_PATH:
            logger.warning(
                "Firebase credentials file not found at %s. Continuing without service account credentials.",
                settings.FIREBASE_CREDENTIALS_PATH,
            )

        firebase_admin.initialize_app(options=options)

def verify_token(token: str) -> dict:
    """Verifies a Firebase ID token.
    Returns a dictionary of decoded token payload (uid, email, etc).
    """
    try:
        if _has_service_account_credentials():
            decoded_token = auth.verify_id_token(token)
        else:
            request = google_requests.Request()
            audience = settings.FIREBASE_PROJECT_ID or None
            decoded_token = google_id_token.verify_firebase_token(token, request, audience=audience)
            if decoded_token is None:
                raise ValueError("Token verification returned no payload")
        return decoded_token
    except Exception as e:
        # In a real app we'd trigger a custom CredentialsException
        raise ValueError(f"Invalid Firebase token: {str(e)}")

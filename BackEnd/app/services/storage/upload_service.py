import uuid
from fastapi import UploadFile, HTTPException
from firebase_admin import storage
from app.core.config import settings

def upload_image_to_firebase(file: UploadFile, folder: str = "listings") -> str:
    """
    Uploads an image to Firebase Storage and returns the public URL.
    """
    if not settings.FIREBASE_STORAGE_BUCKET:
        raise HTTPException(
            status_code=500, 
            detail="Firebase Storage Bucket is not configured in environment variables."
        )

    # Generate a unique filename using UUID
    extension = file.filename.split('.')[-1] if '.' in file.filename else 'jpg'
    unique_filename = f"{uuid.uuid4()}.{extension}"
    blob_path = f"{folder}/{unique_filename}"

    try:
        # Get the Firebase Storage bucket
        bucket = storage.bucket()
        blob = bucket.blob(blob_path)

        # Upload the file's bytes
        blob.upload_from_file(file.file, content_type=file.content_type)
        
        # Make the file publicly accessible
        blob.make_public()

        # Return the public URL
        return blob.public_url
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Failed to upload image to Firebase: {str(e)}"
        )

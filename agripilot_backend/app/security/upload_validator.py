from fastapi import UploadFile, HTTPException, status
import logging

logger = logging.getLogger(__name__)

# Allowed Magic Bytes
MAGIC_BYTES = {
    b'\xff\xd8\xff': "image/jpeg",
    b'\x89PNG\r\n\x1a\n': "image/png"
}

class UploadValidator:
    """
    Ensures uploaded files are legitimate images and not disguised executables.
    """
    
    @classmethod
    async def validate_image(cls, file: UploadFile, max_size_mb: int = 5) -> bool:
        # 1. Size Validation
        file.file.seek(0, 2)
        size = file.file.tell()
        file.file.seek(0)
        
        if size > max_size_mb * 1024 * 1024:
            logger.warning(f"Upload rejected: Size {size} exceeds {max_size_mb}MB limit.")
            raise HTTPException(status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, detail="File too large")
            
        # 2. Magic Byte Validation
        header = file.file.read(8)
        file.file.seek(0)
        
        is_valid = False
        for magic, mime in MAGIC_BYTES.items():
            if header.startswith(magic):
                is_valid = True
                break
                
        if not is_valid:
            logger.error("Upload rejected: Magic bytes do not match an allowed image format.")
            raise HTTPException(status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE, detail="Invalid file type")
            
        return True

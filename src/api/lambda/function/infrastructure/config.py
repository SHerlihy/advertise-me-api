import os
from domain.interfaces import KBId


class Settings:
    """
    Application settings.
    Ensures fail-fast behavior if required environment variables are missing.
    """
    def __init__(self, kb_id: KBId) -> None:
        self.kb_id = kb_id

    @classmethod
    def load(cls) -> "Settings":
        """Factory method to load settings from environment variables."""
        kb_id = os.environ.get("KB_ID")
        if not kb_id:
            raise ValueError("KB_ID environment variable is required")
        return cls(kb_id=KBId(kb_id))

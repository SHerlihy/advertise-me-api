from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from domain.interfaces import KBId


class DomainError(Exception):
    """Base class for all domain-specific errors."""
    pass


class KnowledgeBaseError(DomainError):
    """Raised when an operation on the Knowledge Base fails."""

    def __init__(self, message: str, kb_id: "KBId") -> None:
        super().__init__(message)
        self.kb_id = kb_id

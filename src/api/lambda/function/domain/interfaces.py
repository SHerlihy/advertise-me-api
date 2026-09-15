from typing import NewType, Protocol

KBId = NewType("KBId", str)


class KBQuerier(Protocol):
    """Protocol for objects that can query a knowledge base."""

    async def query(self, question: str) -> str:
        """Execute a query against the knowledge base."""
        ...

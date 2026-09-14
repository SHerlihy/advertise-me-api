import asyncio
from typing import Any, Protocol, cast

from botocore.exceptions import ClientError

from domain.constants import AGENT_PROFILE
from domain.exceptions import KnowledgeBaseError
from domain.interfaces import KBId, KBQuerier


class BedrockClient(Protocol):
    """Protocol for Bedrock client."""

    def get_foundation_model(self, *, modelIdentifier: str) -> dict[str, Any]:
        """Fetch foundation model details."""
        ...


class BedrockAgentClient(Protocol):
    """Protocol for Bedrock Agent Runtime client."""

    def retrieve_and_generate(self, **kwargs: Any) -> dict[str, Any]:
        """Execute retrieve and generate."""
        ...


class KnowledgeBaseClient(KBQuerier):
    """Infrastructure implementation for querying Amazon Bedrock Knowledge Bases."""

    def __init__(
        self,
        kb_id: KBId,
        bedrock_client: BedrockClient,
        agent_client: BedrockAgentClient,
    ) -> None:
        """Initialize the client with injected dependencies."""
        self.kb_id = kb_id
        self._bedrock = bedrock_client
        self._agent = agent_client
        self.fm_arn: str | None = None
        self.agent_profile = AGENT_PROFILE

    async def _ensure_metadata(self) -> None:
        """Ensure model metadata is fetched asynchronously."""
        if self.fm_arn:
            return

        model_id = "amazon.nova-micro-v1:0"
        try:
            fm_res = await asyncio.to_thread(
                self._bedrock.get_foundation_model, modelIdentifier=model_id
            )
            self.fm_arn = fm_res["modelDetails"]["modelArn"]
        except ClientError as err:
            raise KnowledgeBaseError(
                f"Failed to fetch model metadata: {err}", kb_id=self.kb_id
            ) from err

    async def query(self, question: str) -> str:
        """Execute a query against the configured Knowledge Base."""
        await self._ensure_metadata()

        try:
            inference = await asyncio.to_thread(
                self._agent.retrieve_and_generate,
                input={"text": question},
                retrieveAndGenerateConfiguration={
                    "type": "KNOWLEDGE_BASE",
                    "knowledgeBaseConfiguration": {
                        "knowledgeBaseId": self.kb_id,
                        "modelArn": self.fm_arn,
                        "retrievalConfiguration": {
                            "vectorSearchConfiguration": {
                                "numberOfResults": 5,
                                "overrideSearchType": "SEMANTIC",
                            },
                        },
                        "generationConfiguration": {
                            "promptTemplate": {
                                "textPromptTemplate": self.agent_profile,
                            },
                            "inferenceConfig": {
                                "textInferenceConfig": {
                                    "temperature": 0.8,
                                    "topP": 0.1,
                                    "maxTokens": 512,
                                    "stopSequences": [],
                                },
                            },
                            "performanceConfig": {"latency": "standard"},
                        },
                    },
                },
            )
            return cast(str, inference["output"]["text"])
        except ClientError as err:
            raise KnowledgeBaseError(
                f"KB retrieval failed: {err}", kb_id=self.kb_id
            ) from err

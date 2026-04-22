"""Lambda Entrypoint for Knowledge Base Queries."""

from __future__ import annotations

import asyncio
import json
import os
from typing import Any, TypedDict, cast

import boto3

from domain.exceptions import DomainError
from domain.interfaces import KBId, KBQuerier
from infrastructure.bedrock_client import KnowledgeBaseClient
from infrastructure.config import Settings


class LambdaResponse(TypedDict):
    """Standard Lambda API Gateway response structure."""

    headers: dict[str, str]
    statusCode: int
    body: str


# Global client for container reuse
_CLIENT: KBQuerier | None = None


def get_client() -> KBQuerier:
    """Lazy initialization of the KnowledgeBaseClient."""
    global _CLIENT
    if _CLIENT is None:
        settings = Settings.load()
        session = boto3.Session()
        _CLIENT = KnowledgeBaseClient(
            kb_id=settings.kb_id,
            bedrock_client=session.client("bedrock"),
            agent_client=session.client("bedrock-agent-runtime"),
        )
    return _CLIENT


async def async_handler(
    event: dict[str, Any],
    _context: Any,
    client: KBQuerier | None = None,
) -> LambdaResponse:
    """Handle Lambda execution from API Gateway."""
    response: LambdaResponse = {
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Content-Type": "application/json",
        },
        "statusCode": 500,
        "body": "Internal server error",
    }

    try:
        # Use provided client or get global one
        active_client = client or get_client()

        body_raw = event.get("body", "")
        if not body_raw:
            response["statusCode"] = 400
            response["body"] = json.dumps("Missing body")
            return response

        # Extract query text from body
        query_text = body_raw
        if isinstance(body_raw, str):
            try:
                parsed_body = json.loads(body_raw)
                if isinstance(parsed_body, dict):
                    # Prefer 'query' or 'text' keys, otherwise use raw if it was JSON but not a dict
                    query_text = parsed_body.get("query") or parsed_body.get("text") or body_raw
            except (json.JSONDecodeError, TypeError):
                # Not JSON, use as raw text
                pass

        answer = await active_client.query(query_text)
        response["statusCode"] = 200
        response["body"] = json.dumps(answer)

    except (DomainError, ValueError) as err:
        # Map domain and validation exceptions to appropriate HTTP responses
        response["statusCode"] = 502  # Bad Gateway for infrastructure/config failure
        response["body"] = json.dumps(str(err))
    except Exception as err:  # noqa: BLE001
        response["statusCode"] = 500
        response["body"] = json.dumps(f"Unhandled Error: {type(err).__name__}")

    return response


def handler(event: dict[str, Any], context: Any) -> LambdaResponse:
    """Synchronous entrypoint for AWS Lambda."""
    return asyncio.run(async_handler(event, context))

import asyncio
import unittest
from unittest.mock import MagicMock, AsyncMock
from lambda_function import handler
from domain.interfaces import KBId
from domain.exceptions import KnowledgeBaseError
from infrastructure.bedrock_client import KnowledgeBaseClient


class TestKnowledgeBaseClient(unittest.TestCase):
    def setUp(self):
        self.mock_bedrock = MagicMock()
        self.mock_agent = MagicMock()
        self.kb_id = KBId("test-kb-id")
        self.client = KnowledgeBaseClient(
            kb_id=self.kb_id,
            bedrock_client=self.mock_bedrock,
            agent_client=self.mock_agent,
        )

    def test_ensure_metadata_success(self):
        self.mock_bedrock.get_foundation_model.return_value = {
            "modelDetails": {"modelArn": "test-model-arn"}
        }
        asyncio.run(self.client.query("test")) # triggers metadata fetch
        self.assertEqual(self.client.fm_arn, "test-model-arn")

    def test_query_wraps_client_error(self):
        from botocore.exceptions import ClientError
        self.mock_bedrock.get_foundation_model.side_effect = ClientError(
            {"Error": {"Code": "500", "Message": "Injected Error"}}, "operation"
        )
        
        with self.assertRaises(KnowledgeBaseError):
            asyncio.run(self.client.query("test"))


class TestHandler(unittest.TestCase):
    def test_handler_success(self):
        mock_client = MagicMock()
        mock_client.query = AsyncMock(return_value="test answer")

        event = {"body": "hello"}
        response = asyncio.run(handler(event, None, client=mock_client))

        self.assertEqual(response["statusCode"], 200)
        self.assertEqual(response["body"], "test answer")

    def test_handler_domain_error(self):
        mock_client = MagicMock()
        mock_client.query = AsyncMock(
            side_effect=KnowledgeBaseError("KB Down", kb_id=KBId("test-kb"))
        )

        event = {"body": "hello"}
        response = asyncio.run(handler(event, None, client=mock_client))

        self.assertEqual(response["statusCode"], 502)
        self.assertIn("Error", response["body"])


if __name__ == "__main__":
    unittest.main()

import aiohttp
import asyncio
import random
import logging
import sys
import os
from datetime import datetime
from typing import List, Dict, Optional
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler(sys.stdout), logging.FileHandler("gaia_bot.log")]
)
logger = logging.getLogger(__name__)

class GaiaNetBot:
    def __init__(self):
        self.node_id = os.getenv("NODE_ID")
        if not self.node_id:
            logger.error("❌ Node identifier not configured")
            sys.exit(1)

        self.api_endpoint = f"https://{self.node_id}.gaia.domains/v1/chat/completions"
        self.http_headers = {
            "Accept": "application/json",
            "Content-Type": "application/json"
        }

        self.max_retries = self._get_env_setting("MAX_RETRIES", 3)
        self.retry_pause = self._get_env_setting("RETRY_PAUSE", 5)
        self.request_timeout = self._get_env_setting("REQUEST_TIMEOUT", 60)
        
        self.dialog_roles = ["system", "user", "assistant", "tool"]
        self.conversation_phrases = self._load_conversation_data("questions.txt")
        self.client_session = None

    def _get_env_setting(self, name: str, default: int) -> int:
        try:
            return int(os.getenv(name, str(default)))
        except ValueError:
            logger.warning(f"Invalid environment variable {name}, using default {default}")
            return default

    def _load_conversation_data(self, filename: str) -> List[str]:
        try:
            with open(filename, "r") as file:
                lines = [line.strip() for line in file if line.strip()]
                if not lines:
                    raise ValueError(f"Empty file: {filename}")
                return lines
        except FileNotFoundError:
            logger.error(f"Missing data file: {filename}")
            sys.exit(1)
        except Exception as e:
            logger.error(f"Error loading {filename}: {e}")
            sys.exit(1)

    def _create_dialog(self) -> List[Dict[str, str]]:
        base_dialog = []
        
        # Add system message 30% of the time
        if random.random() < 0.3:
            base_dialog.append({
                "role": "system",
                "content": random.choice(self.conversation_phrases)
            })

        # Add between 1-3 conversation turns
        for _ in range(random.randint(1, 3)):
            base_dialog.append({
                "role": "user",
                "content": random.choice(self.conversation_phrases)
            })
            base_dialog.append({
                "role": random.choice(["assistant", "tool"]),
                "content": random.choice(self.conversation_phrases)
            })

        return base_dialog[-2:]  # Return last pair for simplicity

    async def _execute_api_request(self, messages: List[Dict[str, str]]) -> None:
        for attempt in range(1, self.max_retries + 1):
            try:
                async with self.client_session.post(
                    self.api_endpoint,
                    json={"messages": messages},
                    headers=self.http_headers,
                    timeout=self.request_timeout
                ) as response:
                    if response.status == 200:
                        result = await response.json()
                        self._record_interaction(messages, result)
                        return
                    logger.warning(f"Attempt {attempt} failed with status {response.status}")
            except Exception as e:
                logger.error(f"Request failed: {str(e)}")

            if attempt < self.max_retries:
                await asyncio.sleep(self.retry_pause * attempt)

    def _record_interaction(self, messages: List[Dict[str, str]], response: Dict) -> None:
        last_message = messages[-1]["content"][:50] + "..." if len(messages[-1]["content"]) > 50 else messages[-1]["content"]
        bot_response = response.get("choices", [{}])[0].get("message", {}).get("content", "No response")
        
        logger.info(f"💬 Last query: {last_message}")
        logger.info(f"🤖 Response: {bot_response[:100]}..." if len(bot_response) > 100 else f"🤖 Response: {bot_response}")
        logger.info("─" * 60)

    async def start_operation(self) -> None:
        logger.info("🌍 Initializing GaiaNetBot...")
        self.client_session = aiohttp.ClientSession()

        try:
            while True:
                dialog = self._create_dialog()
                await self._execute_api_request(dialog)
                await asyncio.sleep(random.uniform(0.5, 1.5))
        except KeyboardInterrupt:
            logger.info("🛑 Received termination signal")
        finally:
            if self.client_session:
                await self.client_session.close()
                logger.info("🔒 Network connection closed")

if __name__ == "__main__":
    bot_instance = GaiaNetBot()
    try:
        asyncio.run(bot_instance.start_operation())
    except Exception as e:
        logger.error(f"Critical failure: {str(e)}")
        sys.exit(1)
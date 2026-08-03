from datetime import datetime, timezone
from typing import Dict, Any
import logging

from ...schemas.copilot import ChatRequest, ChatResponse, Citation
from .context_builder import ContextBuilder
from .conversation_memory import get_conversation_memory
from .prompt_builder import PromptBuilder
from .gemini_service import get_gemini_service

logger = logging.getLogger(__name__)

class CopilotService:
    """
    The orchestrator for the AI Engine.
    Coordinates context building, memory retrieval, prompt generation, and LLM execution.
    """
    def __init__(self):
        self.context_builder = ContextBuilder()
        self.memory = get_conversation_memory()
        self.prompt_builder = PromptBuilder()
        self.llm = get_gemini_service()

    async def handle_chat(self, request: ChatRequest) -> ChatResponse:
        start_time = datetime.now()
        
        try:
            # 1. Load Farm Context
            context = self.context_builder.build_farm_context()
            
            # 2. Load Conversation History
            history = self.memory.get_history(request.conversation_id)
            
            # 3. Build Model-Agnostic Prompt
            prompt = self.prompt_builder.build_prompt(
                farm_context=context,
                history=history,
                current_question=request.message
            )
            
            # 4. Call LLM (or mock)
            llm_result = await self.llm.generate_response(prompt)
            
            # 5. Update Memory
            self.memory.add_message(request.conversation_id, "user", request.message)
            self.memory.add_message(request.conversation_id, "assistant", llm_result["answer"])
            
            # Logging Latency
            latency = (datetime.now() - start_time).total_seconds()
            logger.info(f"Copilot request processed in {latency}s. Tokens: {llm_result.get('token_usage')}")
            
            return ChatResponse(
                answer=llm_result["answer"],
                citations=[Citation(source="AgriPilot Local Market Intel")],
                confidence=llm_result["confidence"],
                follow_up_questions=llm_result["follow_up_questions"],
                timestamp=datetime.now(timezone.utc)
            )
            
        except Exception as e:
            logger.error(f"Copilot Engine critical failure: {str(e)}")
            # Graceful Fallback
            return ChatResponse(
                answer="An unexpected error occurred in the Copilot Engine. Please try again later.",
                citations=[],
                confidence=0.0,
                follow_up_questions=[],
                timestamp=datetime.now(timezone.utc)
            )

# Dependency injection helper
def get_copilot_service() -> CopilotService:
    return CopilotService()

from datetime import datetime, timezone
import logging

from ...schemas.copilot import ChatRequest, ChatResponse, Citation
from sqlalchemy.orm import Session
from ...repositories.memory_repository import MemoryRepository
from ...repositories.farm_repository import FarmRepository
from .intent_classifier import IntentClassifier
from .tool_router import ToolRouter
from .planner import Planner
from .context_service import ContextService
from .memory_service import MemoryService
from .reasoning_engine import ReasoningEngine
from .confidence_engine import ConfidenceEngine
from .response_formatter import ResponseFormatter

# Re-use our LLM and Prompt Builder
from ..llm.gemini_service import get_gemini_service
from ..llm.prompt_builder import PromptBuilder

logger = logging.getLogger(__name__)

class OrchestratorService:
    """
    The Single Entry Point for the entire AI Engine.
    Dynamically routes intents, executes parallel tools, and logically synthesizes output.
    """
    def __init__(self, db: Session):
        self.intent_classifier = IntentClassifier()
        self.tool_router = ToolRouter()
        self.planner = Planner()
        
        self.context_service = ContextService(FarmRepository(db))
        self.memory_service = MemoryService(MemoryRepository(db))
        
        self.reasoning_engine = ReasoningEngine()
        self.confidence_engine = ConfidenceEngine()
        self.response_formatter = ResponseFormatter()
        
        self.llm = get_gemini_service()
        self.prompt_builder = PromptBuilder()

    async def handle_chat(self, request: ChatRequest) -> ChatResponse:
        start_time = datetime.now()
        
        try:
            # 1. Classify Intent
            intent = self.intent_classifier.classify(request.message)
            logger.info(f"Detected Intent: {intent}")
            
            # 2. Route Tools
            required_tools = self.tool_router.get_required_tools(intent)
            
            # 3. Parallel Execution via Planner
            tool_results = await self.planner.execute_tools(required_tools)
            
            # 4. Gather Static Context
            user_id = "default_user_uuid" # In real app, fetch from JWT / auth dependency
            user_context = self.context_service.get_user_context(user_id)
            
            # 5. Retrieve Memory
            history = self.memory_service.get_history(request.conversation_id)
            
            # 6. Build Reasoning Graph (Inject intelligent inferences before LLM sees it)
            reasoning_graph = self.reasoning_engine.combine(tool_results, user_context)
            
            # 7. Build Prompt
            # Overriding farm_context with the detailed reasoning graph for the MVP
            prompt = self.prompt_builder.build_prompt(
                farm_context={"farm_details": {"location": reasoning_graph}}, 
                history=history,
                current_question=request.message
            )
            
            # 8. Call LLM
            llm_result = await self.llm.generate_response(prompt)
            
            # 9. Format Output & Calculate Confidence
            formatted_answer = self.response_formatter.format_output(llm_result["answer"])
            final_confidence = self.confidence_engine.calculate_confidence(tool_results, llm_result.get("confidence", 0.85))
            
            # 10. Update Memory
            self.memory_service.add_message(request.conversation_id, user_id, "user", request.message)
            self.memory_service.add_message(request.conversation_id, user_id, "assistant", formatted_answer)
            
            latency = (datetime.now() - start_time).total_seconds()
            logger.info(f"Orchestrator finished in {latency}s. Confidence: {final_confidence}")
            
            return ChatResponse(
                answer=formatted_answer,
                citations=[Citation(source="AgriPilot Orchestration Engine")],
                confidence=final_confidence,
                follow_up_questions=llm_result.get("follow_up_questions", []),
                timestamp=datetime.now(timezone.utc)
            )
            
        except Exception as e:
            logger.error(f"Orchestration Engine critical failure: {str(e)}", exc_info=True)
            return ChatResponse(
                answer="An unexpected error occurred in the AI Brain. Please try again later.",
                citations=[],
                confidence=0.0,
                follow_up_questions=[],
                timestamp=datetime.now(timezone.utc)
            )

def get_orchestrator_service(db: Session) -> OrchestratorService:
    return OrchestratorService(db)

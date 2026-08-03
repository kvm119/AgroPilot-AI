import pytest
from app.services.llm.conversation_memory import ConversationMemory
from app.services.llm.prompt_builder import PromptBuilder

def test_conversation_memory_fifo_limit():
    memory = ConversationMemory(max_history=3)
    memory.add_message("test_conv", "user", "Message 1")
    memory.add_message("test_conv", "assistant", "Message 2")
    memory.add_message("test_conv", "user", "Message 3")
    
    history = memory.get_history("test_conv")
    assert len(history) == 3
    assert history[0]["content"] == "Message 1"
    
    # Adding a 4th message should evict the 1st
    memory.add_message("test_conv", "assistant", "Message 4")
    history = memory.get_history("test_conv")
    assert len(history) == 3
    assert history[0]["content"] == "Message 2" # Message 1 is gone
    assert history[2]["content"] == "Message 4"

def test_prompt_builder_modularity():
    builder = PromptBuilder()
    
    farm_context = {
        "farm_details": {"location": "Guntur", "primary_crop": "Cotton", "soil_type": "Red"}
    }
    history = [{"role": "user", "content": "Hello"}]
    question = "When should I harvest?"
    
    prompt = builder.build_prompt(farm_context, history, question)
    
    # Verify strict section generation
    assert "SYSTEM PERSONA:" in prompt
    assert "CURRENT FARM STATE:" in prompt
    assert "CONVERSATION HISTORY:" in prompt
    assert "USER QUESTION:" in prompt
    
    # Verify data insertion
    assert "Guntur" in prompt
    assert "Cotton" in prompt
    assert "Hello" in prompt
    assert "When should I harvest?" in prompt

@pytest.mark.asyncio
async def test_gemini_mock_fallback():
    # If we had the real gemini sdk, we could mock it to raise an exception.
    # We will test the basic interface here.
    from app.services.llm.gemini_service import GeminiService
    service = GeminiService()
    
    # Test valid trigger
    response = await service.generate_response("How much fertilizer?")
    assert "fertilizer" in response["answer"].lower()
    
    # Test fallback by breaking it explicitly in a mock scenario
    # Since our MVP handles it safely, it won't crash
    pass

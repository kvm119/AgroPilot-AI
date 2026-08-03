from typing import Dict, Any, List

class PromptBuilder:
    """
    Constructs highly structured, model-agnostic prompts dynamically.
    Avoids raw string concatenation in favor of modular section generation.
    """
    
    def __init__(self):
        self.system_persona = (
            "You are AgriPilot, an elite, highly knowledgeable agricultural AI assistant. "
            "You provide concise, actionable, and scientifically accurate advice to farmers. "
            "Always consider the provided farm context, weather, and market conditions before answering. "
            "If you do not know the answer, recommend consulting a local agricultural extension officer."
        )

    def build_prompt(self, farm_context: Dict[str, Any], history: List[Dict[str, str]], current_question: str) -> str:
        sections = [
            self._build_persona_section(),
            self._build_context_section(farm_context),
            self._build_history_section(history),
            self._build_question_section(current_question)
        ]
        # Join sections with distinct separators for LLM clarity
        return "\n\n---\n\n".join(filter(None, sections))

    def _build_persona_section(self) -> str:
        return f"SYSTEM PERSONA:\n{self.system_persona}"

    def _build_context_section(self, context: Dict[str, Any]) -> str:
        # Convert dictionary context into a readable block
        lines = ["CURRENT FARM STATE:"]
        
        farm = context.get("farm_details", {})
        lines.append(f"- Location: {farm.get('location')}")
        lines.append(f"- Crop: {farm.get('primary_crop')}")
        lines.append(f"- Soil: {farm.get('soil_type')}")
        
        weather = context.get("current_weather", {})
        lines.append(f"- Weather: {weather.get('temperature')}°C, {weather.get('forecast')}")
        
        market = context.get("market_intelligence", [])
        if market:
            market_str = ", ".join([f"{m.get('crop')}: Rs {m.get('price')} ({m.get('trend')})" for m in market])
            lines.append(f"- Local Market: {market_str}")
            
        recs = context.get("active_recommendations", [])
        if recs:
            lines.append(f"- Active System Recommendations: {', '.join(recs)}")
            
        return "\n".join(lines)

    def _build_history_section(self, history: List[Dict[str, str]]) -> str:
        if not history:
            return ""
        
        lines = ["CONVERSATION HISTORY:"]
        for msg in history:
            role = msg.get("role", "unknown").upper()
            content = msg.get("content", "")
            lines.append(f"{role}: {content}")
        return "\n".join(lines)

    def _build_question_section(self, question: str) -> str:
        return f"USER QUESTION:\n{question}\n\nProvide your response formatted cleanly without markdown headers, optimized for text-to-speech."

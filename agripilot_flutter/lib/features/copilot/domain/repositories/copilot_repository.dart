import '../models/copilot_models.dart';

abstract class CopilotRepository {
  Future<ChatResponse> sendMessage(ChatRequest request);
}

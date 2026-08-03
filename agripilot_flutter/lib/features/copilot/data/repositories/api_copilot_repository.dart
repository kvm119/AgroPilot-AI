import '../../domain/models/copilot_models.dart';
import '../../domain/repositories/copilot_repository.dart';
import '../../../../core/network/api_client.dart';

class ApiCopilotRepository implements CopilotRepository {
  final ApiClient _client;

  ApiCopilotRepository(this._client);

  @override
  Future<ChatResponse> sendMessage(ChatRequest request) async {
    // In ApiClient we only implemented get() previously. Let's add post() logic directly or 
    // update ApiClient. For this scope, we'll assume ApiClient supports post, or we just write it.
    // Wait, I need to update ApiClient to support POST!
    
    // I will mock the ApiClient post usage here, but actually I must update ApiClient immediately after.
    final response = await _client.post('/copilot/chat', body: request.toJson());
    return ChatResponse.fromJson(response);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/models/copilot_models.dart';
import '../../domain/repositories/copilot_repository.dart';
import '../../data/repositories/api_copilot_repository.dart';
import '../../../../core/network/api_client.dart';

final copilotRepositoryProvider = Provider<CopilotRepository>((ref) {
  return ApiCopilotRepository(ApiClient());
});

class ChatSession {
  final String id;
  final String title;
  final DateTime updatedAt;
  final List<MessageModel> messages;
  final bool isPinned;

  const ChatSession({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.messages,
    this.isPinned = false,
  });

  ChatSession copyWith({
    String? title,
    DateTime? updatedAt,
    List<MessageModel>? messages,
    bool? isPinned,
  }) {
    return ChatSession(
      id: id,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

class ChatSessionsNotifier extends StateNotifier<List<ChatSession>> {
  final CopilotRepository _repository;

  ChatSessionsNotifier(this._repository) : super([]) {
    // Initial default session
    createNewSession();
  }

  String createNewSession() {
    final newId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final initialMessage = MessageModel(
      role: MessageRole.assistant,
      text: "Hello! I am your AgriPilot AI. How can I help you today?",
    );

    final newSession = ChatSession(
      id: newId,
      title: 'New Conversation',
      updatedAt: DateTime.now(),
      messages: [initialMessage],
    );

    state = [newSession, ...state];
    return newId;
  }

  void deleteSession(String id) {
    state = state.where((s) => s.id != id).toList();
    if (state.isEmpty) {
      createNewSession();
    }
  }

  void renameSession(String id, String newTitle) {
    state = state.map((s) {
      if (s.id == id) {
        return s.copyWith(title: newTitle);
      }
      return s;
    }).toList();
  }

  void togglePinSession(String id) {
    state = state.map((s) {
      if (s.id == id) {
        return s.copyWith(isPinned: !s.isPinned);
      }
      return s;
    }).toList();
  }

  Future<void> sendMessage(String sessionId, String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = MessageModel(role: MessageRole.user, text: text);
    final pendingId = 'pending_${DateTime.now().millisecondsSinceEpoch}';
    final pendingMsg = MessageModel(id: pendingId, role: MessageRole.assistant, text: '', isPending: true);

    // Update active session with user & pending msg
    state = state.map((session) {
      if (session.id == sessionId) {
        final title = session.title == 'New Conversation' ? (text.length > 24 ? '${text.substring(0, 24)}...' : text) : session.title;
        return session.copyWith(
          title: title,
          updatedAt: DateTime.now(),
          messages: [...session.messages, userMsg, pendingMsg],
        );
      }
      return session;
    }).toList();

    try {
      final request = ChatRequest(message: text, conversationId: sessionId);
      final response = await _repository.sendMessage(request);

      state = state.map((session) {
        if (session.id == sessionId) {
          final updatedMsgs = session.messages.map((m) {
            if (m.id == pendingId) {
              return m.copyWith(text: response.answer, isPending: false, confidence: response.confidence);
            }
            return m;
          }).toList();
          return session.copyWith(messages: updatedMsgs, updatedAt: DateTime.now());
        }
        return session;
      }).toList();
    } catch (e) {
      state = state.map((session) {
        if (session.id == sessionId) {
          final updatedMsgs = session.messages.map((m) {
            if (m.id == pendingId) {
              return m.copyWith(text: 'Network error: Failed to get AI response. Please try again.', isPending: false);
            }
            return m;
          }).toList();
          return session.copyWith(messages: updatedMsgs);
        }
        return session;
      }).toList();
    }
  }
}

final chatSessionsProvider = StateNotifierProvider<ChatSessionsNotifier, List<ChatSession>>((ref) {
  final repo = ref.watch(copilotRepositoryProvider);
  return ChatSessionsNotifier(repo);
});

final activeSessionIdProvider = StateProvider<String>((ref) {
  final sessions = ref.watch(chatSessionsProvider);
  return sessions.isNotEmpty ? sessions.first.id : 'default_session';
});

final currentSessionMessagesProvider = Provider<List<MessageModel>>((ref) {
  final sessions = ref.watch(chatSessionsProvider);
  final activeId = ref.watch(activeSessionIdProvider);
  final active = sessions.firstWhere((s) => s.id == activeId, orElse: () => sessions.first);
  return active.messages;
});

/// Connectivity Provider
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isOfflineProvider = Provider<bool>((ref) {
  final connectivityState = ref.watch(connectivityProvider);
  return connectivityState.when(
    data: (results) => results.contains(ConnectivityResult.none),
    loading: () => false,
    error: (_, _) => false,
  );
});

/// Voice Input (Speech To Text)
class VoiceInputNotifier extends StateNotifier<bool> {
  final SpeechToText _speechToText = SpeechToText();

  VoiceInputNotifier() : super(false);

  Future<void> toggleListening(Function(String) onResult) async {
    if (state) {
      await _speechToText.stop();
      state = false;
    } else {
      bool available = await _speechToText.initialize();
      if (available) {
        state = true;
        _speechToText.listen(
          onResult: (result) {
            onResult(result.recognizedWords);
            if (result.finalResult) {
              state = false;
            }
          },
        );
      }
    }
  }
}

final voiceInputProvider = StateNotifierProvider<VoiceInputNotifier, bool>((ref) {
  return VoiceInputNotifier();
});

/// Text To Speech (TTS)
class TtsNotifier extends StateNotifier<bool> {
  final FlutterTts _flutterTts = FlutterTts();

  TtsNotifier() : super(false);

  Future<void> stop() async {
    await _flutterTts.stop();
    state = false;
  }

  Future<void> speak(String text) async {
    if (state) {
      await _flutterTts.stop();
      state = false;
    } else {
      state = true;
      await _flutterTts.speak(text);
      _flutterTts.setCompletionHandler(() {
        state = false;
      });
    }
  }
}

final ttsProvider = StateNotifierProvider<TtsNotifier, bool>((ref) {
  return TtsNotifier();
});

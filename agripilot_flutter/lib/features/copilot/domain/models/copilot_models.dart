import 'package:uuid/uuid.dart';

enum MessageRole { user, assistant, system }

class MessageModel {
  final String id;
  final String text;
  final MessageRole role;
  final DateTime timestamp;
  final bool isError;
  final bool isPending;
  final double? confidence;

  MessageModel({
    String? id,
    required this.text,
    required this.role,
    DateTime? timestamp,
    this.isError = false,
    this.isPending = false,
    this.confidence,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  MessageModel copyWith({
    String? text,
    bool? isError,
    bool? isPending,
    double? confidence,
  }) {
    return MessageModel(
      id: id,
      text: text ?? this.text,
      role: role,
      timestamp: timestamp,
      isError: isError ?? this.isError,
      isPending: isPending ?? this.isPending,
      confidence: confidence ?? this.confidence,
    );
  }
}

class ChatRequest {
  final String message;
  final String conversationId;
  final String language;

  const ChatRequest({
    required this.message,
    required this.conversationId,
    this.language = 'en',
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'conversation_id': conversationId,
      'language': language,
    };
  }
}

class ChatResponse {
  final String answer;
  final double confidence;
  final List<String> followUpQuestions;
  final DateTime timestamp;

  const ChatResponse({
    required this.answer,
    required this.confidence,
    required this.followUpQuestions,
    required this.timestamp,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      answer: json['answer'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      followUpQuestions: (json['follow_up_questions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

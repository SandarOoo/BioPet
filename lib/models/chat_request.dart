import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'chat_request.g.dart';

@JsonSerializable()
class ChatRequest extends Equatable {
  final String userQuestion;
  final List<Map<String, dynamic>> chatHistory;

  const ChatRequest({
    required this.userQuestion,
    required this.chatHistory,
  });

  factory ChatRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRequestToJson(this);

  @override
  List<Object?> get props => [userQuestion, chatHistory];
}


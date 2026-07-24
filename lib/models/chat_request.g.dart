// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRequest _$ChatRequestFromJson(Map<String, dynamic> json) => ChatRequest(
  userQuestion: json['userQuestion'] as String,
  chatHistory: (json['chatHistory'] as List<dynamic>)
      .map((e) => Map<String, String>.from(e as Map))
      .toList(),
);

Map<String, dynamic> _$ChatRequestToJson(ChatRequest instance) =>
    <String, dynamic>{
      'userQuestion': instance.userQuestion,
      'chatHistory': instance.chatHistory,
    };

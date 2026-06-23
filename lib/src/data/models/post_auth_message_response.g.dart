// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_auth_message_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostAuthMessageResponse _$PostAuthMessageResponseFromJson(
  Map<String, dynamic> json,
) => PostAuthMessageResponse(
  json['response'] as String?,
  type: json['type'] as String? ?? 'post_auth_message_response',
);

Map<String, dynamic> _$PostAuthMessageResponseToJson(
  PostAuthMessageResponse instance,
) => <String, dynamic>{'type': instance.type, 'response': instance.response};

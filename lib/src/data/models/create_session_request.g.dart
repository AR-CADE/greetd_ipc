// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_session_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSessionRequest _$CreateSessionRequestFromJson(
  Map<String, dynamic> json,
) => CreateSessionRequest(
  json['username'] as String,
  type: json['type'] as String? ?? 'create_session',
);

Map<String, dynamic> _$CreateSessionRequestToJson(
  CreateSessionRequest instance,
) => <String, dynamic>{'type': instance.type, 'username': instance.username};

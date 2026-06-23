// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_message_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthMessageResponse _$AuthMessageResponseFromJson(Map<String, dynamic> json) =>
    AuthMessageResponse(
      authMessageType: $enumDecode(
        _$AuthMessageTypeEnumMap,
        json['auth_message_type'],
      ),
      authMessage: json['auth_message'] as String,
      type: json['type'] as String? ?? 'auth_message',
    );

Map<String, dynamic> _$AuthMessageResponseToJson(
  AuthMessageResponse instance,
) => <String, dynamic>{
  'type': instance.type,
  'auth_message_type': _$AuthMessageTypeEnumMap[instance.authMessageType]!,
  'auth_message': instance.authMessage,
};

const _$AuthMessageTypeEnumMap = {
  AuthMessageType.visible: 'visible',
  AuthMessageType.secret: 'secret',
  AuthMessageType.info: 'info',
  AuthMessageType.error: 'error',
};

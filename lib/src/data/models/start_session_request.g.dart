// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_session_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartSessionRequest _$StartSessionRequestFromJson(Map<String, dynamic> json) =>
    StartSessionRequest(
      cmd: (json['cmd'] as List<dynamic>).map((e) => e as String).toList(),
      env:
          (json['env'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      type: json['type'] as String? ?? 'start_session',
    );

Map<String, dynamic> _$StartSessionRequestToJson(
  StartSessionRequest instance,
) => <String, dynamic>{
  'type': instance.type,
  'cmd': instance.cmd,
  'env': instance.env,
};

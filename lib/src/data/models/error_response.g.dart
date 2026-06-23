// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      errorType: $enumDecode(_$ErrorTypeEnumMap, json['error_type']),
      description: json['description'] as String,
      type: json['type'] as String? ?? 'error',
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'type': instance.type,
      'error_type': _$ErrorTypeEnumMap[instance.errorType]!,
      'description': instance.description,
    };

const _$ErrorTypeEnumMap = {
  ErrorType.authError: 'auth_error',
  ErrorType.error: 'error',
};

import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:greetd_ipc/src/data/models/auth_message_response.dart'
    show AuthMessageResponse;
import 'package:greetd_ipc/src/data/models/error_response.dart'
    show ErrorResponse;
import 'package:greetd_ipc/src/data/models/success_response.dart'
    show SuccessResponse;

abstract class GreetdResponse extends Equatable {
  const GreetdResponse();

  factory GreetdResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('type')) {
      final type = json['type'];

      switch (type) {
        case 'success':
          return SuccessResponse.fromJson(json);
        case 'error':
          return ErrorResponse.fromJson(json);
        case 'auth_message':
          return AuthMessageResponse.fromJson(json);
        default:
      }
    }

    throw const FormatException('Invalid greetd response');
  }

  factory GreetdResponse.fromBytes(Uint8List bytes) {
    if (bytes.length < 4) {
      throw const FormatException('Incomplete message');
    }
    final length = ByteData.sublistView(bytes, 0, 4).getUint32(0, Endian.host);
    if (bytes.length < 4 + length) {
      throw const FormatException('Incomplete message');
    }
    final payloadBytes = bytes.sublist(4, 4 + length);
    final jsonString = utf8.decode(payloadBytes);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return GreetdResponse.fromJson(json);
  }

  Map<String, dynamic> toJson();

  String get type => throw UnimplementedError();
}

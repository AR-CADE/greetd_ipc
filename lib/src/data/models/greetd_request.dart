import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:greetd_ipc/src/data/models/greetd_enumeration.dart'
    show GreetdCommand;

abstract class GreetdRequest extends Equatable {
  const GreetdRequest();

  GreetdCommand get command;

  Uint8List toBytes() {
    final jsonString = jsonEncode(toJson());
    final payloadBytes = utf8.encode(jsonString);
    final lengthBytes = ByteData(4)
      ..setUint32(0, payloadBytes.length, Endian.host);
    final buffer = Uint8List(4 + payloadBytes.length);
    buffer
      ..setRange(0, 4, lengthBytes.buffer.asUint8List())
      ..setRange(4, buffer.length, payloadBytes);
    return buffer;
  }

  Map<String, dynamic> toJson();
}

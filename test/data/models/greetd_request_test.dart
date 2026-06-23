import 'dart:convert';
import 'dart:typed_data';
import 'package:greetd_ipc/src/data/models/greetd_enumeration.dart';
import 'package:greetd_ipc/src/data/models/greetd_request.dart';
import 'package:test/test.dart';

class MockRequest extends GreetdRequest {
  const MockRequest({required this.payload});
  final Map<String, dynamic> payload;

  @override
  GreetdCommand get command => GreetdCommand.createSession;

  @override
  Map<String, dynamic> toJson() => payload;

  @override
  List<Object?> get props => [payload];
}

void main() {
  group('GreetdRequest model', () {
    test('toBytes', () {
      const request = MockRequest(payload: {'test': 'value'});
      final bytes = request.toBytes();

      final expectedBytes = [
        16,
        0,
        0,
        0,
        123,
        34,
        116,
        101,
        115,
        116,
        34,
        58,
        34,
        118,
        97,
        108,
        117,
        101,
        34,
        125,
      ];

      expect(bytes, equals(expectedBytes));

      // toBytes should encodes with 4-byte host-endian length prefix
      expect(bytes.length, greaterThan(4));

      final length = ByteData.sublistView(
        bytes,
        0,
        4,
      ).getUint32(0, Endian.host);
      expect(bytes.length, equals(4 + length));

      // Decode payload
      final payloadBytes = bytes.sublist(4);
      final decodedPayload =
          jsonDecode(utf8.decode(payloadBytes)) as Map<String, dynamic>;
      expect(decodedPayload, equals({'test': 'value'}));
    });
  });
}

import 'dart:convert' show jsonDecode, utf8;
import 'dart:typed_data' show ByteData, Endian;

import 'package:greetd_ipc/src/data/models/cancel_session_request.dart'
    show CancelSessionRequest;
import 'package:greetd_ipc/src/data/models/greetd_enumeration.dart'
    show GreetdCommand;
import 'package:test/test.dart';

void main() {
  group('CancelSessionRequest model', () {
    test('props are correct', () {
      const request = CancelSessionRequest();
      expect(
        request.props,
        equals(['cancel_session']),
      );
    });

    test('equality', () {
      expect(
        const CancelSessionRequest(
          type: 'type_test',
        ),
        const CancelSessionRequest(
          type: 'type_test',
        ),
      );
    });

    test('serialize', () {
      const request = CancelSessionRequest(
        type: 'type_test',
      );
      final json = request.toJson();
      final type = json['type'];

      expect(
        request.command,
        GreetdCommand.cancelSession,
      );
      expect(
        type,
        'type_test',
      );
    });

    test('deserialize', () {
      final json = <String, String>{};
      final request = CancelSessionRequest.fromJson(json);
      expect(
        {
          'type': 'cancel_session',
        },
        request.toJson(),
      );
      expect(
        request.type,
        'cancel_session',
      );
      expect(
        request.command,
        GreetdCommand.cancelSession,
      );
    });

    test('toBytes', () {
      final json = <String, String>{
        'type': 'cancel_session',
      };
      final request = CancelSessionRequest.fromJson(json);
      final bytes = request.toBytes();

      final expectedBytes = [
        25,
        0,
        0,
        0,
        123,
        34,
        116,
        121,
        112,
        101,
        34,
        58,
        34,
        99,
        97,
        110,
        99,
        101,
        108,
        95,
        115,
        101,
        115,
        115,
        105,
        111,
        110,
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
      expect(
        decodedPayload,
        equals({
          'type': 'cancel_session',
        }),
      );
    });
  });
}

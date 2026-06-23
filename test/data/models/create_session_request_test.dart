import 'dart:convert' show jsonDecode, utf8;
import 'dart:typed_data' show ByteData, Endian;

import 'package:greetd_ipc/src/data/models/create_session_request.dart'
    show CreateSessionRequest;
import 'package:greetd_ipc/src/data/models/greetd_enumeration.dart'
    show GreetdCommand;
import 'package:test/test.dart';

void main() {
  group('CreateSessionRequest model', () {
    test('props are correct', () {
      const request = CreateSessionRequest('username_test');
      expect(
        request.props,
        equals(['create_session', 'username_test']),
      );
    });

    test('equality', () {
      expect(
        const CreateSessionRequest(
          'username_test',
          type: 'type_test',
        ),
        const CreateSessionRequest(
          'username_test',
          type: 'type_test',
        ),
      );
    });

    test('serialize', () {
      const request = CreateSessionRequest(
        'username_test',
        type: 'type_test',
      );
      final json = request.toJson();
      final type = json['type'];

      expect(
        request.command,
        GreetdCommand.createSession,
      );
      expect(
        type,
        'type_test',
      );
    });

    test('deserialize', () {
      final json = <String, String>{
        'username': 'username_test',
      };
      final request = CreateSessionRequest.fromJson(json);
      expect(
        {
          'username': 'username_test',
          'type': 'create_session',
        },
        request.toJson(),
      );
      expect(
        request.type,
        'create_session',
      );
      expect(
        request.command,
        GreetdCommand.createSession,
      );
    });

    test('toBytes', () {
      final json = <String, String>{
        'username': 'username_test',
        'type': 'create_session',
      };
      final request = CreateSessionRequest.fromJson(json);
      final bytes = request.toBytes();

      final expectedBytes = [
        52,
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
        114,
        101,
        97,
        116,
        101,
        95,
        115,
        101,
        115,
        115,
        105,
        111,
        110,
        34,
        44,
        34,
        117,
        115,
        101,
        114,
        110,
        97,
        109,
        101,
        34,
        58,
        34,
        117,
        115,
        101,
        114,
        110,
        97,
        109,
        101,
        95,
        116,
        101,
        115,
        116,
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
          'username': 'username_test',
          'type': 'create_session',
        }),
      );
    });
  });
}

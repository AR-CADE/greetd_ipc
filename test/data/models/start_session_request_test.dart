import 'dart:convert' show jsonDecode, utf8;
import 'dart:typed_data' show ByteData, Endian;

import 'package:greetd_ipc/greetd_ipc.dart' show GreetdCommand;
import 'package:greetd_ipc/src/data/models/start_session_request.dart'
    show StartSessionRequest;
import 'package:test/test.dart';

void main() {
  group('StartSessionRequest model', () {
    test('props are correct', () {
      {
        const request = StartSessionRequest(
          cmd: ['command_test'],
        );
        expect(
          request.props,
          equals([
            'start_session',
            ['command_test'],
            <String>[],
          ]),
        );
      }
      {
        const request = StartSessionRequest(
          cmd: ['command_test'],
          env: ['env_test'],
        );
        expect(
          request.props,
          equals([
            'start_session',
            ['command_test'],
            ['env_test'],
          ]),
        );
      }
      {
        const request = StartSessionRequest(
          cmd: ['command_test'],
          env: ['env_test'],
          type: 'type_test',
        );
        expect(
          request.props,
          equals([
            'type_test',
            ['command_test'],
            ['env_test'],
          ]),
        );
      }
    });

    test('equality', () {
      expect(
        const StartSessionRequest(
          cmd: ['command_test'],
          env: ['env_test'],
          type: 'type_test',
        ),
        const StartSessionRequest(
          cmd: ['command_test'],
          env: ['env_test'],
          type: 'type_test',
        ),
      );
      expect(
        const StartSessionRequest(
          cmd: ['command_test'],
          env: ['env_test'],
        ),
        const StartSessionRequest(
          cmd: ['command_test'],
          env: ['env_test'],
        ),
      );
      expect(
        const StartSessionRequest(
          cmd: ['command_test'],
        ),
        const StartSessionRequest(
          cmd: ['command_test'],
        ),
      );
    });

    test('serialize', () {
      {
        const request = StartSessionRequest(
          cmd: ['command_test'],
          env: ['env_test'],
          type: 'type_test',
        );
        final json = request.toJson();
        final type = json['type'];
        final cmd = json['cmd'];
        final env = json['env'];

        expect(
          type,
          'type_test',
        );
        expect(
          cmd,
          ['command_test'],
        );
        expect(
          env,
          ['env_test'],
        );
      }
      {
        const request = StartSessionRequest(
          cmd: ['command_test'],
          env: ['env_test'],
        );
        final json = request.toJson();
        final type = json['type'];
        final cmd = json['cmd'];
        final env = json['env'];

        expect(
          type,
          'start_session',
        );
        expect(
          cmd,
          ['command_test'],
        );
        expect(
          env,
          ['env_test'],
        );
      }
      {
        const request = StartSessionRequest(
          cmd: ['command_test'],
        );
        final json = request.toJson();
        final type = json['type'];
        final cmd = json['cmd'];
        final env = json['env'];

        expect(
          type,
          'start_session',
        );
        expect(
          cmd,
          ['command_test'],
        );
        expect(
          env,
          <String>[],
        );
      }
    });

    test('deserialize', () {
      {
        final json = <String, dynamic>{
          'type': 'type_test',
          'cmd': ['command_test'],
          'env': ['response_test'],
        };
        final request = StartSessionRequest.fromJson(json);
        expect(
          {
            'type': 'type_test',
            'cmd': ['command_test'],
            'env': ['response_test'],
          },
          request.toJson(),
        );
        expect(
          request.type,
          'type_test',
        );
        expect(
          request.cmd,
          ['command_test'],
        );
        expect(
          request.env,
          ['response_test'],
        );
        expect(
          request.command,
          GreetdCommand.startSession,
        );
      }
      {
        final json = <String, dynamic>{
          'type': 'type_test',
          'cmd': ['command_test'],
        };
        final request = StartSessionRequest.fromJson(json);
        expect(
          {
            'type': 'type_test',
            'cmd': ['command_test'],
            'env': <String>[],
          },
          request.toJson(),
        );
        expect(
          request.type,
          'type_test',
        );
        expect(
          request.cmd,
          ['command_test'],
        );
        expect(
          request.env,
          <String>[],
        );
        expect(
          request.command,
          GreetdCommand.startSession,
        );
      }
      {
        final json = <String, dynamic>{
          'cmd': ['command_test'],
        };
        final request = StartSessionRequest.fromJson(json);
        expect(
          {
            'type': 'start_session',
            'cmd': ['command_test'],
            'env': <String>[],
          },
          request.toJson(),
        );
        expect(
          request.type,
          'start_session',
        );
        expect(
          request.cmd,
          ['command_test'],
        );
        expect(
          request.env,
          <String>[],
        );
        expect(
          request.command,
          GreetdCommand.startSession,
        );
      }
    });

    test('toBytes', () {
      final json = <String, dynamic>{
        'type': 'type_test',
        'cmd': ['command_test'],
        'env': ['response_test'],
      };
      final request = StartSessionRequest.fromJson(json);
      final bytes = request.toBytes();

      final expectedBytes = [
        67,
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
        116,
        121,
        112,
        101,
        95,
        116,
        101,
        115,
        116,
        34,
        44,
        34,
        99,
        109,
        100,
        34,
        58,
        91,
        34,
        99,
        111,
        109,
        109,
        97,
        110,
        100,
        95,
        116,
        101,
        115,
        116,
        34,
        93,
        44,
        34,
        101,
        110,
        118,
        34,
        58,
        91,
        34,
        114,
        101,
        115,
        112,
        111,
        110,
        115,
        101,
        95,
        116,
        101,
        115,
        116,
        34,
        93,
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
          'type': 'type_test',
          'cmd': ['command_test'],
          'env': ['response_test'],
        }),
      );
    });
  });
}

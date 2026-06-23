import 'dart:convert' show jsonDecode, utf8;
import 'dart:typed_data' show ByteData, Endian;

import 'package:greetd_ipc/greetd_ipc.dart' show GreetdCommand;
import 'package:greetd_ipc/src/data/models/post_auth_message_response.dart'
    show PostAuthMessageResponse;
import 'package:test/test.dart';

void main() {
  group('PostAuthMessageResponse model', () {
    test('props are correct', () {
      {
        const response = PostAuthMessageResponse(
          'response_test',
        );
        expect(
          response.props,
          equals(['post_auth_message_response', 'response_test']),
        );
      }
      {
        const response = PostAuthMessageResponse(
          'response_test',
          type: 'type_test',
        );
        expect(
          response.props,
          equals(['type_test', 'response_test']),
        );
      }
    });

    test('equality', () {
      expect(
        const PostAuthMessageResponse(
          'response_test',
          type: 'type_test',
        ),
        const PostAuthMessageResponse(
          'response_test',
          type: 'type_test',
        ),
      );
      expect(
        const PostAuthMessageResponse(
          'response_test',
        ),
        const PostAuthMessageResponse(
          'response_test',
        ),
      );
    });

    test('serialize', () {
      {
        const authResponse = PostAuthMessageResponse(
          'response_test',
          type: 'type_test',
        );
        final json = authResponse.toJson();
        final type = json['type'];
        final response = json['response'];

        expect(
          type,
          'type_test',
        );
        expect(
          response,
          'response_test',
        );
      }
      {
        const authResponse = PostAuthMessageResponse(
          'response_test',
        );
        final json = authResponse.toJson();
        final type = json['type'];
        final response = json['response'];

        expect(
          type,
          'post_auth_message_response',
        );
        expect(
          response,
          'response_test',
        );
      }
    });

    test('deserialize', () {
      {
        final json = <String, String>{
          'type': 'type_test',
          'response': 'response_test',
        };
        final response = PostAuthMessageResponse.fromJson(json);
        expect(
          {
            'type': 'type_test',
            'response': 'response_test',
          },
          response.toJson(),
        );
        expect(
          response.type,
          'type_test',
        );
        expect(
          response.response,
          'response_test',
        );
        expect(
          response.command,
          GreetdCommand.postAuthMessageResponse,
        );
      }
      {
        final json = <String, String>{
          'response': 'response_test',
        };
        final response = PostAuthMessageResponse.fromJson(json);
        expect(
          {
            'type': 'post_auth_message_response',
            'response': 'response_test',
          },
          response.toJson(),
        );
        expect(
          response.type,
          'post_auth_message_response',
        );
        expect(
          response.response,
          'response_test',
        );
        expect(
          response.command,
          GreetdCommand.postAuthMessageResponse,
        );
      }
    });

    test('toBytes', () {
      final json = <String, String>{
        'type': 'type_test',
        'response': 'response_test',
      };
      final response = PostAuthMessageResponse.fromJson(json);
      final bytes = response.toBytes();

      final expectedBytes = [
        47,
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
        114,
        101,
        115,
        112,
        111,
        110,
        115,
        101,
        34,
        58,
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
          'response': 'response_test',
        }),
      );
    });
  });
}

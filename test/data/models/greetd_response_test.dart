import 'dart:typed_data';
import 'package:greetd_ipc/src/data/models/auth_message_response.dart'
    show AuthMessageResponse;
import 'package:greetd_ipc/src/data/models/error_response.dart'
    show ErrorResponse;
import 'package:greetd_ipc/src/data/models/greetd_response.dart';
import 'package:greetd_ipc/src/data/models/success_response.dart';
import 'package:test/test.dart';

void main() {
  group('GreetdResponse model', () {
    group('deserialize', () {
      test('fromJson throws FormatException for missing type', () {
        expect(
          () => GreetdResponse.fromJson(const <String, dynamic>{}),
          throwsA(isA<FormatException>()),
        );
      });

      test('fromJson throws FormatException for unknown type', () {
        expect(
          () => GreetdResponse.fromJson(const <String, dynamic>{
            'type': 'unknown_type',
          }),
          throwsA(isA<FormatException>()),
        );
      });

      test('fromJson return type', () {
        {
          final json = <String, String>{'type': 'success'};
          final response = GreetdResponse.fromJson(json);

          expect(
            response is SuccessResponse,
            true,
          );

          expect(
            {
              'type': 'success',
            },
            response.toJson(),
          );
          expect(
            response.type,
            'success',
          );
        }
        {
          final json = <String, String>{
            'type': 'error',
            'error_type': 'auth_error',
            'description': 'description_test',
          };
          final response = GreetdResponse.fromJson(json);

          expect(
            response is ErrorResponse,
            true,
          );

          expect(
            {
              'type': 'error',
              'error_type': 'auth_error',
              'description': 'description_test',
            },
            response.toJson(),
          );
          expect(
            response.type,
            'error',
          );
        }
        {
          final json = <String, String>{
            'type': 'auth_message',
            'auth_message': 'authMessage_test',
            'auth_message_type': 'visible',
          };
          final response = GreetdResponse.fromJson(json);

          expect(
            response is AuthMessageResponse,
            true,
          );

          expect(
            {
              'type': 'auth_message',
              'auth_message': 'authMessage_test',
              'auth_message_type': 'visible',
            },
            response.toJson(),
          );
          expect(
            response.type,
            'auth_message',
          );
        }
      });
    });

    group('fromBytes', () {
      test('fromBytes throws FormatException for short bytes', () {
        expect(
          () => GreetdResponse.fromBytes(Uint8List.fromList([0, 0, 0])),
          throwsA(isA<FormatException>()),
        );
      });

      test('fromBytes throws FormatException for incomplete payload', () {
        // 4 bytes length prefix = 10, but only 3 payload bytes provided
        final data = Uint8List.fromList([10, 0, 0, 0, 1, 2, 3]);
        expect(
          () => GreetdResponse.fromBytes(data),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}

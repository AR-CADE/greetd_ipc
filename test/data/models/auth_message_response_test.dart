import 'package:greetd_ipc/src/data/models/auth_message_response.dart'
    show AuthMessageResponse;
import 'package:greetd_ipc/src/data/models/greetd_enumeration.dart'
    show AuthMessageType;
import 'package:test/test.dart';

void main() {
  group('AuthMessageResponse model', () {
    test('props are correct', () {
      const response = AuthMessageResponse(
        authMessage: 'authMessage_test',
        authMessageType: .secret,
      );
      expect(
        response.props,
        equals(['auth_message', AuthMessageType.secret, 'authMessage_test']),
      );
    });

    test('equality', () {
      expect(
        const AuthMessageResponse(
          authMessage: 'authMessage_test',
          authMessageType: .error,
          type: 'authType_test',
        ),
        const AuthMessageResponse(
          authMessage: 'authMessage_test',
          authMessageType: .error,
          type: 'authType_test',
        ),
      );
    });

    test('serialize', () {
      const response = AuthMessageResponse(
        authMessage: 'authMessage_test',
        authMessageType: .info,
        type: 'authType_test',
      );
      final json = response.toJson();
      final authMessage = json['auth_message'];
      final authMessageType = json['auth_message_type'];
      final type = json['type'];

      expect(
        authMessage,
        'authMessage_test',
      );
      expect(
        authMessageType,
        'info',
      );
      expect(
        type,
        'authType_test',
      );
    });

    test('deserialize', () {
      final json = {
        'auth_message': 'authMessage_test',
        'auth_message_type': 'visible',
      };
      final response = AuthMessageResponse.fromJson(json);
      expect(
        {
          'type': 'auth_message',
          'auth_message': 'authMessage_test',
          'auth_message_type': 'visible',
        },
        response.toJson(),
      );
      expect(
        response.authMessage,
        'authMessage_test',
      );
      expect(
        response.authMessageType,
        AuthMessageType.visible,
      );
      expect(
        response.type,
        'auth_message',
      );
    });
  });
}

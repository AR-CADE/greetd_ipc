import 'package:greetd_ipc/src/data/models/error_response.dart'
    show ErrorResponse;
import 'package:greetd_ipc/src/data/models/greetd_enumeration.dart'
    show ErrorType;
import 'package:test/test.dart';

void main() {
  group('ErrorResponse model', () {
    test('props are correct', () {
      const request = ErrorResponse(
        errorType: .authError,
        description: 'description_test',
      );
      expect(
        request.props,
        equals(['error', ErrorType.authError, 'description_test']),
      );
    });

    test('equality', () {
      expect(
        const ErrorResponse(
          errorType: .authError,
          description: 'description_test',
          type: 'type_test',
        ),
        const ErrorResponse(
          errorType: .authError,
          description: 'description_test',
          type: 'type_test',
        ),
      );
    });

    test('serialize', () {
      const response = ErrorResponse(
        errorType: .authError,
        description: 'description_test',
        type: 'type_test',
      );
      final json = response.toJson();
      final type = json['type'];
      final errorType = json['error_type'];
      final description = json['description'];

      expect(
        type,
        'type_test',
      );
      expect(
        errorType,
        'auth_error',
      );
      expect(
        description,
        'description_test',
      );
    });

    test('deserialize', () {
      final json = <String, String>{
        'error_type': 'auth_error',
        'description': 'description_test',
      };
      final response = ErrorResponse.fromJson(json);
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
      expect(
        response.errorType,
        ErrorType.authError,
      );
      expect(
        response.description,
        'description_test',
      );
    });
  });
}

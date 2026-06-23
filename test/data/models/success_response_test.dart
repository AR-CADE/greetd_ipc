import 'package:greetd_ipc/src/data/models/success_response.dart'
    show SuccessResponse;
import 'package:test/test.dart';

void main() {
  group('SuccessResponse model', () {
    test('props are correct', () {
      {
        const request = SuccessResponse();
        expect(
          request.props,
          equals(['success']),
        );
      }
      {
        const request = SuccessResponse(
          type: 'type_test',
        );
        expect(
          request.props,
          equals(['type_test']),
        );
      }
    });

    test('equality', () {
      expect(
        const SuccessResponse(),
        const SuccessResponse(),
      );
      expect(
        const SuccessResponse(
          type: 'type_test',
        ),
        const SuccessResponse(
          type: 'type_test',
        ),
      );
    });

    test('serialize', () {
      {
        const response = SuccessResponse();
        final json = response.toJson();
        final type = json['type'];

        expect(
          type,
          'success',
        );
      }
      {
        const response = SuccessResponse(type: 'type_test');
        final json = response.toJson();
        final type = json['type'];

        expect(
          type,
          'type_test',
        );
      }
    });

    test('deserialize', () {
      {
        final json = <String, String>{};
        final response = SuccessResponse.fromJson(json);
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
        final json = <String, String>{'type': 'type_test'};
        final response = SuccessResponse.fromJson(json);
        expect(
          {
            'type': 'type_test',
          },
          response.toJson(),
        );
        expect(
          response.type,
          'type_test',
        );
      }
    });
  });
}

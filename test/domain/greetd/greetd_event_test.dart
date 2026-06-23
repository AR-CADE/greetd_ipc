import 'package:greetd_ipc/greetd_ipc.dart' show CreateStartableSession;
import 'package:greetd_ipc/src/data/models/success_response.dart'
    show SuccessResponse;
import 'package:greetd_ipc/src/domain/greetd/greetd_bloc.dart'
    show
        CancelSession,
        Connect,
        CreateAuthSession,
        CreateSession,
        ErrorReceived,
        PostAuthResponse,
        ResponseReceived,
        StartSession;
import 'package:test/test.dart';

void main() {
  group('GreetdEvent', () {
    group('CreateStartableSession', () {
      test('supports value equality', () {
        expect(
          const CreateStartableSession(
            username: 'username',
            password: 'password',
            cmd: ['cmd'],
            env: ['env'],
          ),
          equals(
            const CreateStartableSession(
              username: 'username',
              password: 'password',
              cmd: ['cmd'],
              env: ['env'],
            ),
          ),
        );
      });

      test('props are correct', () {
        expect(
          const CreateStartableSession(
            username: 'username',
            password: 'password',
            cmd: ['cmd'],
            env: ['env'],
          ).props,
          equals([
            'username',
            'password',
            ['cmd'],
            ['env'],
          ]),
        );
      });
    });

    group('CreateAuthSession', () {
      test('supports value equality', () {
        expect(
          const CreateAuthSession(
            username: 'username',
            password: 'password',
          ),
          equals(
            const CreateAuthSession(
              username: 'username',
              password: 'password',
            ),
          ),
        );
      });

      test('props are correct', () {
        expect(
          const CreateAuthSession(
            username: 'username',
            password: 'password',
          ).props,
          equals([
            'username',
            'password',
          ]),
        );
      });
    });

    group('CreateSession', () {
      test('supports value equality', () {
        expect(
          const CreateSession('username'),
          equals(const CreateSession('username')),
        );
      });

      test('props are correct', () {
        expect(
          const CreateSession('username').props,
          equals(['username']),
        );
      });
    });

    group('PostAuthResponse', () {
      test('supports value equality', () {
        expect(
          const PostAuthResponse('password'),
          equals(const PostAuthResponse('password')),
        );
      });

      test('props are correct', () {
        expect(
          const PostAuthResponse('password').props,
          equals(['password']),
        );
      });
    });

    group('StartSession', () {
      test('supports value equality', () {
        expect(
          const StartSession(
            cmd: ['cmd'],
            env: ['env'],
          ),
          equals(
            const StartSession(
              cmd: ['cmd'],
              env: ['env'],
            ),
          ),
        );
      });

      test('props are correct', () {
        expect(
          const StartSession(
            cmd: ['cmd'],
            env: ['env'],
          ).props,
          equals([
            ['cmd'],
            ['env'],
          ]),
        );
      });
    });

    group('CancelSession', () {
      test('supports value equality', () {
        expect(
          const CancelSession(),
          equals(const CancelSession()),
        );
      });

      test('props are correct', () {
        expect(
          const CancelSession().props,
          equals([]),
        );
      });
    });

    group('Connect', () {
      test('supports value equality', () {
        expect(
          const Connect(),
          equals(const Connect()),
        );
      });

      test('props are correct', () {
        expect(
          const Connect().props,
          equals([]),
        );
      });
    });

    group('ResponseReceived', () {
      test('supports value equality', () {
        expect(
          const ResponseReceived(
            SuccessResponse(
              type: 'sucess',
            ),
          ),
          equals(
            const ResponseReceived(
              SuccessResponse(
                type: 'sucess',
              ),
            ),
          ),
        );
      });

      test('props are correct', () {
        expect(
          const ResponseReceived(
            SuccessResponse(
              type: 'sucess',
            ),
          ).props,
          equals([
            const SuccessResponse(
              type: 'sucess',
            ),
          ]),
        );
      });
    });

    group('ErrorReceived', () {
      test('supports value equality', () {
        expect(
          const ErrorReceived('error'),
          equals(const ErrorReceived('error')),
        );
      });

      test('props are correct', () {
        expect(
          const ErrorReceived('error').props,
          equals(['error']),
        );
      });
    });
  });
}

import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:greetd_ipc/greetd_ipc.dart';
import 'package:greetd_ipc/src/data/models/auth_message_response.dart';
import 'package:greetd_ipc/src/data/models/cancel_session_request.dart';
import 'package:greetd_ipc/src/data/models/create_session_request.dart';
import 'package:greetd_ipc/src/data/models/error_response.dart';
import 'package:greetd_ipc/src/data/models/post_auth_message_response.dart';
import 'package:greetd_ipc/src/data/models/start_session_request.dart';
import 'package:greetd_ipc/src/data/models/success_response.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

class MockGreetdRepository extends Mock implements GreetdRepository {}

class FakeGreetdRequest extends Fake implements GreetdRequest {}

void main() {
  late MockGreetdRepository repository;
  late PublishSubject<GreetdResponse> responsesSubject;

  setUpAll(() {
    registerFallbackValue(FakeGreetdRequest());
  });

  setUp(() {
    repository = MockGreetdRepository();
    responsesSubject = PublishSubject<GreetdResponse>();

    when(() => repository.responses).thenAnswer((_) => responsesSubject.stream);
    when(() => repository.connected).thenReturn(true);
    when(() => repository.connect()).thenAnswer((_) async {});
    when(() => repository.sendRequest(any())).thenAnswer((_) async {});
    when(() => repository.disconnect()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await responsesSubject.close();
  });

  group('GreetdBloc', () {
    blocTest<GreetdBloc, GreetdState>(
      'emits GreetdStatus.connected when connect succeeds',
      build: () => GreetdBloc(repository: repository),
      expect: () => [
        const GreetdState(status: GreetdStatus.loading, username: ''),
        const GreetdState(status: GreetdStatus.connected, username: ''),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'emits GreetdStatus.error when connect fails',
      setUp: () {
        when(
          () => repository.connect(),
        ).thenThrow(Exception('Connection failed'));
      },
      build: () => GreetdBloc(repository: repository),
      expect: () => [
        const GreetdState(status: GreetdStatus.loading, username: ''),
        const GreetdState(
          status: GreetdStatus.error,
          username: '',
          error:
              'Failed to connect to greetd ipc ! -'
              ' Exception: Connection failed',
        ),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'emits GreetdStatus.error when repository.connected'
      ' is false after connect',
      setUp: () {
        when(() => repository.connected).thenReturn(false);
      },
      build: () => GreetdBloc(repository: repository),
      expect: () => [
        const GreetdState(status: GreetdStatus.loading, username: ''),
        const GreetdState(
          status: GreetdStatus.error,
          username: '',
          error: 'Failed to connect to greetd ipc !',
        ),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'CreateStartableSession adds CreateAuthSession',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        bloc.add(
          const CreateStartableSession(
            username: 'user',
            password: 'pwd',
            cmd: ['ls'],
            env: ['PATH=/bin'],
          ),
        );
      },
      skip: 2,
      expect: () => [
        const GreetdState(status: GreetdStatus.loading, username: 'user'),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'CreateAuthSession adds CreateSession',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        bloc.add(
          const CreateAuthSession(
            username: 'user',
            password: 'pwd',
          ),
        );
      },
      skip: 2,
      expect: () => [
        const GreetdState(status: GreetdStatus.loading, username: 'user'),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'CreateSession sends CreateSessionRequest',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        bloc.add(const CreateSession('user'));
      },
      skip: 2,
      expect: () => [
        const GreetdState(status: GreetdStatus.loading, username: 'user'),
      ],
      verify: (bloc) {
        verify(
          () => repository.sendRequest(const CreateSessionRequest('user')),
        ).called(1);
      },
    );

    blocTest<GreetdBloc, GreetdState>(
      'CreateSession emits error state when sendRequest throws',
      setUp: () {
        when(
          () => repository.sendRequest(any()),
        ).thenThrow(Exception('Send failed'));
      },
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        bloc.add(const CreateSession('user'));
      },
      skip: 2,
      expect: () => [
        const GreetdState(status: GreetdStatus.loading, username: 'user'),
        const GreetdState(
          status: GreetdStatus.error,
          username: 'user',
          error: 'Exception: Send failed',
        ),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'PostAuthResponse sends PostAuthMessageResponse',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        bloc.add(const PostAuthResponse('pwd'));
      },
      skip: 2,
      expect: () => [
        const GreetdState(status: GreetdStatus.loading, username: ''),
      ],
      verify: (bloc) {
        verify(
          () => repository.sendRequest(const PostAuthMessageResponse('pwd')),
        ).called(1);
      },
    );

    blocTest<GreetdBloc, GreetdState>(
      'StartSession sends StartSessionRequest',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        bloc.add(const StartSession(cmd: ['ls'], env: ['PATH=/bin']));
      },
      skip: 2,
      expect: () => [
        const GreetdState(status: GreetdStatus.loading, username: ''),
      ],
      verify: (bloc) {
        verify(
          () => repository.sendRequest(
            const StartSessionRequest(cmd: ['ls'], env: ['PATH=/bin']),
          ),
        ).called(1);
      },
    );

    blocTest<GreetdBloc, GreetdState>(
      'CancelSession sends CancelSessionRequest and resets state to initial',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        bloc.add(const CancelSession());
      },
      skip: 2,
      expect: () => [
        const GreetdState(status: GreetdStatus.loading, username: ''),
        GreetdState.initial(),
      ],
      verify: (bloc) {
        verify(
          () => repository.sendRequest(const CancelSessionRequest()),
        ).called(1);
      },
    );

    blocTest<GreetdBloc, GreetdState>(
      'CancelSession when disconnected clear session and returns initial state',
      setUp: () {
        when(() => repository.connected).thenReturn(false);
      },
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.error);
        bloc.add(const CancelSession());
      },
      skip: 2,
      expect: () => [
        GreetdState.initial(),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'handles AuthMessageResponse with visible prompt',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        responsesSubject.add(
          const AuthMessageResponse(
            authMessageType: AuthMessageType.visible,
            authMessage: 'Username:',
          ),
        );
      },
      skip: 2,
      expect: () => [
        const GreetdState(
          status: GreetdStatus.visible,
          username: '',
          promptType: AuthMessageType.visible,
          promptMessage: 'Username:',
        ),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'handles AuthMessageResponse with secret prompt and no saved password',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        responsesSubject.add(
          const AuthMessageResponse(
            authMessageType: AuthMessageType.secret,
            authMessage: 'Password:',
          ),
        );
      },
      skip: 2,
      expect: () => [
        const GreetdState(
          status: GreetdStatus.secret,
          username: '',
          promptType: AuthMessageType.secret,
          promptMessage: 'Password:',
        ),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'handles AuthMessageResponse with secret prompt and saved password',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        bloc.add(const CreateAuthSession(username: 'user', password: 'pwd'));
        await Future<void>.delayed(Duration.zero);
        responsesSubject.add(
          const AuthMessageResponse(
            authMessageType: AuthMessageType.secret,
            authMessage: 'Password:',
          ),
        );
      },
      skip: 3,
      expect: () => [
        const GreetdState(
          status: GreetdStatus.autoSecret,
          username: 'user',
        ),
        const GreetdState(
          status: GreetdStatus.loading,
          username: 'user',
        ),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'handles AuthMessageResponse with info type',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        responsesSubject.add(
          const AuthMessageResponse(
            authMessageType: AuthMessageType.info,
            authMessage: 'Welcome',
          ),
        );
      },
      skip: 2,
      expect: () => [
        const GreetdState(
          status: GreetdStatus.authInfo,
          username: '',
          promptType: AuthMessageType.info,
          promptMessage: 'Welcome',
        ),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'handles AuthMessageResponse with error type',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        responsesSubject.add(
          const AuthMessageResponse(
            authMessageType: AuthMessageType.error,
            authMessage: 'Invalid credentials',
          ),
        );
      },
      skip: 2,
      expect: () => [
        const GreetdState(
          status: GreetdStatus.authError,
          username: '',
          promptType: AuthMessageType.error,
          promptMessage: 'Invalid credentials',
        ),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'handles SuccessResponse when request was CancelSession',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        bloc.add(const CancelSession());
        await Future<void>.delayed(Duration.zero);
        responsesSubject.add(const SuccessResponse());
      },
      skip: 2,
      expect: () => [
        const GreetdState(status: GreetdStatus.loading, username: ''),
        GreetdState.initial(),
        const GreetdState(status: GreetdStatus.success, username: ''),
        const GreetdState(status: GreetdStatus.cancelled, username: ''),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'handles SuccessResponse when request was StartSession',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        bloc.add(const StartSession(cmd: ['ls']));
        await Future<void>.delayed(Duration.zero);
        responsesSubject.add(const SuccessResponse());
      },
      skip: 3,
      expect: () => [
        const GreetdState(status: GreetdStatus.success, username: ''),
        const GreetdState(status: GreetdStatus.exit, username: ''),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'handles SuccessResponse when request was PostAuthResponse with command',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        bloc.add(
          const CreateStartableSession(
            username: 'user',
            password: 'pwd',
            cmd: ['ls'],
          ),
        );
        await Future<void>.delayed(Duration.zero);
        responsesSubject.add(
          const AuthMessageResponse(
            authMessageType: AuthMessageType.secret,
            authMessage: 'Password:',
          ),
        );
        await Future<void>.delayed(Duration.zero);
        responsesSubject.add(const SuccessResponse());
      },
      skip: 5,
      expect: () => [
        const GreetdState(status: GreetdStatus.success, username: 'user'),
        const GreetdState(status: GreetdStatus.loading, username: 'user'),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'handles SuccessResponse when request was'
      ' PostAuthResponse with no command',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        bloc.add(const CreateAuthSession(username: 'user', password: 'pwd'));
        await Future<void>.delayed(Duration.zero);
        responsesSubject.add(
          const AuthMessageResponse(
            authMessageType: AuthMessageType.secret,
            authMessage: 'Password:',
          ),
        );
        await Future<void>.delayed(Duration.zero);
        responsesSubject.add(const SuccessResponse());
      },
      skip: 5,
      expect: () => [
        const GreetdState(status: GreetdStatus.success, username: 'user'),
        const GreetdState(
          status: GreetdStatus.error,
          username: 'user',
          error: 'Cannot start session, No valid cmd line found !',
        ),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'handles ErrorResponse',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        responsesSubject.add(
          const ErrorResponse(
            errorType: ErrorType.error,
            description: 'Operation failed',
          ),
        );
      },
      skip: 2,
      expect: () => [
        const GreetdState(
          status: GreetdStatus.error,
          username: '',
          error: 'Operation failed',
        ),
      ],
    );

    blocTest<GreetdBloc, GreetdState>(
      'handles stream error through _ErrorReceived',
      build: () => GreetdBloc(repository: repository),
      act: (bloc) async {
        await bloc.stream.firstWhere((s) => s.status == GreetdStatus.connected);
        responsesSubject.addError(Exception('Stream socket error'));
      },
      skip: 2,
      expect: () => [
        const GreetdState(
          status: GreetdStatus.error,
          username: '',
          error: 'Exception: Stream socket error',
        ),
      ],
    );
  });
}

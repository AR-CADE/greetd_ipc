import 'dart:async' show StreamSubscription;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:greetd_ipc/src/data/models/auth_message_response.dart'
    show AuthMessageResponse;
import 'package:greetd_ipc/src/data/models/cancel_session_request.dart'
    show CancelSessionRequest;
import 'package:greetd_ipc/src/data/models/create_session_request.dart'
    show CreateSessionRequest;
import 'package:greetd_ipc/src/data/models/error_response.dart'
    show ErrorResponse;
import 'package:greetd_ipc/src/data/models/greetd_enumeration.dart'
    show AuthMessageType;
import 'package:greetd_ipc/src/data/models/greetd_response.dart'
    show GreetdResponse;
import 'package:greetd_ipc/src/data/models/post_auth_message_response.dart'
    show PostAuthMessageResponse;
import 'package:greetd_ipc/src/data/models/start_session_request.dart'
    show StartSessionRequest;
import 'package:greetd_ipc/src/data/models/success_response.dart'
    show SuccessResponse;
import 'package:greetd_ipc/src/data/repositories/greetd_repository.dart'
    show GreetdRepository;
import 'package:meta/meta.dart';

part 'greetd_event.dart';
part 'greetd_state.dart';

class GreetdBloc extends Bloc<GreetdEvent, GreetdState> {
  GreetdBloc({required this.repository}) : super(GreetdState.initial()) {
    on<CreateSession>(_onCreateSession);
    on<CreateStartableSession>(_onCreateStartableSession);
    on<CreateAuthSession>(_onCreateAuthSession);
    on<PostAuthResponse>(_onPostAuthResponse);
    on<StartSession>(_onStartSession);
    on<CancelSession>(_onCancelSession);
    on<Connect>(_onConnect);
    on<ResponseReceived>(_onResponseReceived);
    on<ErrorReceived>(_onErrorReceived);

    _responsesSubscription = repository.responses.listen(
      (r) => add(ResponseReceived(r)),
      onError: (Object e) => add(ErrorReceived(e.toString())),
    );

    _request = Connect;
    add(const Connect());
  }
  final GreetdRepository repository;
  late final StreamSubscription<GreetdResponse> _responsesSubscription;
  late Type _request;

  String? _password;
  List<String>? _cmd;
  List<String> _env = const [];
  // final Stopwatch _stopwatch = Stopwatch();

  Future<void> _onConnect(Connect event, Emitter<GreetdState> emit) async {
    // restartStopwatch();
    // print('connecting to greetd ipc...');

    try {
      emit(
        state.copyWith(
          status: GreetdStatus.loading,
        ),
      );
      await repository.connect();
      // final elapsedMilliseconds = measureStopwatch();
      // // print(elapsedMilliseconds);
      if (repository.connected) {
        emit(
          state.copyWith(
            status: GreetdStatus.connected,
          ),
        );
      } else {
        await _close();

        emit(
          state.copyWith(
            status: GreetdStatus.error,
            error: 'Failed to connect to greetd ipc !',
          ),
        );
      }
    } on Exception catch (e) {
      await _close();

      emit(
        state.copyWith(
          status: GreetdStatus.error,
          error: 'Failed to connect to greetd ipc ! - $e',
        ),
      );
    }
  }

  /*   void pauseStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    }
  }

  void continueStopwatch() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
    }
  }

  int measureStopwatch() {
    pauseStopwatch();
    return _stopwatch.elapsedMilliseconds;
  }

  void clearStopwatch() {
    if (_stopwatch.isRunning) {
      pauseStopwatch();
      _stopwatch.reset();
    }
  }

  void restartStopwatch() {
    clearStopwatch();
    continueStopwatch();
  } */

  Future<void> _onCreateStartableSession(
    CreateStartableSession event,
    Emitter<GreetdState> emit,
  ) async {
    if (!repository.connected) {
      return;
    }
    if (state.status == GreetdStatus.loading) {
      return;
    }
    _request = CreateStartableSession;
    _cmd = event.cmd;
    _env = event.env;
    add(CreateAuthSession(username: event.username, password: event.password));
  }

  Future<void> _onCreateAuthSession(
    CreateAuthSession event,
    Emitter<GreetdState> emit,
  ) async {
    if (!repository.connected) {
      return;
    }
    if (state.status == GreetdStatus.loading) {
      return;
    }
    _request = CreateAuthSession;
    _password = event.password;
    add(CreateSession(event.username));
  }

  Future<void> _onCreateSession(
    CreateSession event,
    Emitter<GreetdState> emit,
  ) async {
    if (!repository.connected) {
      return;
    }
    if (state.status == GreetdStatus.loading) {
      return;
    }
    // restartStopwatch();
    _request = CreateSession;
    emit(
      state.copyWith(
        status: GreetdStatus.loading,
        username: event.username,
      ),
    );
    try {
      await repository.sendRequest(CreateSessionRequest(event.username));
    } on Exception catch (e) {
      emit(state.copyWith(status: GreetdStatus.error, error: e.toString()));
    }
  }

  Future<void> _onPostAuthResponse(
    PostAuthResponse event,
    Emitter<GreetdState> emit,
  ) async {
    if (!repository.connected) {
      return;
    }
    if (state.status == GreetdStatus.loading) {
      return;
    }
    // restartStopwatch();
    _request = PostAuthResponse;
    emit(state.copyWith(status: GreetdStatus.loading));
    await repository.sendRequest(
      PostAuthMessageResponse(event.password),
    );
  }

  Future<void> _onStartSession(
    StartSession event,
    Emitter<GreetdState> emit,
  ) async {
    if (!repository.connected) {
      return;
    }
    if (state.status == GreetdStatus.loading) {
      return;
    }
    // restartStopwatch();
    _request = StartSession;
    emit(state.copyWith(status: GreetdStatus.loading));
    try {
      await repository.sendRequest(
        StartSessionRequest(cmd: event.cmd, env: event.env),
      );
    } on Exception catch (e) {
      emit(state.copyWith(status: GreetdStatus.error, error: e.toString()));
    }
  }

  Future<void> _onCancelSession(
    CancelSession event,
    Emitter<GreetdState> emit,
  ) async {
    if (!repository.connected) {
      clearSession();
      emit(GreetdState.initial());
      return;
    }
    // restartStopwatch();
    _request = CancelSession;
    emit(state.copyWith(status: GreetdStatus.loading));
    await repository.sendRequest(const CancelSessionRequest());
    emit(GreetdState.initial());
  }

  Future<void> _onResponseReceived(
    ResponseReceived event,
    Emitter<GreetdState> emit,
  ) async {
    if (!repository.connected) {
      return;
    }
    final r = event.response;

    // final elapsedMilliseconds = measureStopwatch();
    // // print(elapsedMilliseconds);
    // print(_request);
    // print(r);

    if (r is AuthMessageResponse) {
      if (r.authMessageType == AuthMessageType.error) {
        clearSession();
        return emit(
          state.copyWith(
            status: GreetdStatus.authError,
            promptType: r.authMessageType,
            promptMessage: r.authMessage,
          ),
        );
      }

      if (r.authMessageType == AuthMessageType.info) {
        return emit(
          state.copyWith(
            status: GreetdStatus.authInfo,
            promptType: r.authMessageType,
            promptMessage: r.authMessage,
          ),
        );
      }

      if (r.authMessageType == AuthMessageType.secret ||
          r.authMessageType == AuthMessageType.visible) {
        final p = _password;

        if (p != null) {
          emit(
            state.copyWith(
              status: GreetdStatus.autoSecret,
            ),
          );
          return add(PostAuthResponse(p));
        } else {
          switch (r.authMessageType) {
            case AuthMessageType.secret:
              return emit(
                state.copyWith(
                  status: GreetdStatus.secret,
                  promptType: r.authMessageType,
                  promptMessage: r.authMessage,
                ),
              );
            case AuthMessageType.visible:
              return emit(
                state.copyWith(
                  status: GreetdStatus.visible,
                  promptType: r.authMessageType,
                  promptMessage: r.authMessage,
                ),
              );
            case AuthMessageType.info:
            case AuthMessageType.error:
              break;
          }
        }
      }

      clearSession();
      return emit(
        state.copyWith(
          status: GreetdStatus.unknown,
          promptType: r.authMessageType,
          promptMessage: r.authMessage,
          error: 'Unknown AuthMessageType ${r.authMessageType} !',
        ),
      );
    } else if (r is SuccessResponse) {
      emit(state.copyWith(status: GreetdStatus.success));
      if (_request == PostAuthResponse) {
        final cmd = _cmd;
        if (cmd != null) {
          return add(StartSession(cmd: cmd, env: _env));
        } else {
          return emit(
            state.copyWith(
              status: GreetdStatus.error,
              error: 'Cannot start session, No valid cmd line found !',
            ),
          );
        }
      }

      if (_request == CancelSession) {
        clearSession();
        return emit(state.copyWith(status: GreetdStatus.cancelled));
      }

      if (_request == StartSession) {
        clearSession();
        return emit(state.copyWith(status: GreetdStatus.exit));
      }
    } else if (r is ErrorResponse) {
      clearSession();
      return emit(
        state.copyWith(status: GreetdStatus.error, error: r.description),
      );
    }
    clearSession();
    return emit(
      state.copyWith(
        status: GreetdStatus.unknown,
        error: 'Unknown GreetdResponse ${r.type} !',
      ),
    );
  }

  void _onErrorReceived(ErrorReceived event, Emitter<GreetdState> emit) {
    clearSession();
    emit(
      state.copyWith(
        status: GreetdStatus.error,
        error: event.error,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _close();
    return super.close();
  }

  void clearSession() {
    _password = null;
    _cmd = null;
    _env = const [];
  }

  Future<void> _close() async {
    // clearStopwatch();
    clearSession();
    await _responsesSubscription.cancel();
    await repository.disconnect();
  }
}

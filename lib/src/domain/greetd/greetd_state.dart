part of 'greetd_bloc.dart';

enum GreetdStatus {
  initial,
  connected,
  loading,
  unknown,
  success,
  error,
  authError,
  authInfo,
  cancelled,
  secret,
  autoSecret,
  visible,
  exit,
}

class GreetdState extends Equatable {
  const GreetdState({
    required this.status,
    required this.username,
    this.error,
    this.promptType,
    this.promptMessage,
  });

  factory GreetdState.initial() => const GreetdState(
    status: GreetdStatus.initial,
    username: '',
  );
  final GreetdStatus status;
  final String username;
  final String? error;
  final AuthMessageType? promptType;
  final String? promptMessage;

  GreetdState copyWith({
    GreetdStatus? status,
    String? username,
    String? error,
    AuthMessageType? promptType,
    String? promptMessage,
  }) {
    return GreetdState(
      status: status ?? this.status,
      username: username ?? this.username,
      error: error,
      promptType: promptType,
      promptMessage: promptMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    username,
    error,
    promptType,
    promptMessage,
  ];
}

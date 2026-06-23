part of 'greetd_bloc.dart';

abstract class GreetdEvent extends Equatable {
  const GreetdEvent();
  @override
  List<Object?> get props => [];
}

class CreateStartableSession extends GreetdEvent {
  const CreateStartableSession({
    required this.username,
    required this.password,
    required this.cmd,
    this.env = const [],
  });

  final String username;
  final String password;
  final List<String> cmd;
  final List<String> env;
  @override
  List<Object?> get props => [username, password, cmd, env];
}

class CreateAuthSession extends GreetdEvent {
  const CreateAuthSession({required this.username, required this.password});
  final String username;
  final String password;
  @override
  List<Object?> get props => [username, password];
}

class CreateSession extends GreetdEvent {
  const CreateSession(this.username);
  final String username;
  @override
  List<Object?> get props => [username];
}

class PostAuthResponse extends GreetdEvent {
  const PostAuthResponse(this.password);
  final String password;
  @override
  List<Object?> get props => [password];
}

class StartSession extends GreetdEvent {
  const StartSession({required this.cmd, this.env = const []});
  final List<String> cmd;
  final List<String> env;
  @override
  List<Object?> get props => [cmd, env];
}

class CancelSession extends GreetdEvent {
  const CancelSession();
}

@visibleForTesting
class Connect extends GreetdEvent {
  const Connect();
}

@visibleForTesting
class ResponseReceived extends GreetdEvent {
  const ResponseReceived(this.response);
  final GreetdResponse response;
  @override
  List<Object?> get props => [response];
}

@visibleForTesting
class ErrorReceived extends GreetdEvent {
  const ErrorReceived(this.error);
  final String error;
  @override
  List<Object?> get props => [error];
}

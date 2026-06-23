import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum GreetdCommand {
  createSession,
  postAuthMessageResponse,
  startSession,
  cancelSession,
}

@JsonEnum()
enum AuthMessageType {
  visible,
  secret,
  info,
  error,
}

@JsonEnum(fieldRename: FieldRename.snake)
enum ErrorType {
  // @JsonKey(name: 'auth_error') too bad :_(
  authError,
  error,
}

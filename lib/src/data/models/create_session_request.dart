import 'package:greetd_ipc/src/data/models/greetd_enumeration.dart'
    show GreetdCommand;
import 'package:greetd_ipc/src/data/models/greetd_request.dart'
    show GreetdRequest;
import 'package:json_annotation/json_annotation.dart' show JsonSerializable;

part 'create_session_request.g.dart';

@JsonSerializable()
class CreateSessionRequest extends GreetdRequest {
  const CreateSessionRequest(this.username, {this.type = 'create_session'});

  factory CreateSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSessionRequestFromJson(json);
  final String type;
  final String username;

  @override
  GreetdCommand get command => GreetdCommand.createSession;

  @override
  Map<String, dynamic> toJson() => _$CreateSessionRequestToJson(this);

  @override
  List<Object?> get props => [type, username];
}

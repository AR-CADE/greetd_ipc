import 'package:greetd_ipc/greetd_ipc.dart' show GreetdRequest;
import 'package:greetd_ipc/src/data/models/greetd_enumeration.dart'
    show GreetdCommand;
import 'package:json_annotation/json_annotation.dart' show JsonSerializable;

part 'start_session_request.g.dart';

@JsonSerializable()
class StartSessionRequest extends GreetdRequest {
  const StartSessionRequest({
    required this.cmd,
    this.env = const [],
    this.type = 'start_session',
  });

  factory StartSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$StartSessionRequestFromJson(json);
  final String type;
  final List<String> cmd;
  final List<String> env;

  @override
  GreetdCommand get command => GreetdCommand.startSession;

  @override
  Map<String, dynamic> toJson() => _$StartSessionRequestToJson(this);

  @override
  List<Object?> get props => [type, cmd, env];
}

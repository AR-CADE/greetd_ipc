import 'package:greetd_ipc/src/data/models/greetd_enumeration.dart'
    show GreetdCommand;
import 'package:greetd_ipc/src/data/models/greetd_request.dart'
    show GreetdRequest;
import 'package:json_annotation/json_annotation.dart' show JsonSerializable;

part 'cancel_session_request.g.dart';

@JsonSerializable()
class CancelSessionRequest extends GreetdRequest {
  const CancelSessionRequest({this.type = 'cancel_session'});

  factory CancelSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelSessionRequestFromJson(json);
  final String type;

  @override
  GreetdCommand get command => GreetdCommand.cancelSession;

  @override
  Map<String, dynamic> toJson() => _$CancelSessionRequestToJson(this);

  @override
  List<Object?> get props => [type];
}

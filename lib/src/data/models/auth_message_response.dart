import 'package:greetd_ipc/src/data/models/greetd_enumeration.dart'
    show AuthMessageType;
import 'package:greetd_ipc/src/data/models/greetd_response.dart'
    show GreetdResponse;
import 'package:json_annotation/json_annotation.dart';

part 'auth_message_response.g.dart';

@JsonSerializable()
class AuthMessageResponse extends GreetdResponse {
  const AuthMessageResponse({
    required this.authMessageType,
    required this.authMessage,
    this.type = 'auth_message',
  });

  factory AuthMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthMessageResponseFromJson(json);

  @override
  final String type;
  @JsonKey(name: 'auth_message_type')
  final AuthMessageType authMessageType;
  @JsonKey(name: 'auth_message')
  final String authMessage;

  @override
  Map<String, dynamic> toJson() => _$AuthMessageResponseToJson(this);

  @override
  List<Object?> get props => [type, authMessageType, authMessage];
}

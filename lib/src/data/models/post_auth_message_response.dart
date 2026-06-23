import 'package:greetd_ipc/src/data/models/greetd_enumeration.dart'
    show GreetdCommand;
import 'package:greetd_ipc/src/data/models/greetd_request.dart'
    show GreetdRequest;
import 'package:json_annotation/json_annotation.dart' show JsonSerializable;

part 'post_auth_message_response.g.dart';

@JsonSerializable()
class PostAuthMessageResponse extends GreetdRequest {
  const PostAuthMessageResponse(
    this.response, {
    this.type = 'post_auth_message_response',
  });

  factory PostAuthMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$PostAuthMessageResponseFromJson(json);
  final String type;
  final String? response;

  @override
  GreetdCommand get command => GreetdCommand.postAuthMessageResponse;

  @override
  Map<String, dynamic> toJson() => _$PostAuthMessageResponseToJson(this);

  @override
  List<Object?> get props => [type, response];
}

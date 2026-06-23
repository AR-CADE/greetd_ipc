import 'package:greetd_ipc/greetd_ipc.dart' show GreetdResponse;
import 'package:json_annotation/json_annotation.dart' show JsonSerializable;

part 'success_response.g.dart';

@JsonSerializable()
class SuccessResponse extends GreetdResponse {
  const SuccessResponse({this.type = 'success'});

  factory SuccessResponse.fromJson(Map<String, dynamic> json) =>
      _$SuccessResponseFromJson(json);

  @override
  final String type;

  @override
  Map<String, dynamic> toJson() => _$SuccessResponseToJson(this);

  @override
  List<Object?> get props => [type];
}

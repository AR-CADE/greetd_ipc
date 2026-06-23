import 'package:greetd_ipc/src/data/models/greetd_enumeration.dart'
    show ErrorType;
import 'package:greetd_ipc/src/data/models/greetd_response.dart'
    show GreetdResponse;
import 'package:json_annotation/json_annotation.dart';

part 'error_response.g.dart';

@JsonSerializable()
class ErrorResponse extends GreetdResponse {
  const ErrorResponse({
    required this.errorType,
    required this.description,
    this.type = 'error',
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);
  @override
  final String type;
  @JsonKey(name: 'error_type')
  final ErrorType errorType;
  final String description;

  @override
  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);

  @override
  List<Object?> get props => [type, errorType, description];
}

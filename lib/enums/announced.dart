import 'package:json_annotation/json_annotation.dart';

enum Announced {
  @JsonValue("nothing")
  NOTHING,
  @JsonValue("Tichu")
  TICHU,
  @JsonValue("Grand Tichu")
  GRAND_TICHU
}

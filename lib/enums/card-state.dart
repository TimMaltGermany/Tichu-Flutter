import 'package:json_annotation/json_annotation.dart';

enum CardState {
  @JsonValue("on hand") ON_HAND,
  @JsonValue("on schupf area before") ON_SCHUPF_AREA_BEFORE,
  @JsonValue("on schupf area after") ON_SCHUPF_AREA_AFTER,
  @JsonValue("on schupf area partner") ON_SCHUPF_AREA_PARTNER,
  @JsonValue("on table to be played") ON_TABLE_TO_BE_PLAYED,
  @JsonValue("on table played") ON_TABLE_PLAYED,
  @JsonValue("off table") OFF_TABLE
}



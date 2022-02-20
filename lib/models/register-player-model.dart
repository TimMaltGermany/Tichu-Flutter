import 'package:flutter/foundation.dart';
import 'package:tichu/game-utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:json_annotation/json_annotation.dart';

// use 'flutter pub run build_runner build_runner' to re-generate
part 'register-player-model.g.dart';

@JsonSerializable()
class RegisterPlayerModel extends ChangeNotifier {
  late SharedPreferences _prefs;

  /// team currently selected by the user
  String team = '';
  /// player (display) name
  String name = '';
  String _token = "invalid";

  @JsonKey(ignore: true)
  String _serverIp = '10.0.2.2';

  int seat = -1;

  RegisterPlayerModel() {
    initialize();
  }

  initialize() async {
    _prefs = await SharedPreferences.getInstance();
    name = _getValue(GameUtils.USERNAME_KEY, '');
    _serverIp = _getValue('serverIp', '10.0.2.2');
  }

  /// authorization token returned after login
  String get token => _token;

  setName(String name) {
    print("setting name from ${this.name} to $name");
    this.name = name;
    if (name.length > 0) {
      _saveStringValue(GameUtils.USERNAME_KEY, name);
    }
    notifyListeners();
  }

  String get serverIp => _serverIp;

  set serverIp(String? serverIp) {
    if (serverIp != null && serverIp.isNotEmpty) {
      _serverIp = serverIp;
      _saveStringValue('serverIp', serverIp);
      notifyListeners();
    }
  }

  void setTeam(String newTeam) {
    team = newTeam;
    notifyListeners();
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  bool hasTeamSelected() {
    return team.isNotEmpty;
  }

  void resetSelection() {
    team = '';
    notifyListeners();
  }

  bool isValidToken() {
    return _token.length > 16;
  }

  void _saveIntValue(String key, int value) {
    _prefs.setInt(key, value);
  }

  void _saveStringValue(String key, String value) {
    _prefs.setString(key, value);
  }

  T _getValue<T>(key, T defaultValue) {
    if (_prefs.containsKey(key)) {
      return _prefs.get(key) as T;
    }
    return defaultValue;
  }

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory RegisterPlayerModel.fromJson(Map<String, dynamic> json) => _$RegisterPlayerModelFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$RegisterPlayerModelToJson(this);

}

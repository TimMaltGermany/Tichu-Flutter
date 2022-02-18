import 'package:web_socket_channel/web_socket_channel.dart';

import 'dart:convert';
import 'dart:ui';

class GameUtils {
  static const BACKGROUND_COLOR = Color.fromRGBO(56, 87, 35, 1);

  static const BACKGROUND_IMAGE = 'bg/table-with-cards.png';

  static const CARD_HEIGHT = 96.0;
  static const CARD_WIDTH = 62.0;

  static const CARD_BACKSIDE = 'cards/backside.png';

  static const USERNAME_KEY = 'username';

  static const List<String> teamNames = [
    'Bonn',
    'Darmstadt',
    'Hamburg',
    'Team KD',
    'Team AD',
    'Team AB',
    'Team FD',
    'Koblenz',
    'FloMax',
    'Team MK',
    'Tichunisten',
    'Doppelsieger'
  ];

  static const PORT = 7001;
}

void sendMessage(WebSocketChannel channel, String cmd, Object message) {
  String encodedMessage = jsonEncode({'cmd': cmd, 'data': message});
  channel.sink.add(encodedMessage);
}

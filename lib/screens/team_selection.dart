import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tichu/game-utils.dart';
import 'package:tichu/models/register-player-model.dart';

class TeamSelection extends StatefulWidget {

  @override
  _TeamSelectionState createState() => _TeamSelectionState();
}

class _TeamSelectionState extends State<TeamSelection> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    String title = context.read<RegisterPlayerModel>().name + '- select your team';
    return Scaffold(
        appBar: AppBar(
            title: Text(title,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            backgroundColor: GameUtils.BACKGROUND_COLOR),
        body:
        ListView.builder(
            itemCount: GameUtils.teamNames.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: ListTile(
                  selected: selectedIndex == index? true: false,
                  selectedTileColor: Colors.blue[100],
                  title: Text(GameUtils.teamNames[index]),
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    context.read<RegisterPlayerModel>().setTeam(GameUtils.teamNames[index]);
                    Navigator.pushNamed(context, '/play');
                  },
                ),
              );
            }
        )
    );
  }
}

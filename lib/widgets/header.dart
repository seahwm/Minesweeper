import 'package:flutter/material.dart';

import '../global/game_state.dart';

const List<String> difficulty = <String>['Easy'];

class Header extends StatefulWidget {
  final void Function() ontrigger;
  const Header(this.ontrigger);

  @override
  State<StatefulWidget> createState() {
    return HeaderState();
  }
}

class HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mine: ${currentBomb}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          DropdownButton<Difficulty>(
            value: currentDifficulty,
            items:
                Difficulty.values.map<DropdownMenuItem<Difficulty>>((
                  Difficulty value,
                ) {
                  return DropdownMenuItem<Difficulty>(
                    value: value,
                    child: Text(value.toString()), // Extract enum name
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                if(currentDifficulty!=value){
                  currentDifficulty = value!;
                  widget.ontrigger();
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

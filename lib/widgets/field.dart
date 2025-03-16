import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:minesweeper/global/game_state.dart';

class Field extends StatelessWidget {
  final FieldState status;
  final clickedColor = Colors.black12;
  final defaultColor = Colors.black26;

  const Field(this.status);

  @override
  Widget build(BuildContext context) {
    return status.isFlag
        ?
        // Flag Style
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: Colors.grey,
          ),
          child: Center(
            child: FittedBox(child: Icon(Icons.flag, color: Colors.red)),
          ),
        )
        : status.clicked
        ? !status.isBomb
            ?
            // Normal Clicked
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: clickedColor,
              ),
              child: Center(
                child:
                    status.boomCount == null
                        ? null
                        : FittedBox(
                          child: Text(
                            status.boomCount.toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
              ),
            )
            :
            // Bomb Style
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: clickedColor,
              ),
              child: Center(
                child: FittedBox(
                  child: Icon(Symbols.bomb, color: Colors.black),
                ),
              ),
            )
        :
        // Normal havent click
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: defaultColor,
          ),
        );
  }
}

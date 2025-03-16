import 'package:flutter/material.dart';
import 'package:minesweeper/global/game_state.dart';
import 'package:minesweeper/widgets/field.dart';
import 'package:minesweeper/widgets/header.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minesweeper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: MyHomePage(title: 'Minesweeper'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool firstClick = true;
  bool end = false;
  bool win = false;
  List<FieldState> fieldList = List.generate(
    configMap[currentDifficulty]!.width * configMap[currentDifficulty]!.height,
    (index) => FieldState(false),
  );
  bool isSetFlag = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Header(restart),
          GridView.count(
            shrinkWrap: true,
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisCount: configMap[currentDifficulty]!.width,
            children: <Widget>[
              for (
                var i = 0;
                i <
                    configMap[currentDifficulty]!.width *
                        configMap[currentDifficulty]!.height;
                i++
              )
                InkWell(
                  onTap: () {
                    setState(() {
                      onClick(i);
                    });
                  },
                  child: Field(fieldList[i]),
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 20),
              Icon(Icons.flag),
              Switch(
                value: isSetFlag,
                onChanged:
                    (value) => setState(() {
                      isSetFlag = value;
                    }),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton:
          end || win
              ? FloatingActionButton(
                onPressed: restart,
                tooltip: 'Restart',
                child: const Icon(Icons.replay),
              )
              : null, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /// Initialize bomb position, the pass in index is the first click index,
  /// should not place bomb in that index
  void initBomb(int index) {
    int remainingBomb = totalBomb;
    while (remainingBomb != 0) {
      int randomNumber = random.nextInt(
        configMap[currentDifficulty]!.width *
            configMap[currentDifficulty]!.height,
      );
      if (randomNumber != index && !fieldList[randomNumber].isBomb) {
        fieldList[randomNumber].isBomb = true;
        remainingBomb--;
      }
    }
  }

  /// Find the surrounded bomb count
  int? findBomb(int i) {
    int count = 0;
    final maxWidth =
        configMap[currentDifficulty]!.width *
        configMap[currentDifficulty]!.height;
    // Left
    if (i % configMap[currentDifficulty]!.width != 0 &&
        i - 1 >= 0 &&
        fieldList[i - 1].isBomb) {
      count++;
    }

    // Right
    if (i % configMap[currentDifficulty]!.width !=
            configMap[currentDifficulty]!.width - 1 &&
        i + 1 < maxWidth &&
        fieldList[i + 1].isBomb) {
      count++;
    }

    // Up
    if (i - configMap[currentDifficulty]!.width >= 0 &&
        fieldList[i - configMap[currentDifficulty]!.width].isBomb) {
      count++;
    }

    // Up Left
    if (i % configMap[currentDifficulty]!.width != 0 &&
        i - configMap[currentDifficulty]!.width - 1 >= 0 &&
        fieldList[i - configMap[currentDifficulty]!.width - 1].isBomb) {
      count++;
    }

    // Up Right
    if (i % configMap[currentDifficulty]!.width !=
            configMap[currentDifficulty]!.width - 1 &&
        i - configMap[currentDifficulty]!.width + 1 >= 0 &&
        fieldList[i - configMap[currentDifficulty]!.width + 1].isBomb) {
      count++;
    }

    // Down
    if (i + configMap[currentDifficulty]!.width < maxWidth &&
        fieldList[i + configMap[currentDifficulty]!.width].isBomb) {
      count++;
    }

    // Down Left
    if (i % configMap[currentDifficulty]!.width != 0 &&
        i + configMap[currentDifficulty]!.width - 1 < maxWidth &&
        fieldList[i + configMap[currentDifficulty]!.width - 1].isBomb) {
      count++;
    }

    // Down Right
    if (i % configMap[currentDifficulty]!.width !=
            configMap[currentDifficulty]!.width - 1 &&
        i + configMap[currentDifficulty]!.width + 1 < maxWidth &&
        fieldList[i + configMap[currentDifficulty]!.width + 1].isBomb) {
      count++;
    }

    return count == 0 ? null : count;
  }

  void onClick(int i) {
    if (fieldList[i].clicked) {
      if (isSetFlag) {
        return;
      }
      openAll(i);
      return;
    }

    if (end || win) {
      return;
    }

    if (isSetFlag) {
      setState(() {
        fieldList[i].isFlag = !fieldList[i].isFlag;
        currentBomb += fieldList[i].isFlag ? -1 : 1;
      });
      return;
    }
    if (fieldList[i].isFlag) {
      return;
    }
    if (firstClick) {
      initBomb(i);
      firstClick = false;
    }

    fieldList[i].clicked = true;
    if (fieldList[i].isBomb) {
      end = true;
      onGameEnd();
      return;
    } else {
      int? count = findBomb(i);
      fieldList[i].boomCount = count;

      //if surrounded is not boom, help to click all surrounded field
      if (count == null) {
        List<int> surrondedFld = [];
        // Left
        if (i % configMap[currentDifficulty]!.width != 0 && i - 1 >= 0) {
          surrondedFld.add(i - 1);
        }

        // Right
        if (i % configMap[currentDifficulty]!.width !=
                configMap[currentDifficulty]!.width - 1 &&
            i + 1 <
                configMap[currentDifficulty]!.width *
                    configMap[currentDifficulty]!.height) {
          surrondedFld.add(i + 1);
        }

        // Up
        if (i - configMap[currentDifficulty]!.width >= 0) {
          surrondedFld.add(i - configMap[currentDifficulty]!.width);
        }

        // Up Left
        if (i % configMap[currentDifficulty]!.width != 0 &&
            i - configMap[currentDifficulty]!.width - 1 >= 0) {
          surrondedFld.add(i - configMap[currentDifficulty]!.width - 1);
        }

        // Up Right
        if (i % configMap[currentDifficulty]!.width !=
                configMap[currentDifficulty]!.width - 1 &&
            i - configMap[currentDifficulty]!.width + 1 >= 0) {
          surrondedFld.add(i - configMap[currentDifficulty]!.width + 1);
        }

        // Down
        if (i + configMap[currentDifficulty]!.width <
            configMap[currentDifficulty]!.width *
                configMap[currentDifficulty]!.height) {
          surrondedFld.add(i + configMap[currentDifficulty]!.width);
        }

        // Down Left
        if (i % configMap[currentDifficulty]!.width != 0 &&
            i + configMap[currentDifficulty]!.width - 1 <
                configMap[currentDifficulty]!.width *
                    configMap[currentDifficulty]!.height) {
          surrondedFld.add(i + configMap[currentDifficulty]!.width - 1);
        }

        // Down Right
        if (i % configMap[currentDifficulty]!.width !=
                configMap[currentDifficulty]!.width - 1 &&
            i + configMap[currentDifficulty]!.width + 1 <
                configMap[currentDifficulty]!.width *
                    configMap[currentDifficulty]!.height) {
          surrondedFld.add(i + configMap[currentDifficulty]!.width + 1);
        }
        for (var index in surrondedFld) {
          setState(() {
            onClick(index);
          });
        }
      }
    }
    checkWin();
  }

  void checkWin() {
    win =
        fieldList.where((field) => field.clicked).toList().length ==
        configMap[currentDifficulty]!.width *
                configMap[currentDifficulty]!.height -
            configMap[currentDifficulty]!.totalBomb;
    onGameEnd();
  }

  void onGameEnd() {
    if (end || win) {
      String content = win ? "Congratulation!!!" : "You Lose Noob";
      var snackBar = SnackBar(content: Text(content));

      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void restart() {
    setState(() {
      firstClick = true;
      end = false;
      win = false;
      totalBomb = configMap[currentDifficulty]!.totalBomb;
      currentBomb = totalBomb;
      fieldList = List.generate(
        configMap[currentDifficulty]!.width *
            configMap[currentDifficulty]!.height,
        (index) => FieldState(false),
      );
      isSetFlag = false;
    });
  }

  void openAll(int i) {
    if (fieldList[i].boomCount == null) {
      return;
    }
    int count = 0;
    final maxWidth =
        configMap[currentDifficulty]!.width *
        configMap[currentDifficulty]!.height;
    // Left
    if (i % configMap[currentDifficulty]!.width != 0 &&
        i - 1 >= 0 &&
        fieldList[i - 1].isFlag) {
      count++;
    }

    // Right
    if (i % configMap[currentDifficulty]!.width !=
            configMap[currentDifficulty]!.width - 1 &&
        i + 1 < maxWidth &&
        fieldList[i + 1].isFlag) {
      count++;
    }

    // Up
    if (i - configMap[currentDifficulty]!.width >= 0 &&
        fieldList[i - configMap[currentDifficulty]!.width].isFlag) {
      count++;
    }

    // Up Left
    if (i % configMap[currentDifficulty]!.width != 0 &&
        i - configMap[currentDifficulty]!.width - 1 >= 0 &&
        fieldList[i - configMap[currentDifficulty]!.width - 1].isFlag) {
      count++;
    }

    // Up Right
    if (i % configMap[currentDifficulty]!.width !=
            configMap[currentDifficulty]!.width - 1 &&
        i - configMap[currentDifficulty]!.width + 1 >= 0 &&
        fieldList[i - configMap[currentDifficulty]!.width + 1].isFlag) {
      count++;
    }

    // Down
    if (i + configMap[currentDifficulty]!.width < maxWidth &&
        fieldList[i + configMap[currentDifficulty]!.width].isFlag) {
      count++;
    }

    // Down Left
    if (i % configMap[currentDifficulty]!.width != 0 &&
        i + configMap[currentDifficulty]!.width - 1 < maxWidth &&
        fieldList[i + configMap[currentDifficulty]!.width - 1].isFlag) {
      count++;
    }

    // Down Right
    if (i % configMap[currentDifficulty]!.width !=
            configMap[currentDifficulty]!.width - 1 &&
        i + configMap[currentDifficulty]!.width + 1 < maxWidth &&
        fieldList[i + configMap[currentDifficulty]!.width + 1].isFlag) {
      count++;
    }

    //--------------------------CLick all
    if (count == fieldList[i].boomCount) {
      // Left
      if (i % configMap[currentDifficulty]!.width != 0 &&
          i - 1 >= 0 &&
          !fieldList[i - 1].isFlag &&
          !fieldList[i - 1].clicked) {
        onClick(i - 1);
      }

      // Right
      if (i % configMap[currentDifficulty]!.width !=
              configMap[currentDifficulty]!.width - 1 &&
          i + 1 < maxWidth &&
          !fieldList[i + 1].isFlag &&
          !fieldList[i + 1].clicked) {
        onClick(i + 1);
      }

      // Up
      if (i - configMap[currentDifficulty]!.width >= 0 &&
          !fieldList[i - configMap[currentDifficulty]!.width].isFlag &&
          !fieldList[i - configMap[currentDifficulty]!.width].clicked) {
        onClick(i - configMap[currentDifficulty]!.width);
      }

      // Up Left
      if (i % configMap[currentDifficulty]!.width != 0 &&
          i - configMap[currentDifficulty]!.width - 1 >= 0 &&
          !fieldList[i - configMap[currentDifficulty]!.width - 1].isFlag &&
          !fieldList[i - configMap[currentDifficulty]!.width - 1].clicked) {
        onClick(i - configMap[currentDifficulty]!.width - 1);
      }

      // Up Right
      if (i % configMap[currentDifficulty]!.width !=
              configMap[currentDifficulty]!.width - 1 &&
          i - configMap[currentDifficulty]!.width + 1 >= 0 &&
          !fieldList[i - configMap[currentDifficulty]!.width + 1].isFlag &&
          !fieldList[i - configMap[currentDifficulty]!.width + 1].clicked) {
        onClick(i - configMap[currentDifficulty]!.width + 1);
      }

      // Down
      if (i + configMap[currentDifficulty]!.width < maxWidth &&
          !fieldList[i + configMap[currentDifficulty]!.width].isFlag &&
          !fieldList[i + configMap[currentDifficulty]!.width].clicked) {
        onClick(i + configMap[currentDifficulty]!.width);
      }

      // Down Left
      if (i % configMap[currentDifficulty]!.width != 0 &&
          i + configMap[currentDifficulty]!.width - 1 < maxWidth &&
          !fieldList[i + configMap[currentDifficulty]!.width - 1].isFlag &&
          !fieldList[i + configMap[currentDifficulty]!.width - 1].clicked) {
        onClick(i + configMap[currentDifficulty]!.width - 1);
      }

      // Down Right
      if (i % configMap[currentDifficulty]!.width !=
              configMap[currentDifficulty]!.width - 1 &&
          i + configMap[currentDifficulty]!.width + 1 < maxWidth &&
          !fieldList[i + configMap[currentDifficulty]!.width + 1].isFlag &&
          !fieldList[i + configMap[currentDifficulty]!.width + 1].clicked) {
        onClick(i + configMap[currentDifficulty]!.width + 1);
      }
    }
  }
}

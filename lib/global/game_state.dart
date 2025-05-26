import 'dart:math';

enum Difficulty { EASY, MEDIUM }

var totalBomb = 10;

var configMap = {
  Difficulty.EASY: GameConfig(9, 9, 10),
  Difficulty.MEDIUM: GameConfig(16, 16, 40),
};

var currentDifficulty = Difficulty.EASY;

var currentBomb = totalBomb;
Random random = Random();

class GameConfig {
  final int width;
  final int height;
  final int totalBomb;

  GameConfig(this.width, this.height, this.totalBomb);
}

class FieldState {
  bool clicked;
  bool isBomb;
  bool isFlag;
  int? boomCount;

  FieldState(this.isFlag, {this.clicked = false, this.isBomb = false});
}

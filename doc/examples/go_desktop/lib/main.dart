import 'package:flame/game/game_widget.dart';
import 'package:flutter/material.dart';

import './game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}

import 'package:flutter/rendering.dart';

import 'package:flutter/widgets.dart' hide WidgetBuilder;

import 'game.dart';
import 'game_render_box.dart';

class EmbeddedGameWidget extends LeafRenderObjectWidget {
  final Game game;

  EmbeddedGameWidget(this.game);

  @override
  RenderBox createRenderObject(BuildContext context) {
    return RenderConstrainedBox(
      child: GameRenderBox(context, game),
      additionalConstraints: const BoxConstraints.expand(),
    );
  }
}

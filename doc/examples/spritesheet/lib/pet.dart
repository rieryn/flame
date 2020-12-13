//bunny behavior is
//wander, move back if leash exceeded, attack if collision

import 'package:flame/components/sprite_animation_component.dart';
import 'package:flame/sprite_animation.dart';
import 'package:vector_math/vector_math_64.dart';

class Pet extends SpriteAnimationComponent{
  Pet(Vector2 size, SpriteAnimation animation) : super(size, animation);


}
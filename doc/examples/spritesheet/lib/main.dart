import 'dart:math';

import 'package:flame/components/particle_component.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flame/components/sprite_component.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/particle.dart';
import 'package:flame/particles/circle_particle.dart';
import 'package:flame/sprite_animation.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/material.dart';
import 'package:spritesheet/red_warrior.dart';
import 'package:flame/sprite.dart';
import 'package:spritesheet/slime.dart';
import 'doppelganger.dart';
import 'ghost.dart';
import 'monster.dart';
import 'demon.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyGame().widget);
}
Particle gradientParticles() {
  Color color = Colors.redAccent;
  double opacity = 0.5;
  const offset = const Offset(10,10);
  var gradient = RadialGradient(
    colors: [
      Color.fromRGBO(
            color.red, color.green, color.blue, opacity),
      Color.fromRGBO(
          color.red, color.green, color.blue,  opacity/2),
    ],
    stops: const [0.0, 0.5],
  );
  final Paint painter = Paint()
    ..style = PaintingStyle.fill
    ..shader = gradient.createShader(
        Rect.fromCircle(center: offset, radius: 2));
  return CircleParticle(
    paint: painter,
  );
}

class BoundingBox{
  final double leftBound = -50;
  final double rightBound = 300;
  final double topBound = 50;
  final double bottomBound = 250; //what you can do that?
}

class MyGame extends BaseGame with TapDetector {
  Particle g;
  SpriteAnimation debugAnimation;
  ParticleComponent particle;
  BoundingBox boundingBox = BoundingBox();
  RedWarrior redwarrior;
  Monster demon;
  Demon emon;
  SpriteComponent vampireSpriteComponent;
  SpriteComponent bg;
  @override
  Future<void> onLoad() async {
    List<String> ghost_images = ['ghost_appear.png','ghost_attack.png','ghost_die.png','ghost_idle.png'];
    Flame.images.loadAll(ghost_images);
    Flame.images.load('slime_sheet.png');
    List<String> demon_images = ['demon_attack1.png','demon_attack2.png','demon_idle.png'];
    Flame.images.loadAll(demon_images);

    /*final image = await images.load("snow_a.png");
   final snowbg = Sprite(image, srcSize: Vector2(1145/2,681/2));
   bg =SpriteComponent.fromSprite(Vector2(1145/2,681/2), snowbg);
   add(bg);*/

    final image = await images.load("safe_a.png");
    final snowbg = Sprite(image, srcSize: Vector2(613,489));
    bg =SpriteComponent.fromSprite(Vector2(613,489)*0.7, snowbg);
    //add(bg);
    final warriorSheet = SpriteSheet(
      image: await images.load('warrior_sheet.png'),
      srcSize: Vector2(1110/15, 1998/27),
    );
    final reaperAttacks = SpriteSheet(
      image: await images.load('reaper_attack.png'),
      srcSize: Vector2(100,100),
    );
    final reaperDie = SpriteSheet(
      image: await images.load('reaper_die.png'),
      srcSize: Vector2(100,100),
    );

    final santa_sheet = SpriteSheet(
      image: await images.load('santa_sheet.png'),
      srcSize: Vector2(864/9,2112/22),
    );
    final knight_attack = SpriteSheet(
      image: await images.load('knight_attack.png'),
      srcSize: Vector2(518/7,74),
    );
    final spriteSheet = SpriteSheet(
      image: await images.load('spritesheet.png'),
      srcSize: Vector2(16.0, 18.0),
    );
    final bunnysheet = SpriteSheet(
      image: await images.load('bunny_sheet.png'),
      srcSize: Vector2(220/4, 444/6.0),
    );

    //    ..position = Vector2(200,200);
    //add(redwarrior);

    final bunnyIdle1 = bunnysheet.createAnimation(row: 0, stepTime: 0.1, to: 4);
    final bunnyNibble = bunnysheet.createAnimation(row: 1, stepTime: 0.1, to: 4);
    final bunnyRun = bunnysheet.createAnimation(row: 2, stepTime: 0.1, to: 4);
    final bunnyJump = bunnysheet.createAnimation(row: 3, stepTime: 0.1, to: 4);
    final bunnyAttack = bunnysheet.createAnimation(row: 4, stepTime: 0.1, to: 4);
    final bunnyIdle2 = bunnysheet.createAnimation(row: 5, stepTime: 0.1, to: 3);
    final spriteSize = Vector2(120.0, 120.0*1.3);

 //   final a = ghost_appear.createAnimation(row: 0, stepTime: 0.1, to: 6);
  //  final b = ghost_attack.createAnimation(row: 0, stepTime: 0.1, to: 4);
  //  final c = ghost_die.createAnimation(row: 0, stepTime: 0.1, to: 7);
  //  final d = ghost_idle.createAnimation(row: 0, stepTime: 0.1, to: 7);
  //  final e = santa_sheet.createAnimation(row: 0, stepTime: 0.1, to: 9);


  //  final a = reaperDie.createAnimation(row: 0, stepTime: 0.1, to: 10);
  //  final b = reaperAttacks.createAnimation(row: 0, stepTime: 0.1, to: 6);
  //  final c = reaperAttacks.createAnimation(row: 1, stepTime: 0.1, to: 6);
  //  final d = knight_attack.createAnimation(row: 0, stepTime: 0.1, to: 7);
  //  final e = santa_sheet.createAnimation(row: 0, stepTime: 0.1, to: 9);
  //  final f = slime_sheet.createAnimation(row: 0, stepTime: 0.1, to: 8);
  //  final g = slime_sheet.createAnimation(row: 1, stepTime: 0.1, to: 8);
  //  final h = slime_sheet.createAnimation(row: 2, stepTime: 0.1, to: 8);
 //   final d = knight_attack.createAnimation(row: 0, stepTime: 0.1, to: 7);

  //  final demonIdle = demonIdle.createAnimation(row: 0, stepTime: 0.1, to: 6);
   // final demonAttack1 = demonAttack1.createAnimation(row: 0, stepTime: 0.1, to: 8);
//    final demonAttack2 = demonAttack2.createAnimation(row: 0, stepTime: 0.1, to: 11);
  //  final knightAttack = knight_attack.createAnimation(row: 0, stepTime: 0.1, to: 7);
 //   final santaToBox = santa_sheet.createAnimation(row: 0, stepTime: 0.1, to: 9);

    final warriorSpin = warriorSheet.createAnimation(row: 0, stepTime: 0.1, to: 4);
    final warriorWalkDown = warriorSheet.createAnimation(row: 1, stepTime: 0.1, to: 12);
    final warriorWalkSideActive = warriorSheet.createAnimation(row: 2, stepTime: 0.1, to: 12);
    final warriorWalkSidePassive = warriorSheet.createAnimation(row: 3, stepTime: 0.1, to: 12);
    final warriorWalkUp = warriorSheet.createAnimation(row: 4, stepTime: 0.1, to: 12);
    final warriorAttackDown = warriorSheet.createAnimation(row: 5, stepTime: 0.1, to: 10);
    final warriorComboDown = warriorSheet.createAnimation(row: 6, stepTime: 0.1, to: 10);
    final warriorPowerDown = warriorSheet.createAnimation(row: 7, stepTime: 0.1, to: 15);
    final warriorAttackSide = warriorSheet.createAnimation(row: 8, stepTime: 0.1, to: 10);
    final warriorComboSide = warriorSheet.createAnimation(row: 9, stepTime: 0.1, to: 10);
    final warriorPowerSide = warriorSheet.createAnimation(row: 10, stepTime: 0.1, to: 15);
    final warriorAttackSideR = warriorSheet.createAnimation(row: 11, stepTime: 0.1, to: 10);
    final warriorComboSideR = warriorSheet.createAnimation(row: 12, stepTime: 0.1, to: 10);
    final warriorPowerSideR = warriorSheet.createAnimation(row: 13, stepTime: 0.1, to: 15);
    final warriorAttackUp = warriorSheet.createAnimation(row: 14, stepTime: 0.1, to: 10);
    final warriorComboUp = warriorSheet.createAnimation(row: 15, stepTime: 0.1, to: 10);
    final warriorPowerUp = warriorSheet.createAnimation(row: 16, stepTime: 0.1, to: 15);
    final warriorFall = warriorSheet.createAnimation(row: 17, stepTime: 0.1, to: 5);
    final warriorDash = warriorSheet.createAnimation(row: 18, stepTime: 0.1, to: 5);
    final warriorDashR = warriorSheet.createAnimation(row: 19, stepTime: 0.1, to: 5);
    final warriorDashUp = warriorSheet.createAnimation(row: 20, stepTime: 0.1, to: 5);
    final warriorGlowFront = warriorSheet.createAnimation(row: 21, stepTime: 0.1, to: 2);
    final warriorGlowSide = warriorSheet.createAnimation(row: 22, stepTime: 0.1, to: 2);
    final warriorGlowSideR = warriorSheet.createAnimation(row: 23, stepTime: 0.1, to: 2);
    final warriorBlink = warriorSheet.createAnimation(row: 24, stepTime: 0.3, to: 13);
    final warriorFlourish = warriorSheet.createAnimation(row: 25, stepTime: 0.3, to: 15);
    debugAnimation = warriorSheet.createAnimation(row: 26, stepTime: 2, to: 2);

    final aa = SpriteAnimationComponent(spriteSize, bunnyIdle1)
      ..x = 150
      ..y = 220;
    final bb = SpriteAnimationComponent(spriteSize, bunnyIdle1)
      ..x = 150
      ..y = 320;
    final cc = SpriteAnimationComponent(spriteSize, bunnyIdle1)
      ..x = 150
      ..y = 420;
    final dd = SpriteAnimationComponent(spriteSize, bunnyIdle1)
      ..x = 150
      ..y = 520;
    final ee = SpriteAnimationComponent(spriteSize, debugAnimation)
      ..x = 150
      ..y = 620;

    particle = ParticleComponent(particle: gradientParticles());
    add(particle);

add(aa);
add(bb);
add(cc);
    demon = newMonster();
    add(demon);
    add(dd);
     add(ee);

    redwarrior = RedWarrior(warriorSheet,warriorSpin,boundingBox);
    //doppel = Doppelganger(warriorSheet,warriorSpin);

    // Some plain sprites

   add(redwarrior);
    //add(doppel);
   //
    //redwarrior.addChild(this,vampireSpriteComponent);
  print("we made it to the end");
  }
  double ticker= 0;
  double bounces = 0;
  @override
  void update( t){
    redwarrior.enemyBox = null;
    demon.enemyBox = null;
    if(demon.isDead == false){combatHandler(redwarrior,demon);}
    cleanUp();

    super.update(t);
  }
  @override
  void render(Canvas c){
    Paint paint = Paint();
    paint.color=Colors.amber;
    //Rect rect =Rect.fromLTWH(0,0,500,300);
    c.drawRect(demon.hitBox, paint);
    super.render(c);
  }
  //we can extend this by doing like a spatial hash and feeding the player the
  //closest target or closest 2-3 boxes, same for implementing multiplayer
  void combatHandler(RedWarrior redWarrior, Monster monster){
    redwarrior.battle = true;
    targetHandler(redWarrior, monster);
    damageHandler(redWarrior, monster);
  }
  void targetHandler(RedWarrior redWarrior, Monster monster){
    redwarrior.enemyBox = monster.hitBox;
    monster.enemyBox = redwarrior.hitBox;
    redwarrior.enemyPosition = monster.position;
    monster.enemyPosition = redwarrior.position;
  }
  void damageHandler(RedWarrior redWarrior, Monster monster){
    if(redwarrior.collided && monster.collided){
      if(redwarrior.isAttacking){monster.hp-=redwarrior.damage;}
      if(monster.isAttacking&&!redwarrior.invuln){redwarrior.hp-=monster.damage;}
    }
  }
  void cleanUp() async{
    if(demon.cleanup == true){
      redwarrior.enemyBox = null;
      redwarrior.enemyPosition = Vector2(1000,1000);
      redwarrior.battle = false;
      demon.cleanup = false;
      demon.remove();
      await Future<void>.delayed(const Duration(seconds : 5));
      demon = newMonster();
      demon.position = Vector2(200,200);
      add(demon);
      demon.isDead = false;
    }
    if(redwarrior.isDead){
      demon.hitBox = null;
    }
  }
  Monster monster;
  //
  Monster newMonster(){
    print("running newmonter");
    //pick a new monster
    //list the current monsters here so i don't get confused
    //demon, ghost, slime
    var rng = Random();
    int random = rng.nextInt(3);
    print(random);
    switch(random){
      case 0: monster = Slime(debugAnimation, boundingBox, 1, Vector2(100,100));
      break;
      case 1: monster = Ghost(debugAnimation, boundingBox, 1, Vector2(100,100));
      break;
      case 2: monster = Demon(debugAnimation, boundingBox, 1, Vector2(100,100));
      break;
    }
     print("created new component");
     print(monster);
     return monster;
  }




  @override
  void onTap() {
    redwarrior.battle = !redwarrior.battle;
    print("tapped, battle:" + redwarrior.battle.toString());
  }
}

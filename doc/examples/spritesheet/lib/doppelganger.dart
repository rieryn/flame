import 'dart:ui';

import 'package:flame/components/position_component.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flame/sprite_animation.dart';
import 'package:flame/spritesheet.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flame/flame.dart';

enum State {
  running,
  attacking,
  sliding,
  dying,
  dead,
}
//only 4-6 inputs, so a simple switch is fine
enum Input {
  attack,//do an attack animation
  comboAttack,
  useItem,
  none, //null
}

class Doppelganger extends SpriteAnimationComponent {
  final leftBound = -50;
  final rightBound = 300;
  final topBound = 100;
  final bottomBound = 300;
  //init vars
  final Vector2 startPosition = Vector2(300,100);
  Map<String, SpriteAnimation> animations;
  final double deflation = 40;
  //ticker vars, these are read by the states so we just modify them to control the behavior
  //todo: check if components can be accessed from outside basegame
  @override
  Vector2 position = Vector2(300,100);
  @override
  Vector2 size = Vector2(190,180);
  double stepTime = 0.1; //steptime: warriorFlourish? *3 warriorDie? *20
  Input input = Input.none;
  bool enableInput = true;
  bool combo1 = true;       //combo attacks unlocked
  bool combo2 = true;       //todo:set to false after testing
  bool combo3 = true;
  bool battle = false;      //battle location
  bool safe = false;        //safe location
  bool collided = false;    //collision state
  Rect hitBox;
  Rect enemyBox;
  Vector2 enemyPosition = Vector2(0,0);
  bool enemyDead = false;
  bool interruptible = true; //if the animation can be cancelled
  Vector2 velocity = Vector2(0,0);
  Vector2 acceleration = Vector2(0,0);
  Vector2 directionToTarget = Vector2(0,0);
  double speed = 0.02;
  Doppelganger(SpriteSheet warriorSheet, SpriteAnimation animation) : super(Vector2(190,180),  animation) {
    print("loading warrior component");

    //process spritesheet
    animations = {
      "warriorSpin" : warriorSheet.createAnimation(row: 0, stepTime: 0.1, to: 4,loop:false),
      'warriorWalkDown': warriorSheet.createAnimation(row: 1, stepTime: 0.1, to: 12,loop:false),
      'warriorWalkSideActive': warriorSheet.createAnimation(row: 2, stepTime: 0.1, to: 12,loop:false),
      'warriorWalkSidePassive' : warriorSheet.createAnimation(row: 3, stepTime: 0.1, to: 12,loop:false),
      'warriorWalkUp' : warriorSheet.createAnimation(row: 4, stepTime: 0.1, to: 12,loop:false),
      'warriorAttackDown' : warriorSheet.createAnimation(row: 5, stepTime: 0.1, to: 10,loop:false),
      'warriorComboDown' : warriorSheet.createAnimation(row: 6, stepTime: 0.1, to: 10,loop:false),
      'warriorPowerDown' : warriorSheet.createAnimation(row: 7, stepTime: 0.1, to: 15,loop:false),
      'warriorAttackSide' : warriorSheet.createAnimation(row: 8, stepTime: 0.1, to: 10,loop:false),
      'warriorComboSide' : warriorSheet.createAnimation(row: 9, stepTime: 0.1, to: 10,loop:false),
      'warriorPowerSide' : warriorSheet.createAnimation(row: 10, stepTime: 0.1, to: 15,loop:false),
      'warriorAttackSideR' : warriorSheet.createAnimation(row: 11, stepTime: 0.1, to: 10,loop:false),
      'warriorComboSideR' : warriorSheet.createAnimation(row: 12, stepTime: 0.1, to: 10,loop:false),
      'warriorPowerSideR' : warriorSheet.createAnimation(row: 13, stepTime: 0.1, to: 15,loop:false),
      'warriorAttackUp' : warriorSheet.createAnimation(row: 14, stepTime: 0.1, to: 10,loop:false),
      'warriorComboUp' : warriorSheet.createAnimation(row: 15, stepTime: 0.1, to: 10,loop:false),
      'warriorPowerUp' : warriorSheet.createAnimation(row: 16, stepTime: 0.1, to: 15,loop:false),
      'warriorFall' : warriorSheet.createAnimation(row: 17, stepTime: 0.1, to: 5,loop:false),
      'warriorDash' : warriorSheet.createAnimation(row: 18, stepTime: 0.1, to: 5,loop:false),
      'warriorDashR' : warriorSheet.createAnimation(row: 19, stepTime: 0.1, to: 5,loop:false),
      'warriorDashUp' : warriorSheet.createAnimation(row: 20, stepTime: 0.1, to: 5,loop:false),
      'warriorGlowFront' : warriorSheet.createAnimation(row: 21, stepTime: 0.1, to: 2,loop:false),
      'warriorGlowSide' : warriorSheet.createAnimation(row: 22, stepTime: 0.1, to: 2,loop:false),
      'warriorGlowSideR' : warriorSheet.createAnimation(row: 23, stepTime: 0.1, to: 2,loop:false),
      'warriorBlink' : warriorSheet.createAnimation(row: 24, stepTime: 0.1, to: 13,loop:false),
      'warriorFlourish' : warriorSheet.createAnimation(row: 25, stepTime: 0.3, to: 15,loop:false),
      'warriorDie' : warriorSheet.createAnimation(row: 26, stepTime: 2, to: 2,loop:false),
      //type animation for simplicity but flame will convert it to a static sprite
      'warriorDead': warriorSheet.createAnimation(row: 26, stepTime: 2, from: 1, to: 2,loop:false),
    };
    //starting animation
    init();
  }
  void init(){
    animation=animations["warriorWalkSidePassive"];
    animation.loop = false;
    //initial state
    animation.onComplete = passive;
    hitBox = toRect().deflate(deflation);
  }
  void f (){
    print("animation complete");
  }
  double ticker= 0;
  double bounces = 0;
  @override
  void update(double t) {
    //check for overrides every update, override the state machine
    enableInput? overrideState(input): print("input disabled");
    //update velocity by acceleration
    velocity += acceleration;
    //update position by velocity
    position += velocity;
    if(position==startPosition){stop();}
    //update hitbox, the hitbox can be a child component if you have time
    hitBox = toRect().deflate(deflation);
    ticker+=1;
    if(ticker>1000){ticker = 0;}//avoid overflow
    if(ticker%159==0){bounces = 0;}
    collision();
    boundsCollision();
    if(enemyPosition!= null){
      final Vector2 direction = position - enemyPosition;
      directionToTarget = direction.normalized();
    }
    if(collided) {
      bounce(directionToTarget, 2);
    }
    super.update(t);
  }
  //override state on manual input
  void overrideState(Input input){
    switch (input){
      case Input.none:
        return;
      case Input.attack:
        return;
    }
  }
  //these handlers change the animation
  //flipx because there's just one row of sprites going on the wrong direction
  void passiveWalk(){
    animation = animations["warriorWalkSidePassive"];
    renderFlipX = true;
    animation.reset();
  }
  void weaponOutWalk(){
    animation = animations["warriorWalkSideActive"];
    renderFlipX = false;
    animation.reset();
  }
  void attack1(){
    animation = animations["warriorAttackSideR"];
    renderFlipX = true;
    animation.reset();
  }
  void attack2(){
    animation = animations["warriorComboSideR"];
    renderFlipX = true;
    animation.reset();
  }
  void attack3(){
    animation = animations["warriorPowerSideR"];
    renderFlipX = true;
    animation.reset();
  }
  //handlers for movement
  void backToStart(){
    stop();
    final Vector2 offset = position-startPosition;
    acceleration -= offset.normalized()*speed*0.8;
  }
  void moveForward(){
    acceleration = Vector2(-1,0)*speed;
  }
  void stop(){
    velocity = Vector2(0,0);
    acceleration = Vector2(0,0);
  }
  void aggresiveMoveToTarget(){
    acceleration += directionToTarget*speed;

  }
  void checkIfInitialPosition(){
    if (position==startPosition){
      stop();
      passiveWalk();
      animation.onComplete = passive;
    }
  }
  //states are functions, they read the ticker and perform a transition to next state
  //usually onAnimationComplete points to the next state
  //if we need to interrupt an animation we call onComplete to force the transition
  //seems like flame stores the animation state so you get it back on that frame if you don't reset
  void passive(){
    print("passive state");
    passiveWalk();
    backToStart();
    animation.onComplete = passive; //loop
    animation.onComplete = battle? active : passive;
  }
  void active(){
    print("active state");
    weaponOutWalk();
    moveForward();
    if(enemyPosition!=null) {
      aggresiveMoveToTarget();}
    animation.onComplete = battle? active : passive;
    if(collided){
      attack1();
      aggresiveMoveToTarget();
      animation.onComplete = collided? attacking : active;
    }
  }
  void attacking(){
    attack1();
    aggresiveMoveToTarget();
    animation.onComplete = collided? comboAttacking :active;
  }
  void comboAttacking(){
    attack2();
    aggresiveMoveToTarget();
    animation.onComplete = collided? powerAttacking : active;
  }
  void powerAttacking(){
    attack3();
    aggresiveMoveToTarget();
    animation.onComplete = collided? attacking : active;
  }
  void nextA(){
    animation = animations["warriorWalkSideActive"];
    animation.reset();
    animation.onComplete = (){};
  }
  void reset(){
    animation = animations["warriorWalkSideActive"];
    animation.loop=true;
  }
  //on terminal state notify the game engine
  //the player component should have no terminal state, dead should always call revive after x ticks
  //other components can remove themselves
  void dead(){
    animation = animations["warriorDead"];
    animation.onComplete = (){};
  }
  //these fns run in update and override state if necessary
  bool collision() {
    if(enemyBox == null){return false;}
    collided = hitBox.overlaps(enemyBox);
    if(collided && interruptible) {
      animation.onComplete.call(); //force the state transition
    }
    return collided;
  }
  void bounce(Vector2 direction, double spd){
    bounces+=1;
    velocity = direction*bounces*spd;
    acceleration =
        direction * -0.3*spd; //bounce speed should be constant, actually bounce should increment based on occurences in x time
    //then increasing player speed will allow longer combo chains

  }
  void boundsCollision(){
    if(position.x < leftBound){bounce(Vector2(1,0), 0.2);}
    if(position.x > rightBound){bounce(Vector2(-1,0),0.2);}
    if(position.y < topBound){bounce(Vector2(0,1),0.2);}
    if(position.y > bottomBound){bounce(Vector2(0,-1),0.2);}
  }
}

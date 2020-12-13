import 'package:flutter/material.dart';

import './example_game.dart';

void main() {
  //runApp(ExampleGame().widget);
    bool state = true;
    typedef f = void Function();
  typedef Callback = int Function(int t);

    void a(){};
    void b(){};
    state? f = a : b;
    print(f);
    state = !state;
    state? f = a : b;
    print(f);

}
typedef Callback = int Function(int t);


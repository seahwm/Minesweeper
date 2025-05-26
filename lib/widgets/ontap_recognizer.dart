import 'package:flutter/gestures.dart';

class OnTapRecognizer extends TapGestureRecognizer {
  OnTapRecognizer(GestureTapCallback onclick) {
    onTap = onclick;
  }
}
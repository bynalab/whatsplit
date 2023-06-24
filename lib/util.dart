import 'package:flutter/material.dart';

void consolePrint(value, [key = 'SPLITTER']) {
  debugPrint({key: value}.toString());
}

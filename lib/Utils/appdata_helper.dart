import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

abstract class AppDataHelper {
  AppDataHelper._();

  static String appName = 'CHIKX';

  static final navKey = GlobalKey<NavigatorState>();

  static bool isValidEmail(String email) =>
      RegExp(r"^[A-Z0-9a-z._-]+@[a-zA-Z0-9_-]+\.[a-zA-Z]+").hasMatch(email);

  static BuildContext? get rootContext => AppDataHelper.navKey.currentState?.overlay?.context;
}

void prettyPrintJSON(dynamic json) {
  if (!kDebugMode) return;

  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  String prettyString = json is String
      ? json
      : (json is Map
      ? encoder.convert(json)
      : '😔..Can\'t Pretty Print Your Object..😔');
  debugPrint('<<----- PRETTY JSON (START) ----->>');
  prettyString.split('\n').forEach((element) => debugPrint(element));
  debugPrint('<<----- PRETTY JSON (END) ----->>');
}
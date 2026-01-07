import 'package:flutter/material.dart';

Color setContainerColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? Color.fromRGBO(34, 34, 34, 1)
      : Color.fromRGBO(255, 245, 245, 1);
}

Color setContainerContrastColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? Color.fromRGBO(255, 245, 245, 1)
      : Color.fromRGBO(34, 34, 34, 1);
}
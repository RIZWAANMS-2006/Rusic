import 'package:flutter/material.dart';

final ValueNotifier<bool> wideScreenPanelsSwapped = ValueNotifier<bool>(false);

void toggleWideScreenPanels() {
  wideScreenPanelsSwapped.value = !wideScreenPanelsSwapped.value;
}

Color setContainerColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color.fromRGBO(34, 34, 34, 1)
      : const Color.fromRGBO(255, 245, 245, 1);
}

Color setContainerContrastColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color.fromRGBO(255, 245, 245, 1)
      : const Color.fromRGBO(34, 34, 34, 1);
}

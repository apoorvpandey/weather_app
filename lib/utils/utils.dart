import 'package:flutter/material.dart';

extension NameFormatting on String {
  String toNameFormat() {
    if (isEmpty) return this;

    final firstChar = this[0].toUpperCase();
    final remainingChars = substring(1).toLowerCase();
    return '$firstChar$remainingChars';
  }
}

bool isServerError(int statusCode) {
  return statusCode >= 500 && statusCode < 600;
}

void unFocusKeyBoard() => FocusManager.instance.primaryFocus?.unfocus();

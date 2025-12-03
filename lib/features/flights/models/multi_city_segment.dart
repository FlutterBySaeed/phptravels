import 'package:flutter/material.dart';

class MultiCitySegment {
  String from;
  String to;
  DateTime? date;
  TextEditingController fromController;
  TextEditingController toController;
  bool hasError;

  MultiCitySegment(
      {this.from = '', this.to = '', this.date, this.hasError = false})
      : fromController = TextEditingController(text: from),
        toController = TextEditingController(text: to);

  MultiCitySegment copyWith(
      {String? from, String? to, DateTime? date, bool? hasError}) {
    return MultiCitySegment(
        from: from ?? this.from,
        to: to ?? this.to,
        date: date ?? this.date,
        hasError: hasError ?? this.hasError);
  }

  void dispose() {
    fromController.dispose();
    toController.dispose();
  }
}

import 'package:flutter/material.dart';

class CalendarEventModel {
  CalendarEventModel({
    required this.id,
    required this.name,
    required this.begin,
    required this.end,
    this.eventColor = Colors.green,
  });

  String name;
  String id;
  DateTime begin;
  DateTime end;
  Color eventColor;


  @override
  bool operator ==(other) {
    return (other is CalendarEventModel) && other.id == id;
  }

}

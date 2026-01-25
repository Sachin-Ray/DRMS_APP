import 'package:flutter/material.dart';

class WeatherDay {
  final String day;
  final IconData icon;
  final String desc;
  final int temp;
  WeatherDay({required this.day, required this.icon, required this.desc, required this.temp});
}

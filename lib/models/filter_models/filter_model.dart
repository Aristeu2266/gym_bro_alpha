import 'package:flutter/material.dart';

class FilterModel {
  final String label;
  Widget? pic;
  final IconData? icon;

  FilterModel(this.label, {this.pic, this.icon}) {
    if (pic == null && icon != null) {
      pic = Icon(icon);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/filter_models/filter_model.dart';
import 'package:gym_bro_alpha/models/filter_models/filter_options.dart';
import 'package:gym_bro_alpha/utils/custom_icons.dart';

class TypeFilters extends FilterOptions {
  @override
  List<FilterModel> get values => [
        FilterModel(
          'All',
          pic: const Icon(CustomIcons.all),
        ),
        FilterModel(
          'Strength',
          pic: const Icon(CustomIcons.strength),
        ),
        FilterModel(
          'Stretching',
          pic: const Icon(CustomIcons.stretching),
        ),
        FilterModel(
          'Powerlifting',
          pic: const Icon(CustomIcons.powerlifting),
        ),
        FilterModel(
          'Cardio',
          pic: const Icon(CustomIcons.cardio),
        ),
        FilterModel(
          'Strongman',
          pic: const Icon(CustomIcons.strongman),
        ),
        FilterModel(
          'Olympic Weightlifting',
          pic: const Icon(CustomIcons.olympicweightlifting),
        ),
        FilterModel(
          'Plyometrics',
          pic: const Icon(CustomIcons.plyometrics),
        ),
      ];
}

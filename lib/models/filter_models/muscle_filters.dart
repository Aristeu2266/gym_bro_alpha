import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/filter_models/filter_model.dart';
import 'package:gym_bro_alpha/models/filter_models/filter_options.dart';
import 'package:gym_bro_alpha/utils/custom_icons.dart';

class MuscleFilters extends FilterOptions {
  @override
  List<FilterModel> get values => [
        FilterModel(
          'All',
          icon: CustomIcons.all,
        ),
        FilterModel(
          'Neck',
          pic: Image.asset('assets/images/muscles/neck.png'),
        ),
        FilterModel(
          'Traps',
          pic: Image.asset('assets/images/muscles/traps.png'),
        ),
        FilterModel(
          'Shoulders',
          pic: Image.asset('assets/images/muscles/shoulders.png'),
        ),
        FilterModel(
          'Chest',
          pic: Image.asset('assets/images/muscles/chest.png'),
        ),
        FilterModel(
          'Middle back',
          pic: Image.asset('assets/images/muscles/middleBack.png'),
        ),
        FilterModel(
          'Lats',
          pic: Image.asset('assets/images/muscles/lats.png'),
        ),
        FilterModel(
          'Lower back',
          pic: Image.asset('assets/images/muscles/lowerBack.png'),
        ),
        FilterModel(
          'Abdominals',
          pic: Image.asset('assets/images/muscles/abdominals.png'),
        ),
        FilterModel(
          'Biceps',
          pic: Image.asset('assets/images/muscles/biceps.png'),
        ),
        FilterModel(
          'Triceps',
          pic: Image.asset('assets/images/muscles/triceps.png'),
        ),
        FilterModel(
          'Forearms',
          pic: Image.asset('assets/images/muscles/forearms.png'),
        ),
        FilterModel(
          'Glutes',
          pic: Image.asset('assets/images/muscles/glutes.png'),
        ),
        FilterModel(
          'Quadriceps',
          pic: Image.asset('assets/images/muscles/quadriceps.png'),
        ),
        FilterModel(
          'Hamstrings',
          pic: Image.asset('assets/images/muscles/hamstrings.png'),
        ),
        FilterModel(
          'Adductors',
          pic: Image.asset('assets/images/muscles/adductors.png'),
        ),
        FilterModel(
          'Abductors',
          pic: Image.asset('assets/images/muscles/abductors.png'),
        ),
        FilterModel(
          'Calves',
          pic: Image.asset('assets/images/muscles/calves.png'),
        ),
      ];
}

import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/filter_models/filter_model.dart';
import 'package:gym_bro_alpha/models/filter_models/filter_options.dart';
import 'package:gym_bro_alpha/utils/custom_icons.dart';

class EquipmentFilters extends FilterOptions {
  @override
  List<FilterModel> get values => [
        FilterModel(
          'All',
          pic: const Icon(CustomIcons.all),
        ),
        FilterModel(
          'Exercise Ball',
          pic: const Icon(CustomIcons.exerciseball),
        ),
        FilterModel(
          'Machine',
          pic: const Icon(CustomIcons.machine),
        ),
        FilterModel(
          'Foam Roll',
          pic: const Icon(CustomIcons.foamroll),
        ),
        FilterModel(
          'Dumbbell',
          pic: const Icon(CustomIcons.dumbbell),
        ),
        FilterModel(
          'Barbell',
          pic: const Icon(CustomIcons.barbell),
        ),
        FilterModel(
          'Body Only',
          pic: const Icon(CustomIcons.bodyonly),
        ),
        FilterModel(
          'Kettlebell',
          pic: const Icon(CustomIcons.kettlebell),
        ),
        FilterModel(
          'Medicine Ball',
          pic: const Icon(CustomIcons.medicineball),
        ),
        FilterModel(
          'Elastic Band',
          pic: const Icon(CustomIcons.elasticband),
        ),
        FilterModel(
          'Cable Crossover',
          pic: const Icon(CustomIcons.cablecrossover),
        ),
        FilterModel(
          'E-Z Curl Bar',
          pic: const Icon(CustomIcons.ezbar),
        ),
        FilterModel(
          'Other',
          pic: const Icon(CustomIcons.other),
        ),
      ];
}

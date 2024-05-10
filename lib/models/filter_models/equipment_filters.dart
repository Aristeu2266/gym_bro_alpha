import 'package:gym_bro_alpha/models/filter_models/filter_model.dart';
import 'package:gym_bro_alpha/models/filter_models/filter_options.dart';
import 'package:gym_bro_alpha/utils/custom_icons.dart';

class EquipmentFilters extends FilterOptions {
  @override
  List<FilterModel> get values => [
        FilterModel(
          'All',
          icon: CustomIcons.all,
        ),
        FilterModel(
          'Exercise Ball',
          icon: CustomIcons.exerciseball,
        ),
        FilterModel(
          'Machine',
          icon: CustomIcons.machine,
        ),
        FilterModel(
          'Foam Roll',
          icon: CustomIcons.foamroll,
        ),
        FilterModel(
          'Dumbbell',
          icon: CustomIcons.dumbbell,
        ),
        FilterModel(
          'Barbell',
          icon: CustomIcons.barbell,
        ),
        FilterModel(
          'Body Only',
          icon: CustomIcons.bodyonly,
        ),
        FilterModel(
          'Kettlebell',
          icon: CustomIcons.kettlebell,
        ),
        FilterModel(
          'Medicine Ball',
          icon: CustomIcons.medicineball,
        ),
        FilterModel(
          'Elastic Band',
          icon: CustomIcons.elasticband,
        ),
        FilterModel(
          'Cable Crossover',
          icon: CustomIcons.cablecrossover,
        ),
        FilterModel(
          'E-Z Curl Bar',
          icon: CustomIcons.ezbar,
        ),
        FilterModel(
          'Other',
          icon: CustomIcons.other,
        ),
      ];
}

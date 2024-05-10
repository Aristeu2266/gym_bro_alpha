import 'package:gym_bro_alpha/models/filter_models/filter_model.dart';
import 'package:gym_bro_alpha/models/filter_models/filter_options.dart';
import 'package:gym_bro_alpha/utils/custom_icons.dart';

class TypeFilters extends FilterOptions {
  @override
  List<FilterModel> get values => [
        FilterModel(
          'All',
          icon: CustomIcons.all,
        ),
        FilterModel(
          'Strength',
          icon: CustomIcons.strength,
        ),
        FilterModel(
          'Stretching',
          icon: CustomIcons.stretching,
        ),
        FilterModel(
          'Powerlifting',
          icon: CustomIcons.powerlifting,
        ),
        FilterModel(
          'Cardio',
          icon: CustomIcons.cardio,
        ),
        FilterModel(
          'Strongman',
          icon: CustomIcons.strongman,
        ),
        FilterModel(
          'Olymicon Weightlifting',
          icon: CustomIcons.olympicweightlifting,
        ),
        FilterModel(
          'Plyometrics',
          icon: CustomIcons.plyometrics,
        ),
      ];
}

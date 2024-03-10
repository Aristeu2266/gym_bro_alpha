import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:gym_bro_alpha/utils/custom_icons.dart';

enum TypeFilters {
  all('All', CustomIcons.all),
  strength('Strength', CustomIcons.strength),
  stretching('Stretching', CustomIcons.stretching),
  powerlifting('Powerlifting', CustomIcons.powerlifting),
  cardio('Cardio', CustomIcons.cardio),
  strongman('Strongman', CustomIcons.strongman),
  olympicWeightlifting(
      'Olympic Weightlifting', CustomIcons.olympicweightlifting),
  plyometrics('Plyometrics', CustomIcons.plyometrics);

  const TypeFilters(this.label, this.iconData);
  final String label;
  final IconData iconData;
}

enum EquipmentFilters {
  all('All', CustomIcons.all),
  exerciseBall('Exercise Ball', CustomIcons.exerciseball),
  machine('Machine', CustomIcons.machine),
  foamRoll('Foam Roll', CustomIcons.foamroll),
  dumbbell('Dumbbell', CustomIcons.dumbbell),
  barbell('Barbell', CustomIcons.barbell),
  bodyOnly('Body Only', CustomIcons.bodyonly),
  kettlebell('Kettlebell', CustomIcons.kettlebell),
  medicineBall('Medicine Ball', CustomIcons.medicineball),
  elasticBand('Elastic Band', CustomIcons.elasticband),
  cableCrossover('Cable Crossover', CustomIcons.cablecrossover),
  ezBar('E-Z Curl Bar', CustomIcons.ezbar),
  other('Other', CustomIcons.other);

  const EquipmentFilters(this.label, this.iconData);
  final String label;
  final IconData iconData;
}

enum Muscles {
  neck('Neck'),
  traps('Traps'),
  shoulders('Shoulders'),
  chest('Chest'),
  middleBack('Middle back'),
  lats('Lats'),
  lowerBack('Lower back'),
  abdominals('Abdominals'),
  biceps('Biceps'),
  triceps('Triceps'),
  forearms('Forearms'),
  glutes('Glutes'),
  quadriceps('Quadriceps'),
  hamstrings('Hamstrings'),
  adductors('Adductors'),
  abductors('Abductors'),
  calves('Calves');

  const Muscles(this.label);
  final String label;
}

class FilterPage extends StatelessWidget {
  const FilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FilterPages filter =
        ModalRoute.of(context)?.settings.arguments as FilterPages;

    return Scaffold(
      appBar: AppBar(
        title: Text('Select ${filter.label}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            color: Theme.of(context).colorScheme.onBackground,
            height: 2,
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: FilterList(filter),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterList extends StatelessWidget {
  const FilterList(this.filter, {super.key});

  final FilterPages filter;

  Widget? listTileChild(int index) {
    return filter != FilterPages.muscle
        ? Icon(
            filter == FilterPages.type
                ? TypeFilters.values[index].iconData
                : EquipmentFilters.values[index].iconData,
          )
        : Image.asset(
            'assets/images/muscles/${Muscles.values[index].name}.png',
          );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: filter == FilterPages.type
          ? TypeFilters.values.length
          : filter == FilterPages.equipment
              ? EquipmentFilters.values.length
              : Muscles.values.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: listTileChild(index),
              ),
              title: Text(
                filter == FilterPages.type
                    ? TypeFilters.values[index].label
                    : filter == FilterPages.equipment
                        ? EquipmentFilters.values[index].label
                        : Muscles.values[index].label,
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(
          height: 0,
        );
      },
    );
  }
}

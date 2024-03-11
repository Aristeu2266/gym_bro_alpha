import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/filter_models/equipment_filters.dart';
import 'package:gym_bro_alpha/models/filter_models/filter_options.dart';
import 'package:gym_bro_alpha/models/filter_models/muscle_filters.dart';
import 'package:gym_bro_alpha/models/filter_models/type_filters.dart';
import 'package:gym_bro_alpha/utils/constants.dart';

class FilterPage extends StatelessWidget {
  const FilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FilterPages filter = (ModalRoute.of(context)?.settings.arguments
        as Map)['filter'] as FilterPages;

    final String selected = (ModalRoute.of(context)?.settings.arguments
        as Map)['selected'] as String;

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
              child: FilterList(
                filter: filter,
                selected: selected,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterList extends StatelessWidget {
  const FilterList({required this.filter, required this.selected, super.key});

  final FilterPages filter;
  final String selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    FilterOptions filterObj = filter == FilterPages.type
        ? TypeFilters()
        : filter == FilterPages.equipment
            ? EquipmentFilters()
            : MuscleFilters();

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: filterObj.values.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {},
          child: Container(
            color: selected == filterObj.values[index].label.toLowerCase()
                ? colorScheme.onPrimary
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: filterObj.values[index].pic,
                ),
                title: Text(filterObj.values[index].label),
                onTap: () =>
                    Navigator.pop(context, filterObj.values[index].label),
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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gym_bro_alpha/models/exercise_model.dart';
import 'package:gym_bro_alpha/models/filter_models/equipment_filters.dart';
import 'package:gym_bro_alpha/models/filter_models/muscle_filters.dart';
import 'package:gym_bro_alpha/models/filter_models/type_filters.dart';
import 'package:gym_bro_alpha/utils/utils.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  @override
  Widget build(BuildContext context) {
    ExerciseModel exercise =
        ModalRoute.of(context)?.settings.arguments as ExerciseModel;

    YoutubePlayerController controller = YoutubePlayerController(
      initialVideoId: (exercise.videoUrl ?? '').split('?v= + ')[1],
      flags: const YoutubePlayerFlags(
        autoPlay: false,
      ),
    );

    TypeFilters typeFilters = TypeFilters();
    EquipmentFilters equipmentFilters = EquipmentFilters();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          exercise.name,
          style: const TextStyle(fontSize: 20),
          maxLines: 2,
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back_outlined),
              onPressed: () {
                controller.setSize(Size.zero);
                controller.dispose();
                Navigator.of(context).pop();
              },
              tooltip: MaterialLocalizations.of(context).lastPageTooltip,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              child: YoutubePlayer(
                controller: controller,
              ),
            ),
            // SizedBox(height: 300),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            typeFilters.values
                                .singleWhere(
                                  (element) =>
                                      element.label.toLowerCase() ==
                                      exercise.category.toLowerCase(),
                                )
                                .icon,
                          ),
                          const SizedBox(width: 4),
                          Text(Utils.capitalize(exercise.category)),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Row(
                          children: [
                            const Text('Category:'),
                            Text(exercise.category.toUpperCase()),
                            typeFilters.values
                                    .singleWhere(
                                      (element) =>
                                          element.label.toLowerCase() ==
                                          exercise.category.toLowerCase(),
                                    )
                                    .pic ??
                                const Text('Erro'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    Size buttonSize(BoxConstraints constraints) {
      if (constraints.maxWidth < constraints.maxHeight) {
        return Size(constraints.maxWidth * 0.6, constraints.maxWidth * 0.6);
      } else {
        return Size(
            ((constraints.maxHeight * 0.4) - 200 > 50
                ? (constraints.maxHeight * 0.4) - 200
                : 50),
            ((constraints.maxHeight * 0.4) - 200 > 50
                ? (constraints.maxHeight * 0.4) - 200
                : 50));
      }
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: double.infinity,
              maxHeight:
                  (constraints.maxHeight - buttonSize(constraints).height) / 2,
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'a',
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 36),
                ),
              ],
            ),
          ),
          Center(
            child: IconButton(
              style: IconButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                minimumSize: buttonSize(constraints),
              ),
              onPressed: () {},
              icon: Icon(
                Icons.play_arrow,
                size: screenSize.width < screenSize.height
                    ? screenSize.width * 0.4
                    : ((screenSize.height * 0.4) - 200 > 40
                        ? (screenSize.height * 0.4)
                        : 40),
              ),
            ),
          ),
        ],
      );
    });
  }
}

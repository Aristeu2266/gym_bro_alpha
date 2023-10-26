import 'package:flutter/material.dart';

class SignBottomText extends StatelessWidget {
  SignBottomText({
    this.text,
    required this.color,
    this.page,
    this.clickable,
    super.key,
  }){
    assert (text != null || clickable != null);
    assert ((clickable != null && page != null) || (clickable == null && page == null));
  }

  final String? text;
  final Color color;
  final Widget? page;
  final String? clickable;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Column(
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (text != null) Text(text!),
                if (clickable != null)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (ctx, animation1, animation2) => page!,
                        ),
                      );
                    },
                    child: Text(
                      clickable!,
                      style: TextStyle(
                        color: color,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

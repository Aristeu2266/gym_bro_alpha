import 'package:flutter/material.dart';

class ExpandButton extends StatefulWidget {
  const ExpandButton({
    required this.text,
    required this.callback,
    this.initialValue = true,
    super.key,
  });

  final Widget text;
  final void Function() callback;
  final bool initialValue;

  @override
  State<ExpandButton> createState() => ExpandButtonState();
}

class ExpandButtonState extends State<ExpandButton>
    with SingleTickerProviderStateMixin {
  AnimationController? _turnController;
  Animation<double>? _turnAnimation;
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialValue;
    _turnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _turnAnimation = Tween(
      begin: 0.0,
      end: widget.initialValue ? -0.5 : 0.5,
    ).animate(
      CurvedAnimation(
        parent: _turnController!,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _turnController!.dispose();
    super.dispose();
  }

  void toggleExpand() {
    _expanded = !_expanded;
    if (_expanded != widget.initialValue) {
      _turnController!.forward();
    } else {
      _turnController!.reverse();
    }
    widget.callback();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: toggleExpand,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        children: [
          widget.text,
          RotationTransition(
            turns: _turnAnimation!,
            child: Icon(
              widget.initialValue ? Icons.expand_less : Icons.expand_more,
              size: 40,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

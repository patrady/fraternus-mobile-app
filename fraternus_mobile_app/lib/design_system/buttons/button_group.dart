import 'package:flutter/widgets.dart';

/// Lays out any number of buttons in a row, each given equal width and
/// separated by [spacing] — the "Cancel / Save" and "Back / Continue"
/// button rows used across forms and onboarding.
class ButtonGroup extends StatelessWidget {
  const ButtonGroup({super.key, required this.children, this.spacing = 10});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

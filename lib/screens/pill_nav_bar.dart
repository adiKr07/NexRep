import 'package:flutter/material.dart';

class PillNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const PillNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.fitness_center_rounded,
    Icons.bar_chart_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 0, 60, 24),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 54, 54, 54).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_icons.length, (index) {
            final isSelected = index == currentIndex;
            return GestureDetector(
              onTap: () => onTabSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icons[index],
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
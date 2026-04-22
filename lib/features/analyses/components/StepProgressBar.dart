import 'package:flutter/material.dart';

class StepProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
 
  const StepProgressBar({
    required this.totalSteps,
    required this.currentStep,
  });
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final bool isActive = index <= currentStep;
        return Expanded(
          child: Container(
            height: 8,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF16372C) // verde activo
                  : const Color(0xFFDDDDDD), // gris inactivo
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
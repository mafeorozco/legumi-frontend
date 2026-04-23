import 'package:flutter/material.dart';


class PlantGrid extends StatelessWidget {
  final int rows;
  final int columns;

  const PlantGrid({super.key, required this.rows, required this.columns});

  @override
  Widget build(BuildContext context) {
    final cols = columns.clamp(1, 10);
    final rws = rows.clamp(1, 6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(rws, (_) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,      // ← clave
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(cols, (_) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5D5D5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
 
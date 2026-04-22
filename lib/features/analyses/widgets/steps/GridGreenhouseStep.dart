import 'package:flutter/material.dart';
import 'package:legumi/features/analyses/models/green_house_selection.dart';
import 'package:legumi/features/analyses/models/grid_position.dart';

class GridGreenhouseStep extends StatefulWidget {
  final GreenhouseSelection greenhouse;
  final ValueChanged<List<GridPosition>> onSelectionChanged;

  const GridGreenhouseStep({
    required this.greenhouse,
    required this.onSelectionChanged,
  });

  @override
  State<GridGreenhouseStep> createState() => _GridGreenhouseStepState();
}

class _GridGreenhouseStepState extends State<GridGreenhouseStep>{
  final Set<GridPosition> _selected = {};

  void _toggleCell(int row, int column) {
    final pos = GridPosition(row: row, column: column);
    setState(() {
      if (_selected.contains(pos)) {
        _selected.remove(pos);
      } else {
        _selected.add(pos);
      }
    });
    widget.onSelectionChanged(_selected.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Leyenda
        Row(
          children: [
            _LegendItem(color: Colors.grey.shade300, label: 'Disponible'),
            const SizedBox(width: 16),
            _LegendItem(color: const Color(0xFF1B4332), label: 'Seleccionado'),
          ],
        ),
        const SizedBox(height: 16),
        // Cuadrícula
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.greenhouse.columns,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: widget.greenhouse.rows * widget.greenhouse.columns,
          itemBuilder: (context, index) {
            final row = index ~/ widget.greenhouse.columns;
            final col = index % widget.greenhouse.columns;
            final isSelected = _selected.contains(GridPosition(row: row, column: col));

            return GestureDetector(
              onTap: () => _toggleCell(row, col),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1B4332) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

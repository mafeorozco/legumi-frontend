import 'package:flutter/material.dart';
import 'package:legumi/features/analyses/models/analysis_result.dart';
import 'package:legumi/features/analyses/models/detected_pest.dart';
import 'package:legumi/features/analyses/models/green_house_selection.dart';
import 'package:legumi/features/analyses/models/grid_position.dart';


class AnalysisResultScreen extends StatelessWidget {
  final AnalysisResult result;
  final GreenhouseSelection greenhouse;
  final List<GridPosition> selectedPositions;

  const AnalysisResultScreen({
    super.key,
    required this.result,
    required this.greenhouse,
    required this.selectedPositions,
  });

  @override
  Widget build(BuildContext context) {
    final mainPest = result.detectedPests.isNotEmpty ? result.detectedPests.first : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Hero con resultado
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2D5016),
              image: DecorationImage(
                image: AssetImage('assets/images/img_hero.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
              padding: const EdgeInsets.only(top: 56, right: 20),
              alignment: Alignment.topRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('resultado del analisis:',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    mainPest?.pest.name.toUpperCase() ?? 'SIN RESULTADO',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenido
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    transform: Matrix4.translationValues(0, -24, 0),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Detalle del analisis',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 20),

                        // Fecha
                        _SectionLabel(label: 'Fecha'),
                        Text(result.dateTimeCreate.split('T').first),
                        const SizedBox(height: 16),

                        // Plagas detectadas
                        _SectionLabel(label: 'Plagas detectadas'),
                        ...result.detectedPests.map((d) => _PestCard(detectedPest: d)),
                        const SizedBox(height: 16),

                        // Descripción
                        if (mainPest != null) ...[
                          _SectionLabel(label: 'Descripcion'),
                          Text(mainPest.pest.descripcion),
                          const SizedBox(height: 16),
                        ],

                        // Zonas afectadas
                        _SectionLabel(label: 'Zonas afectadas'),
                        const SizedBox(height: 8),
                        _GridPreview(
                          greenhouse: greenhouse,
                          selectedPositions: selectedPositions,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5016),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('VOLVER AL INICIO',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }
}

class _PestCard extends StatelessWidget {
  final DetectedPest detectedPest;
  const _PestCard({required this.detectedPest});

  Color get _severityColor {
    switch (detectedPest.severity) {
      case 'alta': return Colors.red.shade100;
      case 'media': return Colors.orange.shade100;
      default: return Colors.green.shade100;
    }
  }

  Color get _severityTextColor {
    switch (detectedPest.severity) {
      case 'alta': return Colors.red.shade800;
      case 'media': return Colors.orange.shade800;
      default: return Colors.green.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detectedPest.pest.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(detectedPest.pest.clasification.name,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _severityColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(detectedPest.severity,
                style: TextStyle(fontSize: 12, color: _severityTextColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _GridPreview extends StatelessWidget {
  final GreenhouseSelection greenhouse;
  final List<GridPosition> selectedPositions;

  const _GridPreview({required this.greenhouse, required this.selectedPositions});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: greenhouse.columns,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: greenhouse.rows * greenhouse.columns,
      itemBuilder: (context, index) {
        final row = index ~/ greenhouse.columns;
        final col = index % greenhouse.columns;
        final isSelected = selectedPositions.contains(GridPosition(row: row, column: col));

        return Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2D5016) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      },
    );
  }
}
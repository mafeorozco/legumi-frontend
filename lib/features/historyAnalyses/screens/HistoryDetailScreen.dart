import 'package:flutter/material.dart';
import 'package:legumi/features/analyses/models/detected_pest.dart';
import 'package:legumi/features/analyses/models/green_house_selection.dart';
import 'package:legumi/features/analyses/models/grid_position.dart';
import 'package:legumi/features/analyses/screens/AnalysisResultScreen.dart';
import 'package:legumi/features/historyAnalyses/models/analysis_model.dart';
import 'package:legumi/features/historyAnalyses/models/analysis_result_model.dart';

class HistoryDetailScreen extends StatefulWidget {
  final AnalysisModel analysis;

  const HistoryDetailScreen({super.key, required this.analysis});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideImageAnimation;
  late Animation<Offset> _slideTextAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideImageAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideTextAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Conversores ────────────────────────────────────────────────────────────

  GreenhouseSelection get _greenhouse => GreenhouseSelection(
        id:      widget.analysis.greenhouse?.id ?? 0,
        name:    widget.analysis.greenhouse?.name ?? 'Sin invernadero',
        rows:    widget.analysis.greenhouse?.rows ?? 0,
        columns: widget.analysis.greenhouse?.columns ?? 0,
      );

  List<GridPosition> get _selectedPositions {
    final positions = <GridPosition>[];
    for (final result in widget.analysis.results) {
      for (final loc in result.plantLocations) {
        positions.add(GridPosition(row: loc.row, column: loc.column));
      }
    }
    return positions;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mainResult = widget.analysis.results.isNotEmpty
        ? widget.analysis.results.first
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Hero ────────────────────────────────────────────────────────
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Stack(
              children: [
                Container(color: const Color(0xFF1B3A2D)),
                Positioned(
                  left: -120,
                  top: 0,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8FBF7F),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -10,
                  top: 30,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideImageAnimation,
                      child: Container(
                        width: 140,
                        height: 170,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/hero_result.png'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width * 0.48,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideTextAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'resultado del analisis:',
                              style: TextStyle(
                                  color: Color(0xFFADD1A5), fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mainResult?.pest?.name.toUpperCase() ??
                                  'SIN RESULTADO',
                              style: const TextStyle(
                                color: Color(0xFFADD1A5),
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Contenido ───────────────────────────────────────────────────
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: SingleChildScrollView(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detalle del analisis',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 20),

                        // Fecha
                        const _SectionLabel(label: 'Fecha'),
                        Text(
                          widget.analysis.dateTimeCreate
                                  ?.toIso8601String()
                                  .split('T')
                                  .first ??
                              'Sin fecha',
                        ),
                        const SizedBox(height: 16),

                        // Plagas detectadas
                        const _SectionLabel(label: 'Plagas detectadas'),
                        ...widget.analysis.results
                        .where((d) => d.pest?.id != 11)
                        .map(
                          (r) => _ResultCard(result: r),
                        ),
                        const SizedBox(height: 16),

                        // Descripción
                        if (mainResult?.pest?.descripcion != null) ...[
                          const _SectionLabel(label: 'Descripcion'),
                          Text(mainResult!.pest!.descripcion!),
                          const SizedBox(height: 16),
                        ],

                        // Zonas afectadas
                        const _SectionLabel(label: 'Zonas afectadas'),
                        const SizedBox(height: 8),
                        _GridPreview(
                          greenhouse: _greenhouse,
                          selectedPositions: _selectedPositions,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Botón ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5016),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'VOLVER',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF16372C),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final AnalysisResultModel result;
  const _ResultCard({required this.result});

  Color get _severityColor {
    switch (result.severity.toLowerCase()) {
      case 'alta':   return Colors.red.shade100;
      case 'media':  return Colors.orange.shade100;
      default:       return Colors.green.shade100;
    }
  }

  Color get _severityTextColor {
    switch (result.severity.toLowerCase()) {
      case 'alta':   return Colors.red.shade800;
      case 'media':  return Colors.orange.shade800;
      default:       return Colors.green.shade800;
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
            child: Text(
              result.pest?.name ?? 'Sin plaga',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _severityColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Severidad: ${result.severity}',
              style: TextStyle(
                fontSize: 12,
                color: _severityTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPreview extends StatelessWidget {
  final GreenhouseSelection greenhouse;
  final List<GridPosition> selectedPositions;

  const _GridPreview({
    required this.greenhouse,
    required this.selectedPositions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.house_outlined, size: 16,
                color: Color.fromARGB(255, 27, 27, 27)),
            const SizedBox(width: 6),
            Text(
              greenhouse.name,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 27, 27, 27)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
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
            final isSelected = selectedPositions
                .contains(GridPosition(row: row, column: col));
            return Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1B3A2D)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
            );
          },
        ),
      ],
    );
  }
}
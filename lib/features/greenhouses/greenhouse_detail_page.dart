import 'package:flutter/material.dart';
import 'package:legumi/core/theme/app_theme.dart';
import 'package:legumi/shared/widgets/menu_inferior.dart';

class GreenhouseDetailPage extends StatelessWidget {
  final Map<String, dynamic> greenhouse;
  const GreenhouseDetailPage({super.key, required this.greenhouse});

  @override
  Widget build(BuildContext context) {
    final rows    = greenhouse['rows'] as int? ?? 0;
    final columns = greenhouse['columns'] as int? ?? 0;
    final name    = greenhouse['name'] ?? 'Invernadero';

    return Scaffold(
      body: Column(children: [
        // TopBar
        Container(
          height: 64,
          color: AppColors.green800,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Text(name,
              style: const TextStyle(color: Colors.white, fontSize: 18,
                fontWeight: FontWeight.w700)),
            const Spacer(),
            // Botón editar (futuro)
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
              label: const Text('Editar',
                style: TextStyle(color: Colors.white, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ]),
        ),

        // Body
        Expanded(
          child: Row(children: [
            // Panel izquierdo — info
            SizedBox(
              width: 280,
              child: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ícono grande
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.green50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.home_work_outlined,
                        color: AppColors.green600, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(name,
                      style: const TextStyle(fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Invernadero activo',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),

                    const SizedBox(height: 24),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 24),

                    // Stats
                    _InfoRow(label: 'Filas', value: '$rows'),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Columnas', value: '$columns'),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Total cuadriculas', value: '${rows * columns}'),

                    const Spacer(),

                    // Badge estado
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.green50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      /* child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        /* children: [
                          Icon(Icons.check_circle_outline,
                            color: AppColors.green600, size: 16),
                          SizedBox(width: 6),
                          /* Text('Sin alertas activas',
                            style: TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.green600)), */
                        ], */
                      ), */
                    ),
                  ],
                ),
              ),
            ),

            Container(width: 0.5, color: AppColors.border),

            // Panel derecho — cuadrícula
            Expanded(
              child: Container(
                color: AppColors.background,
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('Distribución del invernadero',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                      const Spacer(),
                      // Leyenda
                      _LegendDot(color: AppColors.green50,
                        border: AppColors.green200, label: 'Sana'),
                      const SizedBox(width: 12),
                      /* _LegendDot(color: const Color(0xFFFCEBEB),
                        border: Color(0xFFF09595), label: 'Afectada'), */
                    ]),
                    const SizedBox(height: 6),
                    Text('$rows filas × $columns columnas · ${rows * columns} cuadriculas',
                      style: const TextStyle(fontSize: 13,
                        color: AppColors.textSecondary)),
                    const SizedBox(height: 20),

                    // Cuadrícula centrada y limitada
                    Expanded(
                      child: rows > 0 && columns > 0
                        ? _DetailGrid(rows: rows, cols: columns)
                        : const Center(
                            child: Text('Sin datos de cuadrícula')),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),

        const MenuInferior(),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary)),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final Color border;
  final String label;
  const _LegendDot({required this.color, required this.border, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 12, height: 12,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 4),
      Text(label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ]);
  }
}

class _DetailGrid extends StatelessWidget {
  final int rows;
  final int cols;
  const _DetailGrid({required this.rows, required this.cols});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcula tamaño de celda para que quepa en el espacio disponible
        final maxCellW = (constraints.maxWidth - (cols - 1) * 3) / cols;
        final maxCellH = (constraints.maxHeight - (rows - 1) * 3) / rows;
        final cellSize = maxCellW < maxCellH ? maxCellW : maxCellH;
        final clampedCell = cellSize.clamp(20.0, 80.0);

        final gridW = clampedCell * cols + (cols - 1) * 3;
        final gridH = clampedCell * rows + (rows - 1) * 3;

        return Center(
          child: Container(
            width: gridW,
            height: gridH,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.green600, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(), // sin scrollbar
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                itemCount: rows * cols,
                itemBuilder: (_, index) {
                  final row = index ~/ cols + 1;
                  final col = index % cols + 1;
                  return Container(
                    color: AppColors.green50,
                    child: Center(
                      child: Text('$row,$col',
                        style: TextStyle(
                          fontSize: clampedCell < 35 ? 8 : 10,
                          color: AppColors.green400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
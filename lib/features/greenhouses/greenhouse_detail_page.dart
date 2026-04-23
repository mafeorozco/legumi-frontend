import 'package:flutter/material.dart';
import 'package:legumi/core/theme/app_theme.dart';
import 'package:legumi/shared/widgets/menu_inferior.dart';

class GreenhouseDetailPage extends StatelessWidget {
  final Map<String, dynamic> greenhouse;
  const GreenhouseDetailPage({super.key, required this.greenhouse});

  @override
  Widget build(BuildContext context) {
    final rows = greenhouse['rows'] as int? ?? 0;
    final columns = greenhouse['columns'] as int? ?? 0;
    final name = greenhouse['name'] as String? ?? 'Invernadero';
    final isOwner = greenhouse['is_owner'] as bool? ?? false;
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      // MenuInferior solo aparece en móvil (el widget lo controla internamente)
      bottomNavigationBar: MenuInferior(
        currentIndex: 2, // Invernaderos activo
        onTap: (_) {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior
            _TopBar(name: name, isOwner: isOwner, isMobile: isMobile),

            Expanded(
              child: isMobile
                  ? _MobileLayout(
                      name: name,
                      rows: rows,
                      columns: columns,
                      isOwner: isOwner,
                    )
                  : _DesktopLayout(
                      name: name,
                      rows: rows,
                      columns: columns,
                      isOwner: isOwner,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// BARRA SUPERIOR
class _TopBar extends StatelessWidget {
  final String name;
  final bool isOwner;
  final bool isMobile;
  const _TopBar({
    required this.name,
    required this.isOwner,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      color: AppColors.green800,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Botón editar solo si es admin — solo en escritorio por espacio
          if (isOwner && !isMobile)
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.edit_outlined,
                size: 14,
                color: Colors.white,
              ),
              label: const Text(
                'Editar',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

          // En móvil solo el ícono de editar
          if (isOwner && isMobile) ...[
            const SizedBox(width: 4),
            IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.white70,
                size: 19,
              ),
              onPressed: () {},
            ),
          ],
        ],
      ),
    );
  }
}

// LAYOUT MÓVIL — info arriba, cuadrícula abajo
class _MobileLayout extends StatelessWidget {
  final String name;
  final int rows, columns;
  final bool isOwner;
  const _MobileLayout({
    required this.name,
    required this.rows,
    required this.columns,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tarjeta de información general
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.green50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.home_work_outlined,
                        color: AppColors.green600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          _RoleBadge(isOwner: isOwner),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 14),

                // Stats en fila de 3
                Row(
                  children: [
                    Expanded(
                      child: _InfoStat(label: 'Filas', value: '$rows'),
                    ),
                    Container(width: 0.5, height: 36, color: AppColors.border),
                    Expanded(
                      child: _InfoStat(label: 'Columnas', value: '$columns'),
                    ),
                    Container(width: 0.5, height: 36, color: AppColors.border),
                    Expanded(
                      child: _InfoStat(
                        label: 'Total',
                        value: '${rows * columns}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Cuadrícula visual
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Distribución',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    _LegendDot(
                      color: AppColors.green50,
                      border: AppColors.green200,
                      label: 'Sana',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$rows filas × $columns columnas',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // La cuadrícula tiene altura fija en móvil para no ocupar toda la pantalla
                SizedBox(
                  height: 280,
                  child: _DetailGrid(rows: rows, cols: columns),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// LAYOUT ESCRITORIO — panel izquierdo + cuadrícula derecha
class _DesktopLayout extends StatelessWidget {
  final String name;
  final int rows, columns;
  final bool isOwner;
  const _DesktopLayout({
    required this.name,
    required this.rows,
    required this.columns,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Panel izquierdo — info del invernadero
        Container(
          width: 260,
          color: AppColors.surface,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícono grande
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  color: AppColors.green600,
                  size: 25,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              _RoleBadge(isOwner: isOwner),
              const SizedBox(height: 20),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 20),

              // Datos del invernadero
              _InfoRow(label: 'Filas', value: '$rows'),
              const SizedBox(height: 10),
              _InfoRow(label: 'Columnas', value: '$columns'),
              const SizedBox(height: 10),
              _InfoRow(label: 'Total cuadrículas', value: '${rows * columns}'),
              const SizedBox(height: 10),
              _InfoRow(
                label: 'Estado',
                value: 'Activo',
                valueColor: AppColors.green600,
              ),

              const Spacer(),
            ],
          ),
        ),

        Container(width: 0.5, color: AppColors.border),

        // Panel derecho — cuadrícula visual
        Expanded(
          child: Container(
            color: AppColors.background,
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Distribución del invernadero',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    _LegendDot(
                      color: AppColors.green50,
                      border: AppColors.green200,
                      label: 'Sana',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$rows filas × $columns columnas · ${rows * columns} cuadrículas',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // La cuadrícula ocupa todo el espacio disponible
                Expanded(
                  child: _DetailGrid(rows: rows, cols: columns),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// CUADRÍCULA DETALLADA CON COORDENADAS
class _DetailGrid extends StatelessWidget {
  final int rows, cols;
  const _DetailGrid({required this.rows, required this.cols});

  @override
  Widget build(BuildContext context) {
    if (rows == 0 || cols == 0) {
      return const Center(
        child: Text(
          'Sin datos de cuadrícula',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcula el tamaño de celda que cabe en el espacio disponible
        final maxW = (constraints.maxWidth - (cols - 1) * 3) / cols;
        final maxH = (constraints.maxHeight - (rows - 1) * 3) / rows;
        final cell = (maxW < maxH ? maxW : maxH).clamp(18.0, 72.0);

        final gridW = cell * cols + (cols - 1) * 3;
        final gridH = cell * rows + (rows - 1) * 3;

        return Center(
          child: Container(
            width: gridW,
            height: gridH,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.green400, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                itemCount: rows * cols,
                itemBuilder: (_, index) {
                  final r = index ~/ cols + 1;
                  final c = index % cols + 1;
                  return Container(
                    color: AppColors.green50,
                    child: Center(
                      child: Text(
                        '$r,$c',
                        style: TextStyle(
                          fontSize: cell < 30 ? 7 : 9,
                          color: AppColors.green400,
                          fontWeight: FontWeight.w500,
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

// WIDGETS PEQUEÑOS DE APOYO

// Fila de dato: etiqueta a la izq, valor a la der (panel desktop)
class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// Estadística centrada (panel móvil en fila de 3)
class _InfoStat extends StatelessWidget {
  final String label, value;
  const _InfoStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// Badge Admin / Operario
class _RoleBadge extends StatelessWidget {
  final bool isOwner;
  const _RoleBadge({required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOwner ? AppColors.green50 : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isOwner ? 'Admin' : 'Operario',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isOwner ? AppColors.green700 : const Color(0xFF854F0B),
        ),
      ),
    );
  }
}

// Punto de leyenda del mapa
class _LegendDot extends StatelessWidget {
  final Color color, border;
  final String label;
  const _LegendDot({
    required this.color,
    required this.border,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

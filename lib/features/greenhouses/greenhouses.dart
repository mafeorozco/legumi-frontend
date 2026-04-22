import 'package:flutter/material.dart';
import 'package:legumi/core/services/greenhouses_services.dart';
import 'package:legumi/core/theme/app_theme.dart';
import 'package:legumi/features/greenhouses/add_greenhouse.dart';
import 'package:legumi/features/greenhouses/greenhouse_detail_page.dart';
import 'package:legumi/shared/widgets/menu_inferior.dart';

class GreenhousesPage extends StatefulWidget {
  const GreenhousesPage({super.key});

  @override
  State<GreenhousesPage> createState() => _GreenhousesPageState();
}

class _GreenhousesPageState extends State<GreenhousesPage> {
  final _service = GreenhousesService();
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Carga la lista de invernaderos del usuario
  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.fetchMyGreenhouses();
      if (mounted)
        setState(() {
          _items = data;
          _isLoading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Abre el formulario para crear un invernadero y recarga al volver
  Future<void> _goCreate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddGreenhousesPage()),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
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
            _TopBar(onBack: () => Navigator.pop(context), onAdd: _goCreate),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.green600,
                        strokeWidth: 2,
                      ),
                    )
                  : _items.isEmpty
                  ? _EmptyState(onAdd: _goCreate)
                  : isMobile
                  ? _MobileList(items: _items)
                  : _DesktopGrid(items: _items),
            ),
          ],
        ),
      ),
    );
  }
}

// BARRA SUPERIOR
class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onAdd;
  const _TopBar({required this.onBack, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      height: 58,
      color: AppColors.green800,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Botón de regreso
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: onBack,
          ),
          const SizedBox(width: 6),
          const Text(
            'Mis invernaderos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),

          // Botón agregar — ícono en móvil, texto en escritorio
          isMobile
              ? IconButton(
                  padding: EdgeInsets.zero,
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                  onPressed: onAdd,
                )
              : ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 15),
                  label: const Text('Nuevo invernadero'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.green800,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ESTADO VACÍO
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.home_work_outlined,
              color: AppColors.green400,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin invernaderos',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Crea tu primer invernadero para comenzar',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Crear invernadero'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// LISTA MÓVIL — tarjetas verticales en columna
class _MobileList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _MobileList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _MobileCard(
        data: items[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GreenhouseDetailPage(greenhouse: items[i]),
          ),
        ),
      ),
    );
  }
}

// TARJETA MÓVIL — fila compacta con info y mini cuadrícula
class _MobileCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  const _MobileCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rows = data['rows'] as int? ?? 0;
    final cols = data['columns'] as int? ?? 0;
    final isOwner = data['is_owner'] as bool? ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            // Mini cuadrícula a la izquierda
            SizedBox(
              width: 56,
              height: 56,
              child: _MiniGrid(rows: rows, cols: cols),
            ),
            const SizedBox(width: 14),

            // Información central
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'Sin nombre',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$rows filas × $cols columnas · ${rows * cols} cuadrículas',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _RoleBadge(isOwner: isOwner),
                ],
              ),
            ),

            // Flecha derecha
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// GRID ESCRITORIO — tarjetas en cuadrícula adaptativa
class _DesktopGrid extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _DesktopGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contador de resultados
          Text(
            '${items.length} invernadero${items.length != 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) => _DesktopCard(
              data: items[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GreenhouseDetailPage(greenhouse: items[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// TARJETA ESCRITORIO — cuadrícula visual + info debajo
class _DesktopCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  const _DesktopCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rows = data['rows'] as int? ?? 0;
    final cols = data['columns'] as int? ?? 0;
    final isOwner = data['is_owner'] as bool? ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: nombre + badge de rol
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.home_work_outlined,
                    color: AppColors.green600,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    data['name'] ?? 'Sin nombre',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _RoleBadge(isOwner: isOwner),
              ],
            ),
            const SizedBox(height: 4),

            // Dimensiones
            Text(
              '$rows × $cols · ${rows * cols} cuadrículas',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            // Mini cuadrícula ocupa el espacio restante
            Expanded(
              child: _MiniGrid(rows: rows, cols: cols),
            ),
          ],
        ),
      ),
    );
  }
}

// MINI CUADRÍCULA — representación visual del invernadero
class _MiniGrid extends StatelessWidget {
  final int rows, cols;
  const _MiniGrid({required this.rows, required this.cols});

  @override
  Widget build(BuildContext context) {
    if (rows == 0 || cols == 0) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.green50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.green100),
        ),
        child: const Center(
          child: Icon(
            Icons.grid_off_outlined,
            color: AppColors.green200,
            size: 18,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.green200, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          itemCount: rows * cols,
          itemBuilder: (_, __) => Container(color: AppColors.green50),
        ),
      ),
    );
  }
}

// BADGE DE ROL — Admin o Operario
class _RoleBadge extends StatelessWidget {
  final bool isOwner;
  const _RoleBadge({required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isOwner ? AppColors.green50 : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isOwner ? 'Admin' : 'Operario',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isOwner ? AppColors.green700 : const Color(0xFF854F0B),
        ),
      ),
    );
  }
}

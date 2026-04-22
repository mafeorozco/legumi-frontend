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

  Future<void> _load() async {
    try {
      final data = await _service.fetchMyGreenhouses();
      if (mounted) setState(() { _items = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              icon: const Icon(Icons.arrow_back,
                color: Colors.white, size: 20)),
            const SizedBox(width: 8),
            const Text('Mis invernaderos',
              style: TextStyle(color: Colors.white, fontSize: 18,
                fontWeight: FontWeight.w700)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => const AddGreenhousesPage()));
                _load();
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Nuevo invernadero'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.green800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
                textStyle: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ),

        Expanded(
          child: _isLoading
            ? const Center(child: CircularProgressIndicator(
                color: AppColors.green600))
            : _items.isEmpty
              ? _buildEmpty()
              : _buildGrid(),
        ),

        const MenuInferior(),
      ]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.home_work_outlined,
              color: AppColors.green400, size: 40)),
          const SizedBox(height: 16),
          const Text('Sin invernaderos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Crea tu primer invernadero para comenzar',
            style: TextStyle(fontSize: 14,
              color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(context,
                MaterialPageRoute(
                  builder: (_) => const AddGreenhousesPage()));
              _load();
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Crear invernadero'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 12)),
          ),
        ]),
    );
  }

  Widget _buildGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_items.length} invernadero'
            '${_items.length != 1 ? 's' : ''}',
            style: const TextStyle(fontSize: 13,
              color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
              const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent : 340,
                crossAxisSpacing   : 16,
                mainAxisSpacing    : 16,
                childAspectRatio   : 1.1,
              ),
            itemCount: _items.length,
            itemBuilder: (_, i) => _GreenhouseCard(
              data : _items[i],
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) =>
                  GreenhouseDetailPage(greenhouse: _items[i]))),
            ),
          ),
        ]),
    );
  }
}

// CARD

class _GreenhouseCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  const _GreenhouseCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rows    = data['rows']    as int? ?? 0;
    final cols    = data['columns'] as int? ?? 0;
    final isOwner = data['is_owner'] as bool? ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.home_work_outlined,
                  color: AppColors.green600, size: 20)),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['name'] ?? 'Sin nombre',
                    style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis),
                  Text('$rows × $cols · ${rows * cols} cuadriculas',
                    style: const TextStyle(fontSize: 12,
                      color: AppColors.textSecondary)),
                ])),
              // Badge de rol
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOwner
                    ? AppColors.green50 : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isOwner ? 'Admin' : 'Operario',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: isOwner
                      ? AppColors.green800
                      : const Color(0xFF854F0B)),
                )),
            ]),
            const SizedBox(height: 12),
            Expanded(child: _MiniGrid(rows: rows, cols: cols)),
          ]),
      ),
    );
  }
}

class _MiniGrid extends StatelessWidget {
  final int rows, cols;
  const _MiniGrid({required this.rows, required this.cols});

  @override
  Widget build(BuildContext context) {
    if (rows == 0 || cols == 0) return const SizedBox();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.green100, width: 1),
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
          itemBuilder: (_, __) =>
            Container(color: AppColors.green50),
        ),
      ),
    );
  }
}
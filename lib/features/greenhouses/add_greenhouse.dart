import 'package:flutter/material.dart';
import 'package:legumi/core/services/greenhouses_services.dart';
import 'package:legumi/core/theme/app_theme.dart';
import 'package:legumi/shared/widgets/menu_inferior.dart';

class AddGreenhousesPage extends StatefulWidget {
  const AddGreenhousesPage({super.key});

  @override
  State<AddGreenhousesPage> createState() => _AddGreenhousesPageState();
}

class _AddGreenhousesPageState extends State<AddGreenhousesPage> {
  final _nameController    = TextEditingController();
  final _rowsController    = TextEditingController();
  final _columnsController = TextEditingController();
  final _formKey           = GlobalKey<FormState>();
  final _service           = GreenhousesService();
  bool _loading = false;
  int  _rows = 0, _cols = 0;

  @override
  void initState() {
    super.initState();
    _rowsController.addListener(_updateGrid);
    _columnsController.addListener(_updateGrid);
  }

  @override
  void dispose() {
    _rowsController.removeListener(_updateGrid);
    _columnsController.removeListener(_updateGrid);
    _nameController.dispose();
    _rowsController.dispose();
    _columnsController.dispose();
    super.dispose();
  }

  void _updateGrid() => setState(() {
    _rows = int.tryParse(_rowsController.text) ?? 0;
    _cols = int.tryParse(_columnsController.text) ?? 0;
  });

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      // El backend toma el users_id del token — no hay que mandarlo
      await _service.createGreenhouse(
        name   : _nameController.text.trim(),
        rows   : _rows,
        columns: _cols,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invernadero creado con éxito')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())));
    }

    if (mounted) setState(() => _loading = false);
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
            const Text('Nuevo invernadero',
              style: TextStyle(color: Colors.white, fontSize: 18,
                fontWeight: FontWeight.w700)),
          ]),
        ),

        Expanded(
          child: Row(children: [
            // Formulario
            SizedBox(
              width: 420,
              child: Container(
                color: AppColors.background,
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Datos del invernadero',
                        style: TextStyle(fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      const Text('Ingresa el nombre y dimensiones',
                        style: TextStyle(fontSize: 14,
                          color: AppColors.textSecondary)),
                      const SizedBox(height: 28),

                      _label('Nombre'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Ej: Invernadero Norte',
                          prefixIcon: Icon(Icons.home_work_outlined,
                            size: 18, color: AppColors.textSecondary)),
                        validator: (v) => v == null || v.isEmpty
                          ? 'Ingresa un nombre' : null,
                      ),
                      const SizedBox(height: 20),

                      Row(children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Filas'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _rowsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Ej: 5',
                                prefixIcon: Icon(Icons.table_rows_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary)),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Requerido';
                                if ((int.tryParse(v) ?? 0) <= 0) return '> 0';
                                return null;
                              },
                            ),
                          ])),
                        const SizedBox(width: 16),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Columnas'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _columnsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Ej: 4',
                                prefixIcon: Icon(Icons.view_column_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary)),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Requerido';
                                if ((int.tryParse(v) ?? 0) <= 0) return '> 0';
                                return null;
                              },
                            ),
                          ])),
                      ]),

                      const SizedBox(height: 12),

                      if (_rows > 0 && _cols > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.green50,
                            borderRadius: BorderRadius.circular(10)),
                          child: Row(children: [
                            const Icon(Icons.eco_outlined,
                              size: 16, color: AppColors.green600),
                            const SizedBox(width: 8),
                            Text('Total: ${_rows * _cols} cuadriculas',
                              style: const TextStyle(fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.green800)),
                          ])),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading
                            ? const SizedBox(height: 18, width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                            : const Text('Crear invernadero'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Container(width: 0.5, color: AppColors.border),

            // Vista previa cuadrícula (sin cambios)
            Expanded(
              child: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vista previa',
                      style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(_rows > 0 && _cols > 0
                      ? '$_rows filas × $_cols columnas'
                      : 'Ingresa dimensiones para ver la cuadrícula',
                      style: const TextStyle(fontSize: 13,
                        color: AppColors.textSecondary)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _rows > 0 && _cols > 0
                        ? _GridPreview(rows: _rows, cols: _cols)
                        : Center(child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64, height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.green50,
                                  borderRadius: BorderRadius.circular(16)),
                                child: const Icon(Icons.grid_on_outlined,
                                  color: AppColors.green400, size: 32)),
                              const SizedBox(height: 12),
                              const Text('La cuadrícula aparecerá aquí',
                                style: TextStyle(fontSize: 14,
                                  color: AppColors.textSecondary)),
                            ])),
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

  Widget _label(String text) => Text(text,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
      color: AppColors.textSecondary));
}

class _GridPreview extends StatelessWidget {
  final int rows, cols;
  const _GridPreview({required this.rows, required this.cols});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final cellSize = (constraints.maxWidth / cols)
        .clamp(0.0, constraints.maxHeight / rows);
      return Center(
        child: Container(
          width: cellSize * cols, height: cellSize * rows,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.green600, width: 2),
            borderRadius: BorderRadius.circular(8)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 2, mainAxisSpacing: 2),
              itemCount: rows * cols,
              itemBuilder: (_, index) {
                final r = index ~/ cols + 1;
                final c = index % cols + 1;
                return Container(
                  color: AppColors.green50,
                  child: Center(child: Text('$r,$c',
                    style: const TextStyle(fontSize: 9,
                      color: AppColors.green400))));
              },
            ),
          ),
        ),
      );
    });
  }
}
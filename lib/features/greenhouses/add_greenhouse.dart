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
  final _nameCtrl = TextEditingController();
  final _rowsCtrl = TextEditingController();
  final _colsCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _service = GreenhousesService();

  bool _loading = false;
  int _rows = 0, _cols = 0;

  @override
  void initState() {
    super.initState();
    // Actualiza la vista previa cada vez que cambian los campos de dimensiones
    _rowsCtrl.addListener(_updateGrid);
    _colsCtrl.addListener(_updateGrid);
  }

  @override
  void dispose() {
    _rowsCtrl.removeListener(_updateGrid);
    _colsCtrl.removeListener(_updateGrid);
    _nameCtrl.dispose();
    _rowsCtrl.dispose();
    _colsCtrl.dispose();
    super.dispose();
  }

  void _updateGrid() => setState(() {
    _rows = int.tryParse(_rowsCtrl.text) ?? 0;
    _cols = int.tryParse(_colsCtrl.text) ?? 0;
  });

  // Valida y envía el formulario al servidor
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await _service.createGreenhouse(
        name: _nameCtrl.text.trim(),
        rows: _rows,
        columns: _cols,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invernadero creado con éxito')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
            _TopBar(onBack: () => Navigator.pop(context)),

            Expanded(child: isMobile ? _buildMobile() : _buildDesktop()),
          ],
        ),
      ),
    );
  }

  //  Vista móvil: formulario + vista previa en columna 
  Widget _buildMobile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Formulario
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Datos del invernadero',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFormFields(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Vista previa de la cuadrícula
          if (_rows > 0 && _cols > 0) ...[
            Container(
              height: 200,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vista previa · $_rows × $_cols',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _GridPreview(rows: _rows, cols: _cols),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Botón crear
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Crear invernadero',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  //  Vista escritorio: formulario izq | vista previa der 
  Widget _buildDesktop() {
    return Row(
      children: [
        // Panel izquierdo — formulario
        SizedBox(
          width: 380,
          child: Container(
            color: AppColors.background,
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Datos del invernadero',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ingresa el nombre y las dimensiones',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildFormFields(),

                  const Spacer(),

                  // Botón crear al fondo del panel
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Crear invernadero',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Container(width: 0.5, color: AppColors.border),

        // Panel derecho — vista previa
        Expanded(
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vista previa',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _rows > 0 && _cols > 0
                      ? '$_rows filas × $_cols columnas · ${_rows * _cols} cuadrículas'
                      : 'Ingresa las dimensiones para ver la cuadrícula',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: _rows > 0 && _cols > 0
                      ? _GridPreview(rows: _rows, cols: _cols)
                      : _EmptyPreview(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //  Campos del formulario
  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre
        const _Label('Nombre'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'Ej: Invernadero Norte',
            prefixIcon: Icon(
              Icons.home_work_outlined,
              size: 17,
              color: AppColors.textSecondary,
            ),
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Ingresa un nombre' : null,
        ),
        const SizedBox(height: 16),

        // Filas y columnas en fila
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('Filas'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _rowsCtrl,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Ej: 5',
                      prefixIcon: Icon(
                        Icons.table_rows_outlined,
                        size: 17,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if ((int.tryParse(v) ?? 0) <= 0) return '> 0';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('Columnas'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _colsCtrl,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      hintText: 'Ej: 4',
                      prefixIcon: Icon(
                        Icons.view_column_outlined,
                        size: 17,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if ((int.tryParse(v) ?? 0) <= 0) return '> 0';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        // Chip informativo de total de cuadrículas
        if (_rows > 0 && _cols > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppColors.green600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total: ${_rows * _cols} cuadrículas',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.green800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// BARRA SUPERIOR
class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

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
            onPressed: onBack,
          ),
          const SizedBox(width: 6),
          const Text(
            'Nuevo invernadero',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// VISTA PREVIA DE CUADRÍCULA
class _GridPreview extends StatelessWidget {
  final int rows, cols;
  const _GridPreview({required this.rows, required this.cols});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = (constraints.maxWidth - (cols - 1) * 2) / cols;
        final maxH = (constraints.maxHeight - (rows - 1) * 2) / rows;
        final cell = (maxW < maxH ? maxW : maxH).clamp(0.0, 80.0);

        return Center(
          child: Container(
            width: cell * cols + (cols - 1) * 2,
            height: cell * rows + (rows - 1) * 2,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.green600, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
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
                          fontSize: cell < 28 ? 7 : 9,
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

// PLACEHOLDER CUANDO NO HAY DIMENSIONES
class _EmptyPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.grid_on_outlined,
              color: AppColors.green300,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'La cuadrícula aparecerá aquí',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ETIQUETA DE CAMPO
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    ),
  );
}

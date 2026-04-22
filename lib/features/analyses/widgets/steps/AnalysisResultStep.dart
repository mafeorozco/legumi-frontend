import 'dart:io';
import 'package:flutter/material.dart';
import 'package:legumi/core/services/analyses_service.dart';

class SendAnalysisStep extends StatefulWidget {
  final String imagePath;
  final int greenhouseId;

  const SendAnalysisStep({
    super.key,
    required this.imagePath,
    required this.greenhouseId,
  });

  @override
  State<SendAnalysisStep> createState() => _SendAnalysisStepState();
}

class _SendAnalysisStepState extends State<SendAnalysisStep> {
  final AnalysesService _service = AnalysesService();

  // ── Estados posibles ──────────────────────
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _sendAnalysis(); // Se envía automáticamente al entrar al paso
  }

  Future<void> _sendAnalysis() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.createAnalysis(
        greenhouseId: widget.greenhouseId,
        imageFile: File(widget.imagePath),
      );

      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _result = result;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Cargando ──────────────────────────────
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            CircularProgressIndicator(color: Color(0xFF3D7A2A)),
            SizedBox(height: 16),
            Text(
              'Analizando imagen...',
              style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
            ),
          ],
        ),
      );
    }

    // ── Error ─────────────────────────────────
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.red),
            ),
            const SizedBox(height: 20),
            // Botón para reintentar
            OutlinedButton.icon(
              onPressed: _sendAnalysis,
              icon: const Icon(Icons.refresh, color: Color(0xFF3D7A2A)),
              label: const Text(
                'Reintentar',
                style: TextStyle(color: Color(0xFF3D7A2A)),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF3D7A2A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Éxito ─────────────────────────────────
    if (_isSuccess && _result != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen enviada
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(widget.imagePath),
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),

          // Resultado de la API
          // Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFF4FAF0),
          //     border: Border.all(color: const Color(0xFF3D7A2A)),
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const Row(
          //         children: [
          //           Icon(
          //             Icons.check_circle,
          //             color: Color(0xFF3D7A2A),
          //             size: 20,
          //           ),
          //           SizedBox(width: 8),
          //           Text(
          //             'Análisis completado',
          //             style: TextStyle(
          //               fontWeight: FontWeight.w600,
          //               color: Color(0xFF3D7A2A),
          //             ),
          //           ),
          //         ],
          //       ),
          //       const Divider(height: 20),

          //       // Muestra los campos que devuelva tu API
          //       // Ajusta las keys según tu respuesta real
          //       if (_result!['plaga'] != null)
          //         _ResultRow(
          //           label: 'Plaga detectada',
          //           value: _result!['plaga'],
          //         ),
          //       if (_result!['confianza'] != null)
          //         _ResultRow(
          //           label: 'Confianza',
          //           value: '${_result!['confianza']}%',
          //         ),
          //       if (_result!['recomendacion'] != null)
          //         _ResultRow(
          //           label: 'Recomendación',
          //           value: _result!['recomendacion'],
          //         ),
          //     ],
          //   ),
          // ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

// ── Widget helper para filas del resultado ──
// class _ResultRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _ResultRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF1A1A1A),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 13, color: Color(0xFF444444)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

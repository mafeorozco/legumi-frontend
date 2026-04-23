import 'dart:io';
import 'package:flutter/material.dart';
import 'package:legumi/core/services/analyses_service.dart';
import 'package:legumi/features/analyses/models/analysis_result.dart';


class SendAnalysisStep extends StatefulWidget {
  final String imagePath;
  final ValueChanged<AnalysisResult> onSuccess;

  const SendAnalysisStep({super.key, required this.imagePath, required this.onSuccess});

  @override
  State<SendAnalysisStep> createState() => _SendAnalysisStepState();
}

class _SendAnalysisStepState extends State<SendAnalysisStep> {
  final AnalysesService _service = AnalysesService();

  // ── Estados posibles ──────────────────────
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  AnalysisResult? _analysisResult;
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
        imageFile: File(widget.imagePath),
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _result = result;
      });

      await Future.delayed(const Duration(seconds: 1));
      final response = AnalysisResult.fromJson(result);
      widget.onSuccess(response);
    } catch (e) {
      if (!mounted) return;
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
  return const Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFF16372C)),
          SizedBox(height: 16),
          Text(
            'Analizando imagen...',
            style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
          ),
        ],
      ),
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
          Text(""),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

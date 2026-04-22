import 'package:flutter/material.dart';
import 'package:legumi/features/analyses/components/BottomButton.dart';
import 'package:legumi/features/analyses/components/HeroHeader.dart';
import 'package:legumi/features/analyses/components/StepProgressBar.dart';
import 'package:legumi/features/analyses/models/detect_pest_step.dart';
import 'package:legumi/features/analyses/models/green_house_selection.dart';
import 'package:legumi/features/analyses/models/grid_position.dart';
import 'package:legumi/features/analyses/widgets/steps/AnalysisResultStep.dart';
import 'package:legumi/features/analyses/widgets/steps/GridGreenhouseStep.dart';
import 'package:legumi/features/analyses/widgets/steps/SaveImageStep.dart';
import 'package:legumi/features/analyses/widgets/steps/SelectedGreenHouseStep.dart';

class AnalysePestScreen extends StatefulWidget {
  const AnalysePestScreen({super.key});

  @override
  State<AnalysePestScreen> createState() => _AnalysePestScreenState();
}

class _AnalysePestScreenState extends State<AnalysePestScreen> {
  int _currentStep = 0;
  GreenhouseSelection? selectedGreenhouse;
  List<GridPosition> selectedPositions = [];
  String? _imagePath;

  List<DetectPestStep> get _steps => [
    DetectPestStep(
      title: 'Sube tu imagen de la plaga o tomale una foto',
      content: SaveImageStep(
        onImageSelected: (path) {
          setState(() => _imagePath = path);
        },
      ),
    ),
    DetectPestStep(
      title: '',
      content: (_imagePath != null)
          ? SendAnalysisStep(
              imagePath: _imagePath!,
              onSuccess: () {
                setState(() => _currentStep++);
              },
            )
          : const Center(child: Text('Faltan datos del paso anterior')),
    ),
    DetectPestStep(
      title: "Selecciona el invernadero",
      content: SelectedGreenHouseStep(
        onGreenhouseSelected: (greenhouse) {
          setState(() => selectedGreenhouse = greenhouse);
        },
      ),
    ),
    DetectPestStep(
      title: "Selecciona las zonas afectadas de tu invernadero",
      content: (selectedGreenhouse != null) 
      ? GridGreenhouseStep(
        greenhouse: selectedGreenhouse!,
        onSelectionChanged: (positions) {
          setState(() => selectedPositions = positions);
        },
      )
      : const Text('Primero selecciona un invernadero'),
      
    )
  ];

  void _onNext() {
    print("Imagen ${_imagePath}");
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      // Último paso → acción final
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Detección enviada')));
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
Widget build(BuildContext context) {
  final step = _steps[_currentStep];

  return Scaffold(
    backgroundColor: Colors.white,
    body: Stack(
      children: [
        // 1. Hero de fondo
        HeroHeader(),

        // 2. Todo el contenido encima del hero
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 156), 

            // Contenedor blanco redondeado
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Botón back + progress bar
                    GestureDetector(
                      onTap: _onBack,
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Icon(
                          Icons.arrow_back,
                          color: Color.fromARGB(255, 27, 27, 27),
                          size: 22,
                        ),
                      ),
                    ),
                    StepProgressBar(
                      totalSteps: _steps.length,
                      currentStep: _currentStep,
                    ),
                    const SizedBox(height: 24),

                    // Título del paso
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Contenido del paso
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            step.content,
                            const SizedBox(height: 100), // espacio para el botón
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // 3. Botón flotante abajo
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: BottomButton(
            label: _currentStep < _steps.length - 1 ? 'SIGUIENTE' : 'VER RESULTADO',
            onPressed: _onNext,
          ),
        ),
      ],
    ),
  );
}
}

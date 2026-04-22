import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:legumi/features/reports/edit_report.dart';
import 'package:legumi/shared/widgets/curve.dart';
import 'package:legumi/core/services/ubications_plants_services.dart';
import 'package:legumi/core/services/reports_services.dart';
import 'package:legumi/shared/widgets/menu_inferior.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({required this.data, super.key});
  final Map<String, dynamic> data;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final reportsService = ReportsServices();
  late Map<String, dynamic> report;

  final ubicationPlantsService = UbicationsPlantsServices();
  List<int> positions = [];

  int rows = 0;
  int columns = 0;

  @override
  void initState() {
    super.initState();
    //Aqui estoy asignando la informacion que hay en data a report
    report = widget.data;

    loadPlantsAffected();

    //Estoy trayendo las columnas y filas del invernadero del reporte
    rows = report['greenhouse']['rows'] ?? 0;
    columns =  report['greenhouse']['columns'] ?? 0;
  }

  //Aqui estoy cargando las plantas afectadas
  void loadPlantsAffected() async {
    try {
      debugPrint('Mostrar las platas afectadas');
      final plantsAffected = await ubicationPlantsService.fetchUbicationsPlants(report['id']);
      debugPrint('Plantas afectadas: ${jsonEncode(plantsAffected)}');

      //Aqui estoy filtrando solamente el numero de la posicion
      final ubicationPlants = plantsAffected
          .where((e) => e.isNotEmpty && e['position'] != null)
          .map<int>((e) => e['position'] as int)
          .toList();

      setState(() {
        positions = ubicationPlants;
      });
    } catch (e) {
      debugPrint('Error en loadItem: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: Curvature(),
                  child: Container(height: 150, color: Colors.green),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Image.asset(
                      'assets/images/zanahoria.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Boton atras
                      IconButton(
                        icon: Image.asset(
                          'assets/images/atras.png',
                          width: 30,
                          height: 30,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),

                      //Boton editar
                      IconButton(
                        icon: Image.asset(
                          'assets/images/edit.png',
                          width: 30,
                          height: 30,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditReportPage(report_data: report, positions_data: positions),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '${report['pest_by_plants_id'] ?? 'Sin nombre'}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ) ??
                        const TextStyle(color: Colors.black, fontSize: 24),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Ubicación: ${report['greenhouse']['name'] ?? 'Sin invernadero'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black) ??
                        const TextStyle(color: Colors.black, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Fecha: ${report['date'] ?? 'Sin fecha'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black) ??
                        const TextStyle(color: Colors.black, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Tipo de planta: ${report['plants_id'] ?? 'Sin planta'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black) ??
                        const TextStyle(color: Colors.black, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Parte afectada: ${report['partplant']['name'] ?? 'Sin parte de la planta'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black) ??
                        const TextStyle(color: Colors.black, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Plantas afectadas:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black) ??
                        const TextStyle(color: Colors.black, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  //Cuadricula
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns > 0 ? columns : 1,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        itemCount: rows * columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          bool isAffected = positions.contains(index);
                          return Container(
                            decoration: BoxDecoration(
                              color: isAffected ? Colors.red : Colors.white,
                              border: Border.all(color: Colors.black),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      //Menu
      bottomNavigationBar: const MenuInferior(),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:legumi/core/services/reports_services.dart';
import 'package:legumi/features/reports/add_report.dart';
import 'package:legumi/features/reports/report.dart';
import 'package:legumi/shared/widgets/menu_inferior.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final apiService = ReportsServices();
  List<Map<String, dynamic>> reports = [];
  int ? user_id;

  @override
  void initState() {
    super.initState();
    initData();
  }

  //Aqui inicializo los datos de los reportes del usuario 
  Future<void> initData() async {
    final id = await loadUserId();
    if (id != null) {
      await loadItem(id);
    } else {
      debugPrint('No se pudo cargar el user_id');
    }
  }

  //Aqui cargo el Id
  Future<int?> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
     debugPrint('El id es  $id');
    return id;
  }

  //Aqui estoy cargando los reportes del usuario
  Future<void> loadItem(int userId) async {
    try {
      debugPrint('Mostrar los reportes del usuario $userId');
      final data = await apiService.fetchReports(8);
      debugPrint('Reportes: ${jsonEncode(data)}');
      setState(() {
        reports = data;
      });
    } catch (e) {
      debugPrint('Error en loadItem: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial de reportes")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddReportPage()),
              );
            },
            child: const Text("Agregar uno nuevo"),
          ),
          Expanded(
            child: reports.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Cargando o no hay datos disponibles"),
                      ],
                    ),
                  )
                : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final item = reports[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportPage(data: item),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['pest_by_plants_id'] ?? 'No hay nombre :(',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${item['date'] ?? 'No hay fechas :('}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )

          ),
        ],
      ),
      bottomNavigationBar: const MenuInferior(),
    );
  }
}

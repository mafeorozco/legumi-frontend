import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:legumi/shared/widgets/curve.dart';
import 'package:legumi/core/services/reports_services.dart';
import 'package:legumi/core/services/greenhouses_services.dart';
import 'package:legumi/core/services/ubications_plants_services.dart';
import 'package:legumi/shared/widgets/menu_inferior.dart';
import 'package:legumi/features/home/presentation/screens/inicio_screen.dart';


//Si hay un StatefulWidget, deben haber dos clases: 
class EditReportPage extends StatefulWidget {
  const EditReportPage({required this.report_data, required this.positions_data, super.key});
  final Map<String, dynamic> report_data;
  final List<int> positions_data;
  
  @override
  State<EditReportPage> createState() => _EditReportPageState();
}

//Aqui es la zona dinamica de la aplicacion
class _EditReportPageState extends State<EditReportPage> {
  final reportsService = ReportsServices();
  final greenhousesServices = GreenhousesServices();
  final ubicationPlantsService = UbicationsPlantsServices();
  
  late Map<String, dynamic> report;

  int? greenhouse; // Aquí se guarda el id del nuevo invernadero
  int? part_plant; // Aquí se guarda el id parte de la planta
  int? report_id;
  int rows = 0;
  int columns = 0;

  List<Map<String, dynamic>> parts_plants = [];
  List<Map<String, dynamic>> greenhouses= [];
  List <int> positions=[];
  
  @override
    void initState() {
      super.initState();
      loadPartsPlants();
      loadGreenhouses();
      report = widget.report_data;
      positions = widget.positions_data;

      //Asignando los valores predeterminados del reporte
      part_plant = report['partplant']?['id'];
      greenhouse = report['greenhouse']?['id'];
      rows = report['greenhouse']['rows'] ?? 0;
      columns =  report['greenhouse']['columns'] ?? 0;
      report_id = report['id'];
    }

  //Aqui estoy trayendo toda la informacion de las partes de la plantas
    void loadPartsPlants() async {
      try {
        debugPrint('Mostrar las partes de la planta');
        
        final partes_plantas = await reportsService.fetchPartsPlants();
        debugPrint('Partes de las plantas: ${jsonEncode(partes_plantas)}');

        setState(() {
          parts_plants = partes_plantas; 
        });
      } catch (e) {
        debugPrint('Error en loadItem: $e');
      }
    }

    //Aqui estoy trayendo toda la informacion de los invernaderos
    void loadGreenhouses() async {
      try {
        debugPrint('Mostrar los invernaderos');
        
        final greenhouses_ = await greenhousesServices.fetchGreenhouses();
        debugPrint('Los invernaderos son: ${jsonEncode(greenhouses_)}');

        setState(() {
          greenhouses = greenhouses_; 
        });
      } catch (e) {
        debugPrint('Error en loadItem: $e');
      }
    }

    Future<void> _submitForm() async {
      try {
        //Aqui estoy guardando los datos del reporte
        final data = {
          'greenhouses_id': greenhouse,
          'parts_plants_id': part_plant
        };
        debugPrint("Se han actualizados los datos del reporte: $report_id");

        final reponse = await reportsService.updateReport(report['id'], data);
        debugPrint("nuevos datos guardados: $reponse");

        //Aqui estoy eliminando las plantas afectadas actuales
        final deleteResponse = await ubicationPlantsService.deletePlantsAffected(report['id']);

        //Aqui estoy guardando las nuevas ubicaciones de las plantas
        for (final ubication in positions){
          final ubications = {
            "position": ubication,
            "report_id": report_id,
          };
        
          final ubicationResponse = await ubicationPlantsService.insertPlantsAffected(ubications);
          debugPrint("Ubicación guardada: $ubicationResponse");
        }

        
      } catch (e) {
        debugPrint("Error $e");
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
              ],
            ),

            //Botones
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Botones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botón "atrás" con imagen
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

                          Text(
                            'Editar reporte', 
                            style:
                              Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.black,
                              ) ??
                              const TextStyle(color: Colors.black, fontSize: 16),
                          ),
                            
                          // Botón de guardar el reporte
                          IconButton(
                            icon: Image.asset(
                              'assets/images/check.png',
                              width: 30,
                              height: 30,
                            ),
                            onPressed: () async {
                              await _submitForm(); // Ejecuta tu función
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => InicioScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            //Textos
            Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [

                          //Ingresar nuevo invernadero
                          Row(
                            children: [
                              Text(
                                'Invernadero:',
                                style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.black,
                                ) ??
                                const TextStyle(color: Colors.black, fontSize: 16),
                              ),
                              SizedBox(width: 15), // espacio entre texto y campo
                              Expanded(
                                child:
                                //Menu desplegable con los invernaderos  
                                DropdownButton<int>(
                                  value: greenhouse,
                                  items: greenhouses.map<DropdownMenuItem<int>>((greenH) {
                                    return DropdownMenuItem<int>(
                                      value: greenH['id'],
                                      child: Text(greenH['name']?.toString() ?? 'Sin nombre'),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      greenhouse = value;
                                    });
                                  },
                                )
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          
                          //Ingresar nueva parte de la planta
                          Row(
                            children: [
                              Text(
                                'Parte de la planta afectada:',
                                style:
                                  Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.black,
                                  ) ??
                                  const TextStyle(color: Colors.black, fontSize: 16),
                              ),
                              SizedBox(width: 15), // espacio entre texto y campo
                              Expanded(
                                child:  
                                //Menu desplegable con las partes de la plantas
                                DropdownButton<int>(
                                  value: part_plant,
                                  items: parts_plants.map<DropdownMenuItem<int>>((part) {
                                    return DropdownMenuItem<int>(
                                      value: part['id'],
                                      child: Text(part['name']?.toString() ?? 'Sin nombre'),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      part_plant = value;
                                    });
                                  },
                                )
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          //Ingresar nuevas plantas affectadas
                          Row( 
                            children: [
                              Text(
                                'Plantas afectadas:',
                                style:
                                  Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.black,
                                  ) ??
                                  const TextStyle(color: Colors.black, fontSize: 16),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

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
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        // Alterna el estado de afectado
                                        if (isAffected) {
                                          positions.remove(index);
                                        } else {
                                          positions.add(index);
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isAffected ? Colors.red : Colors.white,
                                        border: Border.all(color: Colors.black),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ]
                      ),
                    ),
                  ]
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MenuInferior(),
    );
  }
}
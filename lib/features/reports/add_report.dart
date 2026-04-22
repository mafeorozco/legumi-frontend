import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:legumi/core/services/reports_services.dart';
import 'package:legumi/core/services/greenhouses_services.dart';
import 'package:intl/intl.dart';
import 'package:legumi/core/services/ubications_plants_services.dart';
import 'package:legumi/features/home/presentation/screens/inicio_screen.dart';

class AddReportPage extends StatefulWidget {
  const AddReportPage({super.key});

  @override
  State<AddReportPage> createState() => _AddReportPageState();
}

class _AddReportPageState extends State<AddReportPage> {
  final reportsService = ReportsServices();
  final greenhousesServices = GreenhousesServices();
  final ubicationsPlantsServices = UbicationsPlantsServices();

  final TextEditingController _plants = TextEditingController();
  final TextEditingController _pest = TextEditingController();

  int? greenhouse; // Aquí se guarda el id del nuevo invernadero
  int? part_plant; // Aquí se guarda el id parte de la planta
  int? report_id;
  List<Map<String, dynamic>> parts_plants = [];
  List<Map<String, dynamic>> greenhouses= [];
  List <int> positions=[];

  @override
    void initState() {
      super.initState();
      loadPartsPlants();
      loadGreenhouses();
    }

   @override
  void dispose() {
    _plants.dispose();
    _pest.dispose();
    super.dispose();
  }

  void loadPartsPlants() async {
    try {
      debugPrint('Mostrar las partes de la planta');
      //Aqui estoy trayendo toda la informacion de las ubicaciones de las plantas afectadas
      final partes_plantas = await reportsService.fetchPartsPlants();
      debugPrint('Partes de las plantas: ${jsonEncode(partes_plantas)}');

      setState(() {
        parts_plants = partes_plantas; 
      });
    } catch (e) {
      debugPrint('Error en loadItem: $e');
    }
  }

  void loadGreenhouses() async {
    try {
      debugPrint('Mostrar los invernaderos');
      //Aqui estoy trayendo toda la informacion de los invernadero
      final greenhouses_ = await greenhousesServices.fetchGreenhouses();
      debugPrint('Los invernaderos son: ${jsonEncode(greenhouses_)}');

      setState(() {
        greenhouses = greenhouses_; 
      });
    } catch (e) {
      debugPrint('Error en loadItem: $e');
    }
  }


  //Esto va a guardar los datos que han sido ingresado
  Future<void> _submitForm() async {
    final plant = _plants.text;
    final pest = _pest.text;
    final DateTime fechaActual = DateTime.now();
    final String date = DateFormat('yyyy-MM-dd').format(fechaActual);

    try {
      //Aqui estoy guardando los datos del reporte
      final data = {
        'date': date,
        'plants_id': plant,
        'pest_by_plants_id': pest,
        'greenhouses_id': greenhouse,
        'parts_plants_id': part_plant
      };

      //debugPrint(jsonEncode(data));

      final response = await reportsService.createReport(data);
      debugPrint("respuesta $response");

      report_id = response['id'];
      debugPrint("Id del reporte: $report_id");

      //Aqui estoy guardando las ubicaciones de las plantas
      for (final ubication in positions){
        final ubications = {
          "position": ubication,
          "report_id": report_id,
        };
      
        final ubicationResponse = await ubicationsPlantsServices.insertPlantsAffected(ubications);
        debugPrint("Ubicación guardada: $ubicationResponse");
      }
    } catch (e) {
      debugPrint("Error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi reporte")),
      body: Column(
        children: [
          SizedBox(
            width: 350,
            child: TextField(
              // obscureText: true,
              controller: _plants,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nombre planta',
              ),
              keyboardType: TextInputType.text,
            ),
          ),
          SizedBox(
            width: 350,
            child: TextField(
              // obscureText: true,
              controller: _pest,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nombre plaga',
              ),
              keyboardType: TextInputType.text,
            ),
          ),
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
                  items: greenhouses.map<DropdownMenuItem<int>>((p) {
                    return DropdownMenuItem<int>(
                      value: p['id'],
                      child: Text(p['name']?.toString() ?? 'Sin nombre'),
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
          const SizedBox(height: 24),
          //Cuadricula
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
              ),
              child: GridView.count(
                //aqui se dice el numero en el que se van a repartir las celdas
                crossAxisCount: 4,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 1.0,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                //Esto dice el numero total de celdas
                children: List.generate(20, (index) {
                  //Aqui se seleccionan las celdas
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
                }),
              ),
            )
          ),                            
          ElevatedButton(
            onPressed: () async {
              await _submitForm(); // Ejecuta tu función
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InicioScreen()),
              );
            },
            child: const Text('Crear Reporte'),
          ),
        ],
      ),
    );
  }
}
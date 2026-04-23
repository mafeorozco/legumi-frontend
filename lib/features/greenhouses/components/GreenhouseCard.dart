import 'package:flutter/material.dart';
import 'package:legumi/features/greenhouses/components/PlantGrid.dart';
import 'package:material_symbols_icons/symbols.dart';


class GreenhouseCard extends StatelessWidget {
  final String name;
  final int rows;
  final int columns;
 
  const GreenhouseCard({
    super.key,
    required this.name,
    required this.rows,
    required this.columns,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFADD1A5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                // Icono casita — círculo
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16372C),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Symbols.home_and_garden, 
                    color: Color(0xFFADD1A5),
                    size: 25,
                    fill: 0,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.black87)),
                    Text('Filas: $rows  Columnas:$columns',
                        style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
                const Spacer(),
                // Iconos eco apuntando a la izquierda (Transform.flip),
                // uno grande y uno pequeño desplazado abajo-derecha
                SizedBox(
                  width: 50,
                  height: 40,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Hoja grande — arriba a la izquierda
                      Positioned(
                        top:-10,
                        left: -10,
                        child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.14159), // flip horizontal
                          child: const Icon(
                            Symbols.eco, 
                            color: Color(0xFF16372C),
                             size: 40,
                             fill: 0,
                             weight: 600,
                             )                      ),
                      ),
                      // Hoja pequeña — abajo a la derecha
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(3.14159),
                          child: const Icon(
                            Symbols.eco, 
                            color: Color(0xFF16372C),
                             size: 30,
                             fill: 0,
                             weight: 600,
                             ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,  // ← esto centra el grid
              children: [
                PlantGrid(rows: rows, columns: columns),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFADD1A5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, color: Color(0xFF16372C), size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
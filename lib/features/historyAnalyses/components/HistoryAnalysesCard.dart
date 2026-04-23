import 'package:flutter/material.dart';
import 'package:legumi/features/greenhouses/components/PlantGrid.dart';
import 'package:material_symbols_icons/symbols.dart';


class HistoryCard extends StatelessWidget {
  final String title;
  final String date;
  final String greenhouse;
  final String severity;

  const HistoryCard({
    super.key,
    required this.title,
    required this.date,
    required this.greenhouse,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header verde ──────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          child:
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFADD1A5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                // Ícono izquierda
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16372C),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Symbols.content_paste, color: Color(0xFFADD1A5), size: 20, fill: 1),
                ),
                const SizedBox(width: 10),
                // Título y fecha
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.black87)),
                    Text(date,
                        style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
                const Spacer(),
                // Ícono planta derecha
                SizedBox(
                  width: 50,
                  height: 40,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Hoja grande — arriba a la izquierda
                      Positioned(
                        bottom:-18,
                        left: -10,
                        child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.14159), // flip horizontal
                          child: const Icon(
                            Symbols.potted_plant, 
                            color: Color(0xFF16372C),
                             size: 55,
                             fill: 0,
                             weight: 500,
                             )                      
                        ),
                      ),
                    ],
                  ),
                ),
                // Icon(Symbols.potted_plant, color: Color(0xFF16372C), size: 36, fill: 1),
              ],
            ),
          ),
          ),

          // ── Cuerpo ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    children: [
                      const TextSpan(
                          text: 'Invernadero: ',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: greenhouse),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    children: [
                      const TextSpan(
                          text: 'Severidad: ',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: severity),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Botón flecha ──────────────────────────────────────────
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
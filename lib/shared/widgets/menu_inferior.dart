import 'package:flutter/material.dart';

class MenuInferior extends StatelessWidget {
  const MenuInferior({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_outlined, 'Inicio'),
          _buildNavItem(Icons.crop_free_outlined, 'Escanear'),
          _buildNavItem(Icons.history_outlined, 'Historial'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: label == 'Escanear' ? const Color(0xFF4CAF50) : Colors.transparent,
            shape: label == 'Escanear' ? BoxShape.circle : BoxShape.rectangle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: label == 'Escanear' ? Colors.white : const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4CAF50),
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

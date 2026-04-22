import 'package:flutter/material.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader();
 
  @override
  Widget build(BuildContext context) {
    return Container(
      // Altura total = imagen visible + espacio para que la tarjeta se superponga
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF2D5016), // fallback si no hay imagen
        image: DecorationImage(
          image: AssetImage('assets/images/img_hero.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.35),
              Colors.black.withOpacity(0.1),
            ],
          ),
        ),
        padding: const EdgeInsets.only(top: 56, left: 20),
        alignment: Alignment.topLeft,
        child: const Text(
          'Detectar plaga',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
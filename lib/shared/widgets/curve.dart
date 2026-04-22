import 'package:flutter/material.dart';

//Intento de curvatura
//Aqui se define la forma de la curva
class Curvature extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    //Punto inicial: esquina inferior izquierda
    path.moveTo(0, size.height);

    //Curva ascendente en el lado izquierdo
    path.quadraticBezierTo(
      size.width * 0.1, size.height - 42, // control izquierdo
      size.width * 0.25, size.height - 40, // punto intermedio izquierdo
    );

    //Línea recta por el centro
    path.lineTo(size.width * 0.75, size.height - 40);

    // Curva descendente en el lado derecho
    path.quadraticBezierTo(
      size.width * 0.9, size.height - 42, // control derecho
      size.width, size.height, // esquina inferior derecha
    );

    // Cierra el resto del contenedor
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  //Esto dice que la curva no cambia
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


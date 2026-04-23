class PestClassification {
  final int id;
  final String name;

  PestClassification({required this.id, required this.name});

  factory PestClassification.fromJson(Map<String, dynamic> json) =>
      PestClassification(id: json['id'], name: json['name']);
}

class Pest {
  final int id;
  final String name;
  final String descripcion;
  final PestClassification clasification;

  Pest({required this.id, required this.name, required this.descripcion, required this.clasification});

  factory Pest.fromJson(Map<String, dynamic> json) => Pest(
        id: json['id'],
        name: json['name'],
        descripcion: json['descripcion'],
        clasification: PestClassification.fromJson(json['clasification']),
      );
}
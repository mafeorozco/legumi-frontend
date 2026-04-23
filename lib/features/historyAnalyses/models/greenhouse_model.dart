class GreenhouseModel {
  final int id;
  final String name;
  final int rows;
  final int columns;

  GreenhouseModel({
    required this.id,
    required this.name,
    required this.rows,
    required this.columns,
  });

  factory GreenhouseModel.fromJson(Map<String, dynamic> json) {
    return GreenhouseModel(
      id:      json['id'],
      name:    json['name'],
      rows:    json['rows'],
      columns: json['columns'],
    );
  }
}
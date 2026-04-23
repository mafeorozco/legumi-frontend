

class AnalysisResultModel {
  final int id;
  final String severity;
  final DateTime? dateTimeCreate;
  final List<PlantLocationModel> plantLocations;
  final PestModel? pest;

  AnalysisResultModel({
    required this.id,
    required this.severity,
    this.dateTimeCreate,
    this.plantLocations = const [],
    this.pest,
  });

  factory AnalysisResultModel.fromJson(Map<String, dynamic> json) {
    return AnalysisResultModel(
      id:             json['id'],
      severity:       json['severity'],
      dateTimeCreate: json['Date_Time_Create'] != null
                        ? DateTime.parse(json['Date_Time_Create'])
                        : null,
      pest:           json['pest'] != null
                        ? PestModel.fromJson(json['pest'])
                        : null,
      plantLocations: (json['plant_locations'] as List<dynamic>? ?? [])
                        .map((l) => PlantLocationModel.fromJson(l))
                        .toList() ?? [],
    );
  }
}

class PestModel {
  final int id;
  final String name;
  final String? descripcion;

  PestModel({
    required this.id,
    required this.name,
    this.descripcion,
  });

  factory PestModel.fromJson(Map<String, dynamic> json) {
    return PestModel(
      id:          json['id'],
      name:        json['name'],
      descripcion: json['descripcion'],
    );
  }
}

class PlantLocationModel {
  final int id;
  final int row;
  final int column;
  final int analysisResultsId;

  PlantLocationModel({
    required this.id,
    required this.row,
    required this.column,
    required this.analysisResultsId,
  });

  factory PlantLocationModel.fromJson(Map<String, dynamic> json) {
    return PlantLocationModel(
      id:                json['id'],
      row:               json['row'],
      column:            json['column'],
      analysisResultsId: json['analysis_results_id'],
    );
  }
}
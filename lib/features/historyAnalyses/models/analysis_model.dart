// analysis_model.dart
import 'package:legumi/features/historyAnalyses/models/analysis_result_model.dart';
import 'package:legumi/features/historyAnalyses/models/greenhouse_model.dart';

class AnalysisModel {
  final int id;
  final String imagePath;
  final DateTime? dateTimeCreate;
  final int greenhousesId;
  final GreenhouseModel? greenhouse;
  final List<AnalysisResultModel> results;

  AnalysisModel({
    required this.id,
    required this.imagePath,
    this.dateTimeCreate,
    required this.greenhousesId,
    this.greenhouse,
    this.results = const [],
  });

  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    return AnalysisModel(
      id:             json['id'],
      imagePath:      json['image_path'],
      dateTimeCreate: json['Date_Time_Create'] != null
                        ? DateTime.parse(json['Date_Time_Create'])
                        : null,
      greenhousesId:  json['greenhouses_id'],
      greenhouse:     json['greenhouse'] != null
                        ? GreenhouseModel.fromJson(json['greenhouse'])
                        : null,
      results:        (json['results'] as List<dynamic>? ?? [])
                        .map((r) => AnalysisResultModel.fromJson(r))
                        .toList(),
    );
  }
}
import 'package:legumi/features/analyses/models/detect_pest_step.dart';
import 'package:legumi/features/analyses/models/detected_pest.dart';

class AnalysisResult {
  final int analysisId;
  final String imagePath;
  final String dateTimeCreate;
  final List<DetectedPest> detectedPests;
  final String message;

  AnalysisResult({
    required this.analysisId,
    required this.imagePath,
    required this.dateTimeCreate,
    required this.detectedPests,
    required this.message,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
        analysisId: json['analysis_id'],
        imagePath: json['image_path'],
        dateTimeCreate: json['Date_Time_Create'],
        detectedPests: (json['detected_pests'] as List)
            .map((e) => DetectedPest.fromJson(e))
            .toList(),
        message: json['message'],
      );
}
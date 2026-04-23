

import 'package:legumi/features/analyses/models/pest.dart';

class DetectedPest {
  final int resultId;
  final Pest pest;
  final String severity;
  final int detectionsCount;

  DetectedPest({required this.resultId, required this.pest, required this.severity, required this.detectionsCount});

  factory DetectedPest.fromJson(Map<String, dynamic> json) => DetectedPest(
        resultId: json['result_id'],
        pest: Pest.fromJson(json['pest']),
        severity: json['severity'],
        detectionsCount: json['detections_count'],
      );
}
// File: lib/features/labour/data/labour_models.dart
// Purpose: Typed models for contractor + labour + documents.
// Used by: labour_api_service, labour_repository, providers, screens.

import 'package:flutter/foundation.dart';

@immutable
class Contractor {
  const Contractor({required this.id, required this.name});
  final String id;
  final String name;
  factory Contractor.fromJson(Map<String, dynamic> j) =>
      Contractor(id: j['id'] as String, name: j['name'] as String);
}

@immutable
class Labour {
  const Labour({
    required this.id,
    required this.name,
    required this.skill,
    required this.contractorId,
    required this.contractorName,
    required this.active,
    this.dob,
    this.faceEnrolledId,
    this.panCardUrl,
    this.aadhaarUrl,
  });

  final String id;
  final String name;
  final String skill;
  final String contractorId;
  final String contractorName;
  final bool active;
  final DateTime? dob;
  final String? faceEnrolledId;
  final String? panCardUrl;
  final String? aadhaarUrl;

  factory Labour.fromJson(Map<String, dynamic> j) => Labour(
        id: j['id'] as String,
        name: j['name'] as String,
        skill: j['skill'] as String,
        contractorId: j['contractorId'] as String,
        contractorName: j['contractorName'] as String,
        active: (j['active'] as bool?) ?? true,
        dob: j['dob'] == null ? null : DateTime.parse(j['dob'] as String),
        faceEnrolledId: j['faceEnrolledId'] as String?,
        panCardUrl: j['panCardUrl'] as String?,
        aadhaarUrl: j['aadhaarUrl'] as String?,
      );

  Labour copyWith({
    String? name,
    String? skill,
    String? contractorId,
    String? contractorName,
    bool? active,
    DateTime? dob,
    String? faceEnrolledId,
    String? panCardUrl,
    String? aadhaarUrl,
  }) =>
      Labour(
        id: id,
        name: name ?? this.name,
        skill: skill ?? this.skill,
        contractorId: contractorId ?? this.contractorId,
        contractorName: contractorName ?? this.contractorName,
        active: active ?? this.active,
        dob: dob ?? this.dob,
        faceEnrolledId: faceEnrolledId ?? this.faceEnrolledId,
        panCardUrl: panCardUrl ?? this.panCardUrl,
        aadhaarUrl: aadhaarUrl ?? this.aadhaarUrl,
      );
}

@immutable
class LabourDocument {
  const LabourDocument({
    required this.type,
    required this.url,
    required this.uploadedAt,
  });
  final String type; // 'Aadhaar', 'PAN', etc.
  final String url;
  final DateTime uploadedAt;

  factory LabourDocument.fromJson(Map<String, dynamic> j) => LabourDocument(
        type: j['type'] as String,
        url: j['url'] as String,
        uploadedAt: DateTime.parse(j['uploadedAt'] as String),
      );
}

/// Allowed skill values — backend can later return this list; for now a fixed set
/// keeps validation simple.
const List<String> kSkillOptions = [
  'Skilled Welder',
  'Mason',
  'Steel Fitter',
  'Helper',
  'Electrician',
  'Carpenter',
];

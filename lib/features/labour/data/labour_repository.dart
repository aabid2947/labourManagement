// File: lib/features/labour/data/labour_repository.dart
// Purpose: Domain wrapper for LabourApiService — typed Contractor / Labour / LabourDocument.
// Used by: features/labour/providers/labour_providers.dart.

import 'labour_api_service.dart';
import 'labour_models.dart';

class LabourRepository {
  LabourRepository({LabourApiService? api}) : _api = api ?? LabourApiService();
  final LabourApiService _api;

  Future<List<Contractor>> fetchContractors() async {
    final list = await _api.fetchContractors();
    return list.map(Contractor.fromJson).toList(growable: false);
  }

  Future<int> fetchLabourCount({required String contractorId}) =>
      _api.fetchLabourCount(contractorId: contractorId);

  Future<List<Labour>> fetchLabour({required String contractorId}) async {
    final list = await _api.fetchLabour(contractorId: contractorId);
    return list.map(Labour.fromJson).toList(growable: false);
  }

  Future<List<LabourDocument>> fetchDocuments({required String labourId}) async {
    final list = await _api.fetchLabourDocuments(labourId: labourId);
    return list.map(LabourDocument.fromJson).toList(growable: false);
  }

  Future<String> createLabour({
    required String contractorId,
    required String name,
    required String skill,
    required DateTime dob,
    String? panCardLocalPath,
    String? aadhaarLocalPath,
  }) {
    final payload = <String, dynamic>{
      'contractorId': contractorId,
      'name': name,
      'skill': skill,
      'dob': dob.toIso8601String(),
      // Files would be uploaded as multipart in the real call.
      'panCardLocalPath': panCardLocalPath,
      'aadhaarLocalPath': aadhaarLocalPath,
    };
    return _api.createLabour(payload);
  }

  Future<bool> updateLabour({
    required String id,
    required String contractorId,
    required String name,
    required String skill,
    required DateTime dob,
  }) =>
      _api.updateLabour(id: id, payload: {
        'contractorId': contractorId,
        'name': name,
        'skill': skill,
        'dob': dob.toIso8601String(),
      });

  Future<String> enrollFace({
    required String labourId,
    required String imageB64,
  }) =>
      _api.enrollFace(labourId: labourId, imageB64: imageB64);

  Future<bool> setActive({required String id, required bool active}) =>
      _api.setLabourActive(id: id, active: active);
}

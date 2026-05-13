// File: lib/features/labour/data/labour_api_service.dart
// Purpose: Network stubs for contractors + labour + face enroll + documents.
// Used by: features/labour/data/labour_repository.dart.

import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class LabourApiService {
  LabourApiService({Dio? dio}) : _dio = dio ?? DioClient().dio;
  final Dio _dio;

  // TODO(api): GET /contractors — response: [{id, name}]
  Future<List<Map<String, dynamic>>> fetchContractors() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [
      {'id': 'abc', 'name': 'ABC Construction Pvt. Ltd.'},
      {'id': 'shree', 'name': 'Shree Construction'},
      {'id': 'green', 'name': 'GreenLine Builders'},
    ];
    // Real: return (await _dio.get('/contractors')).data as List<Map<String, dynamic>>;
  }

  // TODO(api): GET /labour/count?contractorId= — response: {total: int}
  Future<int> fetchLabourCount({required String contractorId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _mockLabour(contractorId).length;
  }

  // TODO(api): GET /labour?contractorId= —
  //   response: [{id, name, skill, contractorId, contractorName, active, dob, ...}]
  Future<List<Map<String, dynamic>>> fetchLabour({
    required String contractorId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _mockLabour(contractorId);
  }

  // TODO(api): GET /labour/{id}/documents — response: [{type, url, uploadedAt}]
  Future<List<Map<String, dynamic>>> fetchLabourDocuments({
    required String labourId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final iso = DateTime.now().subtract(const Duration(days: 12)).toIso8601String();
    return [
      {
        'type': 'Aadhaar',
        'url': 'https://files.example.com/$labourId/aadhaar.pdf',
        'uploadedAt': iso,
      },
      {
        'type': 'PAN',
        'url': 'https://files.example.com/$labourId/pan.pdf',
        'uploadedAt': iso,
      },
    ];
  }

  // TODO(api): POST /labour — request: {<full form fields>}, response: {id}
  Future<String> createLabour(Map<String, dynamic> payload) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return 'lab-${DateTime.now().millisecondsSinceEpoch}';
    // Real: return (await _dio.post('/labour', data: payload)).data['id'] as String;
  }

  // TODO(api): PUT /labour/{id} — request: {<form fields>}, response: {success}
  Future<bool> updateLabour({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return true;
  }

  // TODO(api): POST /labour/face/enroll — request: {image_b64, labourId},
  //   response: {success, faceId}
  Future<String> enrollFace({
    required String labourId,
    required String imageB64,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return 'face-${labourId.hashCode.abs()}';
  }

  // TODO(api): PATCH /labour/{id}/active — request: {active: bool}, response: {success}
  Future<bool> setLabourActive({
    required String id,
    required bool active,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  // ───── Deterministic mock dataset so the screens render data offline ─────
  List<Map<String, dynamic>> _mockLabour(String contractorId) {
    final byContractor = <String, List<Map<String, dynamic>>>{
      'abc': [
        _l('lab-1', 'Ramesh Kumar', 'Skilled Welder', contractorId, true),
        _l('lab-2', 'Suresh Yadav', 'Mason', contractorId, true),
        _l('lab-3', 'Imran Shaikh', 'Steel Fitter', contractorId, true),
        _l('lab-4', 'Mahesh Patel', 'Helper', contractorId, false),
        _l('lab-5', 'Vikram Singh', 'Electrician', contractorId, true),
        _l('lab-6', 'Ajay Kumar', 'Carpenter', contractorId, true),
      ],
      'shree': [
        _l('lab-7', 'Rakesh Kumar', 'Mason', contractorId, true),
        _l('lab-8', 'Mukesh Sharma', 'Helper', contractorId, true),
      ],
      'green': [
        _l('lab-9', 'Pawan Verma', 'Carpenter', contractorId, true),
      ],
    };
    return byContractor[contractorId] ?? const [];
  }

  Map<String, dynamic> _l(
    String id,
    String name,
    String skill,
    String contractorId,
    bool active,
  ) {
    final contractorName = switch (contractorId) {
      'abc' => 'ABC Construction Pvt. Ltd.',
      'shree' => 'Shree Construction',
      'green' => 'GreenLine Builders',
      _ => 'Unknown',
    };
    return {
      'id': id,
      'name': name,
      'skill': skill,
      'contractorId': contractorId,
      'contractorName': contractorName,
      'active': active,
      'dob': DateTime(1992, 4, 15).toIso8601String(),
    };
  }

  // ignore: unused_element
  Dio get _client => _dio;
}

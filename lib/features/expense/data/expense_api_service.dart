// File: lib/features/expense/data/expense_api_service.dart
// Purpose: Network stubs for the Expense feature.
// Used by: features/expense/data/expense_repository.dart.

import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class ExpenseApiService {
  ExpenseApiService({Dio? dio}) : _dio = dio ?? DioClient().dio;
  final Dio _dio;

  // TODO(api): GET /expense/summary — response: {total: number, pendingCount: int}
  Future<Map<String, dynamic>> fetchSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const {'total': 42800, 'pendingCount': 12};
  }

  // TODO(api): GET /expense?status=pending|in_progress|approved|rejected
  //   response: [{id, category, amount, date, status, notes?, attachmentUrl?}]
  Future<List<Map<String, dynamic>>> fetchByStatus(String status) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _mock(status);
  }

  // TODO(api): POST /expense/claim — request: {ids: [...]}, response: {success: bool}
  Future<bool> claim({required List<String> ids}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return true;
    // Real: return ((await _dio.post('/expense/claim', data: {'ids': ids}))
    //     .data as Map<String, dynamic>)['success'] == true;
  }

  // TODO(api): POST /expense — request:
  //   {items: [{category, amount, date, notes, attachments}]},
  //   response: {success: bool, ids: [...]}
  Future<bool> createMany(List<Map<String, dynamic>> items) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return true;
  }

  // ─── Deterministic mock data so the UI renders without a backend ────────────
  List<Map<String, dynamic>> _mock(String status) {
    String iso(int daysAgo) =>
        DateTime.now().subtract(Duration(days: daysAgo)).toIso8601String();
    switch (status) {
      case 'pending':
        return [
          {
            'id': 'e-1',
            'category': 'Site Vehicle Fuel',
            'amount': 2450,
            'date': iso(2),
            'status': 'pending',
          },
          {
            'id': 'e-2',
            'category': 'Safety Gear - Gloves',
            'amount': 1800,
            'date': iso(4),
            'status': 'pending',
          },
          {
            'id': 'e-3',
            'category': 'Site Team Lunch',
            'amount': 4200,
            'date': iso(6),
            'status': 'pending',
          },
          {
            'id': 'e-4',
            'category': 'Cement Transport',
            'amount': 850,
            'date': iso(7),
            'status': 'pending',
          },
        ];
      case 'in_progress':
        return [];
      case 'approved':
        return [
          {
            'id': 'a-1',
            'category': 'Tools & Equipment',
            'amount': 3200,
            'date': iso(10),
            'status': 'approved',
          },
          {
            'id': 'a-2',
            'category': 'Fuel',
            'amount': 1500,
            'date': iso(12),
            'status': 'approved',
          },
        ];
      case 'rejected':
        return [
          {
            'id': 'r-1',
            'category': 'Stationery',
            'amount': 750,
            'date': iso(20),
            'status': 'rejected',
            'notes': 'Outside policy.',
          },
        ];
    }
    return const [];
  }

  // ignore: unused_element
  Dio get _client => _dio;
}

// File: lib/features/expense/data/expense_repository.dart
// Purpose: Domain wrapper for ExpenseApiService — typed models for the UI.
// Used by: features/expense/providers/expense_providers.dart.

import 'expense_api_service.dart';
import 'expense_models.dart';

class ExpenseRepository {
  ExpenseRepository({ExpenseApiService? api})
      : _api = api ?? ExpenseApiService();
  final ExpenseApiService _api;

  Future<ExpenseSummary> fetchSummary() async {
    final j = await _api.fetchSummary();
    return ExpenseSummary(
      total: j['total'] as num,
      pendingCount: j['pendingCount'] as int,
    );
  }

  Future<List<Expense>> fetchByStatus(ExpenseStatus status) async {
    final list = await _api.fetchByStatus(status.apiValue);
    return list.map(Expense.fromJson).toList(growable: false);
  }

  Future<bool> claim({required List<String> ids}) => _api.claim(ids: ids);

  Future<bool> createMany(List<ExpenseDraft> drafts) =>
      _api.createMany(drafts.map((d) => d.toApi()).toList(growable: false));
}

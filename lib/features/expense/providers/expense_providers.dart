// File: lib/features/expense/providers/expense_providers.dart
// Purpose: Riverpod providers for the Expense feature — summary, lists per status,
//          selected tab, pending-row selections (checkboxes).
// Used by: my_expense_screen, add_expense_screen.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/expense_models.dart';
import '../data/expense_repository.dart';

final expenseRepositoryProvider =
    Provider<ExpenseRepository>((_) => ExpenseRepository());

final expenseSummaryProvider = FutureProvider<ExpenseSummary>((ref) {
  return ref.watch(expenseRepositoryProvider).fetchSummary();
});

/// Family keyed on status so each tab caches independently and "Pending →
/// Claim" can `invalidate` only the affected lists.
final expenseByStatusProvider = FutureProvider.autoDispose
    .family<List<Expense>, ExpenseStatus>((ref, status) {
  return ref.watch(expenseRepositoryProvider).fetchByStatus(status);
});

/// Currently visible tab (default = Pending per brief).
class ExpenseTabController extends Notifier<ExpenseStatus> {
  @override
  ExpenseStatus build() => ExpenseStatus.pending;
  void select(ExpenseStatus s) => state = s;
}

final selectedExpenseTabProvider =
    NotifierProvider<ExpenseTabController, ExpenseStatus>(
        ExpenseTabController.new);

/// IDs currently checked on the Pending tab — used by the Claim button.
class PendingSelectionController extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String id) {
    final next = {...state};
    if (!next.add(id)) next.remove(id);
    state = next;
  }

  void clear() => state = <String>{};
}

final pendingSelectionProvider =
    NotifierProvider<PendingSelectionController, Set<String>>(
        PendingSelectionController.new);

/// Local "In Progress" overlay — rows the user has just claimed but the backend
/// hasn't yet reflected. Cleared when the In Progress tab refreshes from API.
class InProgressOverlayController extends Notifier<List<Expense>> {
  @override
  List<Expense> build() => const [];
  void addAll(Iterable<Expense> items) =>
      state = [...state, ...items];
  void clear() => state = const [];
}

final inProgressOverlayProvider =
    NotifierProvider<InProgressOverlayController, List<Expense>>(
        InProgressOverlayController.new);

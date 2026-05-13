// File: lib/features/expense/data/expense_models.dart
// Purpose: Typed models for the My Expense flow — summary, list rows, status tabs.
// Used by: expense_api_service, expense_repository, providers, screens.

import 'package:flutter/foundation.dart';

/// Server statuses we surface on the list. "In Progress" is NOT in the
/// screenshot — it's added per the brief (PDF page 37) and placed immediately
/// before "Approved" in the tab order.
enum ExpenseStatus { pending, inProgress, approved, rejected }

extension ExpenseStatusX on ExpenseStatus {
  String get label => switch (this) {
        ExpenseStatus.pending => 'Pending',
        ExpenseStatus.inProgress => 'In Progress',
        ExpenseStatus.approved => 'Approved',
        ExpenseStatus.rejected => 'Rejected',
      };
  String get apiValue => switch (this) {
        ExpenseStatus.pending => 'pending',
        ExpenseStatus.inProgress => 'in_progress',
        ExpenseStatus.approved => 'approved',
        ExpenseStatus.rejected => 'rejected',
      };
}

/// Tab order matches the brief — Pending | In Progress | Approved | Rejected.
const List<ExpenseStatus> kExpenseTabs = [
  ExpenseStatus.pending,
  ExpenseStatus.inProgress,
  ExpenseStatus.approved,
  ExpenseStatus.rejected,
];

const List<String> kExpenseCategories = [
  'Fuel',
  'Site Vehicle Fuel',
  'Safety Gear - Gloves',
  'Site Team Lunch',
  'Cement Transport',
  'Tools & Equipment',
  'Stationery',
  'Other',
];

@immutable
class ExpenseSummary {
  const ExpenseSummary({required this.total, required this.pendingCount});
  final num total;
  final int pendingCount;
}

@immutable
class Expense {
  const Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.status,
    this.notes,
    this.attachmentUrl,
  });

  final String id;
  final String category;
  final num amount;
  final DateTime date;
  final ExpenseStatus status;
  final String? notes;
  final String? attachmentUrl;

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: j['id'] as String,
        category: j['category'] as String,
        amount: j['amount'] as num,
        date: DateTime.parse(j['date'] as String),
        status: _statusFromString(j['status'] as String),
        notes: j['notes'] as String?,
        attachmentUrl: j['attachmentUrl'] as String?,
      );
}

ExpenseStatus _statusFromString(String s) {
  return switch (s) {
    'pending' => ExpenseStatus.pending,
    'in_progress' => ExpenseStatus.inProgress,
    'approved' => ExpenseStatus.approved,
    'rejected' => ExpenseStatus.rejected,
    _ => ExpenseStatus.pending,
  };
}

/// Local-only payload for a single section of the Add Expense form.
@immutable
class ExpenseDraft {
  const ExpenseDraft({
    required this.id,
    this.category,
    this.amount,
    this.date,
    this.notes,
    this.attachmentLocalPath,
  });

  final String id;
  final String? category;
  final num? amount;
  final DateTime? date;
  final String? notes;
  final String? attachmentLocalPath;

  ExpenseDraft copyWith({
    String? category,
    num? amount,
    DateTime? date,
    String? notes,
    String? attachmentLocalPath,
  }) =>
      ExpenseDraft(
        id: id,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        notes: notes ?? this.notes,
        attachmentLocalPath: attachmentLocalPath ?? this.attachmentLocalPath,
      );

  Map<String, dynamic> toApi() => {
        'category': category,
        'amount': amount,
        'date': date?.toIso8601String(),
        'notes': notes,
        'attachmentLocalPath': attachmentLocalPath,
      };
}

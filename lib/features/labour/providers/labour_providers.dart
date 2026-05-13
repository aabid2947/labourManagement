// File: lib/features/labour/providers/labour_providers.dart
// Purpose: Riverpod providers for contractor + labour state.
// Used by: labour list / induction / documents / labour_in / labour_out screens.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/labour_models.dart';
import '../data/labour_repository.dart';

final labourRepositoryProvider =
    Provider<LabourRepository>((_) => LabourRepository());

final contractorsProvider = FutureProvider<List<Contractor>>((ref) {
  return ref.watch(labourRepositoryProvider).fetchContractors();
});

class SelectedContractorController extends Notifier<Contractor?> {
  @override
  Contractor? build() => null;
  void select(Contractor c) => state = c;
}

final selectedContractorProvider =
    NotifierProvider<SelectedContractorController, Contractor?>(
        SelectedContractorController.new);

final labourListProvider = FutureProvider.autoDispose<List<Labour>>((ref) {
  final c = ref.watch(selectedContractorProvider);
  if (c == null) return Future.value(const <Labour>[]);
  return ref.watch(labourRepositoryProvider).fetchLabour(contractorId: c.id);
});

final labourCountProvider = FutureProvider.autoDispose<int>((ref) {
  final c = ref.watch(selectedContractorProvider);
  if (c == null) return Future.value(0);
  return ref.watch(labourRepositoryProvider).fetchLabourCount(contractorId: c.id);
});

final labourDocumentsProvider =
    FutureProvider.autoDispose.family<List<LabourDocument>, String>((ref, id) {
  return ref.watch(labourRepositoryProvider).fetchDocuments(labourId: id);
});

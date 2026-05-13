// File: lib/features/dashboard/providers/dashboard_providers.dart
// Purpose: Riverpod providers for the dashboard — sites, selected site, summary, expense, location.
// Used by: features/dashboard/presentation/screens/dashboard_screen.dart.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dashboard_models.dart';
import '../data/dashboard_repository.dart';
import '../data/location_service.dart';

final dashboardRepositoryProvider =
    Provider<DashboardRepository>((_) => DashboardRepository());

final locationServiceProvider =
    Provider<LocationService>((_) => LocationService());

final sitesProvider = FutureProvider<List<Site>>((ref) {
  return ref.watch(dashboardRepositoryProvider).fetchSites();
});

class SelectedSiteController extends Notifier<Site?> {
  @override
  Site? build() => null;
  void select(Site s) => state = s;
}

final selectedSiteProvider =
    NotifierProvider<SelectedSiteController, Site?>(SelectedSiteController.new);

final summaryProvider = FutureProvider.autoDispose<DashboardSummary>((ref) {
  final site = ref.watch(selectedSiteProvider);
  if (site == null) {
    throw StateError('No site selected');
  }
  return ref.watch(dashboardRepositoryProvider).fetchSummary(siteId: site.id);
});

final myExpenseProvider = FutureProvider.autoDispose<MyExpense>((ref) {
  final site = ref.watch(selectedSiteProvider);
  if (site == null) {
    throw StateError('No site selected');
  }
  return ref.watch(dashboardRepositoryProvider).fetchMyExpense(siteId: site.id);
});

/// Returns the resolved location label once, cached for the session.
final currentLocationProvider = FutureProvider<String?>((ref) {
  return ref.watch(locationServiceProvider).getCurrentLocationLabel();
});

/// Truncation rule from the brief (PDF page 11):
/// "agar jyada bada location hai to do word dikhao aur Baki dot dot kar do"
String truncateLocation(String raw, {int wordsToKeep = 2, int charLimit = 20}) {
  if (raw.length <= charLimit) return raw;
  final words = raw.split(RegExp(r'\s+'));
  if (words.length <= wordsToKeep) return raw;
  return '${words.take(wordsToKeep).join(' ')}...';
}

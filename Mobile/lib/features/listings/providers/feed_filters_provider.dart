import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedFilters {
  final String query;
  final int? categoryId;
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final String sort;

  const FeedFilters({
    this.query = '',
    this.categoryId,
    this.city,
    this.minPrice,
    this.maxPrice,
    this.sort = 'newest',
  });

  // Sentinel to differentiate "not provided" from "explicitly set to null"
  static const _sentinel = Object();

  FeedFilters copyWith({
    String? query,
    Object? categoryId = _sentinel,
    Object? city = _sentinel,
    Object? minPrice = _sentinel,
    Object? maxPrice = _sentinel,
    String? sort,
  }) {
    return FeedFilters(
      query: query ?? this.query,
      categoryId: categoryId == _sentinel ? this.categoryId : categoryId as int?,
      city: city == _sentinel ? this.city : city as String?,
      minPrice: minPrice == _sentinel ? this.minPrice : minPrice as double?,
      maxPrice: maxPrice == _sentinel ? this.maxPrice : maxPrice as double?,
      sort: sort ?? this.sort,
    );
  }
}

class FeedFiltersNotifier extends Notifier<FeedFilters> {
  @override
  FeedFilters build() {
    return const FeedFilters();
  }

  void updateQuery(String newQuery) {
    state = state.copyWith(query: newQuery);
  }

  void updateSort(String newSort) {
    state = state.copyWith(sort: newSort);
  }

  void applyFilters({
    int? categoryId,
    String? city,
    double? minPrice,
    double? maxPrice,
  }) {
    state = FeedFilters(
      query: state.query,
      sort: state.sort,
      categoryId: categoryId,
      city: city,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  void clearFilters() {
    state = const FeedFilters();
  }
}

final feedFiltersProvider = NotifierProvider<FeedFiltersNotifier, FeedFilters>(
  FeedFiltersNotifier.new,
);

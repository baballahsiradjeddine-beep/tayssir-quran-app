class PaginatedData<T> {
  PaginatedData({
    required this.data,
    required this.page,
    required this.totalPages,
    this.userRank,
  });

  final List<T> data;
  final int page;
  final int totalPages;
  final int? userRank;
}

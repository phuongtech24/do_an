class PagedResult<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int number;
  final int size;

  const PagedResult({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.number,
    required this.size,
  });

  int get pageIndex => number + 1;

  factory PagedResult.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic>) itemParser,
  }) {
    final rawList = (json['content'] as List<dynamic>? ?? const []);
    return PagedResult<T>(
      content: rawList
          .whereType<Map<String, dynamic>>()
          .map(itemParser)
          .toList(),
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      number: (json['number'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? rawList.length,
    );
  }
}

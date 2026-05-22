class ApiResponse<T> {
  final int status;
  final String message;
  final T? data;

  ApiResponse({required this.status, required this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T? Function(Object? raw)? parseData,
  }) {
    return ApiResponse<T>(
      status: (json['status'] as num?)?.toInt() ?? 0,
      message: (json['message'] ?? '').toString(),
      data: parseData != null ? parseData(json['data']) : (json['data'] as T?),
    );
  }
}


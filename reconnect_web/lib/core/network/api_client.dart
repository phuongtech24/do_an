import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_response.dart';

class ApiClient {
  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, String>? headers,
    Object? body,
    T? Function(Object? raw)? parseData,
  }) async {
    final resp = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        if (headers != null) ...headers,
      },
      body: body == null ? null : jsonEncode(body),
    );
    final json = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    return ApiResponse<T>.fromJson(json, parseData: parseData);
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, String>? headers,
    Object? body,
    T? Function(Object? raw)? parseData,
  }) async {
    final resp = await http.put(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        if (headers != null) ...headers,
      },
      body: body == null ? null : jsonEncode(body),
    );
    final json = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    return ApiResponse<T>.fromJson(json, parseData: parseData);
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    Map<String, String>? headers,
    Object? body,
    T? Function(Object? raw)? parseData,
  }) async {
    final resp = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        if (headers != null) ...headers,
      },
      body: body == null ? null : jsonEncode(body),
    );
    final json = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    return ApiResponse<T>.fromJson(json, parseData: parseData);
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    T? Function(Object? raw)? parseData,
  }) async {
    final resp = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        if (headers != null) ...headers,
      },
    );
    final json = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    return ApiResponse<T>.fromJson(json, parseData: parseData);
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
      Map<String, String>? headers,
      T? Function(Object? raw)? parseData,
  }) async {
    final resp = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        if (headers != null) ...headers,
      },
    );
    final json = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    return ApiResponse<T>.fromJson(json, parseData: parseData);
  }
}

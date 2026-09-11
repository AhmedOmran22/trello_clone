import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/exceptions.dart';

class SupabaseServices {
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  /// SELECT - get list of rows
  Future<List<Map<String, dynamic>>> getAll(
    String table, {
    String select = '*',
    Map<String, dynamic>? filters,
  }) async {
    try {
      var query = _client.from(table).select(select);

      if (filters != null) {
        filters.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } on SocketException catch (_) {
      throw const NetworkException(noInternetMessage);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  /// SELECT - get single row by id
  Future<Map<String, dynamic>> getById(
    String table,
    String id, {
    String select = '*',
  }) async {
    try {
      final response = await _client
          .from(table)
          .select(select)
          .eq('id', id)
          .single();

      return response;
    } on SocketException catch (_) {
      throw const NetworkException(noInternetMessage);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  /// INSERT - create a new row
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.from(table).insert(data).select().single();

      return response;
    } on SocketException catch (_) {
      throw const NetworkException(noInternetMessage);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  /// INSERT - create multiple rows
  Future<List<Map<String, dynamic>>> insertMany(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final response = await _client.from(table).insert(data).select();

      return List<Map<String, dynamic>>.from(response);
    } on SocketException catch (_) {
      throw const NetworkException(noInternetMessage);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  /// UPDATE - update a row by id
  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
          .from(table)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return response;
    } on SocketException catch (_) {
      throw const NetworkException(noInternetMessage);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  /// DELETE - delete a row by id
  Future<void> delete(String table, String id) async {
    try {
      await _client.from(table).delete().eq('id', id);
    } on SocketException catch (_) {
      throw const NetworkException(noInternetMessage);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  /// UPSERT - insert or update if exists
  Future<Map<String, dynamic>> upsert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.from(table).upsert(data).select().single();

      return response;
    } on SocketException catch (_) {
      throw const NetworkException(noInternetMessage);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  /// SUBSCRIBE - listen to real-time changes
  Stream<List<Map<String, dynamic>>> subscribe(
    String table, {
    Map<String, dynamic>? filters,
  }) {
    var query = _client.from(table).stream(primaryKey: ['id']);

    if (filters != null) {
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
    }

    return query;
  }
}

import 'package:postgres/postgres.dart';

class DatabaseService {
  static DatabaseService? _instance;
  PostgreSQLConnection? _connection;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  // Database connection configuration
  static const String _host = 'localhost';
  static const int _port = 5432;
  static const String _databaseName = 'nursery_db';
  static const String _username = 'nursery_admin';
  static const String _password = 'nursery_password_2025';

  // Get or create connection
  Future<PostgreSQLConnection> get connection async {
    if (_connection == null || _connection!.isClosed) {
      _connection = PostgreSQLConnection(
        _host,
        _port,
        _databaseName,
        username: _username,
        password: _password,
      );
      await _connection!.open();
    }
    return _connection!;
  }

  // Close connection
  Future<void> close() async {
    if (_connection != null && !_connection!.isClosed) {
      await _connection!.close();
    }
  }

  // Execute query
  Future<List<Map<String, Map<String, dynamic>>>> query(
    String sql, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    final conn = await connection;
    return await conn.mappedResultsQuery(sql,
        substitutionValues: substitutionValues);
  }

  // Execute non-query (INSERT, UPDATE, DELETE)
  Future<int> execute(
    String sql, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    final conn = await connection;
    return await conn.execute(sql, substitutionValues: substitutionValues);
  }

  // Transaction support
  Future<T> transaction<T>(Future<T> Function(dynamic) action) async {
    final conn = await connection;
    return await conn.transaction((ctx) async {
      return await action(ctx);
    });
  }
}

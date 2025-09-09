// Source de données locale avec SharedPreferences
// ==========================================
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/task.dart';

/// DataSource pour la gestion locale des tâches
/// Encapsule la logique de sérialisation/désérialisation
class LocalTaskDataSource {
  final SharedPreferences _sharedPreferences;

  const LocalTaskDataSource(this._sharedPreferences);

  /// Récupère toutes les tâches depuis le stockage local
  Future<List<Task>> getTasks() async {
    try {
      final tasksJson =
          _sharedPreferences.getString(AppConstants.tasksStorageKey);

      if (tasksJson == null || tasksJson.isEmpty) {
        return [];
      }

      final tasksList = jsonDecode(tasksJson) as List<dynamic>;
      return tasksList
          .map((taskJson) => Task.fromJson(taskJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw StorageException(
        message: 'Erreur lors de la lecture des tâches: $e',
        operation: 'getTasks',
        originalError: e,
      );
    }
  }

  /// Sauvegarde la liste complète des tâches
  Future<void> saveTasks(List<Task> tasks) async {
    try {
      final tasksJsonList = tasks.map((task) => task.toJson()).toList();
      final tasksJson = jsonEncode(tasksJsonList);

      await _sharedPreferences.setString(
          AppConstants.tasksStorageKey, tasksJson);
    } catch (e) {
      throw StorageException(
        message: 'Erreur lors de la sauvegarde des tâches: $e',
        operation: 'saveTasks',
        originalError: e,
      );
    }
  }
}
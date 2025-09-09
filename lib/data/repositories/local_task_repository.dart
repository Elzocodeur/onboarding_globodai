// Implémentation concrète du Repository
// ==========================================
import '../../core/errors/app_exception.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local_task_datasource.dart';

/// Implémentation locale du TaskRepository
/// Gère la logique métier et délègue la persistance au DataSource
class LocalTaskRepository implements TaskRepository {
  final LocalTaskDataSource _dataSource;
  List<Task>? _cachedTasks;

  LocalTaskRepository(this._dataSource);

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      _cachedTasks = await _dataSource.getTasks();
      return List.from(
          _cachedTasks!); // Retourne une copie pour préserver l'immutabilité
    } catch (e) {
      throw AppException(
          message: 'Impossible de charger les tâches', originalError: e);
    }
  }

  @override
  Future<void> addTask(Task task) async {
    try {
      _cachedTasks ??= await _dataSource.getTasks();

      // Vérification de l'unicité de l'ID
      if (_cachedTasks!.any((existingTask) => existingTask.id == task.id)) {
        throw AppException(message: 'Une tâche avec cet ID existe déjà');
      }

      _cachedTasks!.add(task);
      await _dataSource.saveTasks(_cachedTasks!);
    } catch (e) {
      throw AppException(
          message: 'Impossible d\'ajouter la tâche', originalError: e);
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    try {
      _cachedTasks ??= await _dataSource.getTasks();

      final index = _cachedTasks!.indexWhere((t) => t.id == task.id);
      if (index == -1) {
        throw TaskNotFoundException(task.id);
      }

      _cachedTasks![index] = task;
      await _dataSource.saveTasks(_cachedTasks!);
    } catch (e) {
      throw AppException(
          message: 'Impossible de mettre à jour la tâche', originalError: e);
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      _cachedTasks ??= await _dataSource.getTasks();

      final taskExists = _cachedTasks!.any((task) => task.id == taskId);
      if (!taskExists) {
        throw TaskNotFoundException(taskId);
      }

      _cachedTasks!.removeWhere((task) => task.id == taskId);
      await _dataSource.saveTasks(_cachedTasks!);
    } catch (e) {
      throw AppException(
          message: 'Impossible de supprimer la tâche', originalError: e);
    }
  }

  @override
  Future<bool> taskExists(String taskId) async {
    try {
      _cachedTasks ??= await _dataSource.getTasks();
      return _cachedTasks!.any((task) => task.id == taskId);
    } catch (e) {
      return false;
    }
  }
}

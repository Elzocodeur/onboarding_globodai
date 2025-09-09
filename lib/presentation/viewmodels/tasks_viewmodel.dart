import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../commands/task_commands.dart';

/// États possibles de l'application
enum TasksViewState {
  initial,
  loading,
  loaded,
  error,
}

/// ViewModel principal gérant l'état des tâches
/// Implémente ChangeNotifier pour la réactivité avec Provider
class TasksViewModel extends ChangeNotifier {
  final TaskRepository _repository;
  final Uuid _uuid = const Uuid();

  // État privé du ViewModel
  List<Task> _tasks = [];
  TasksViewState _state = TasksViewState.initial;
  String? _errorMessage;
  bool _isLoading = false;

  TasksViewModel(this._repository);

  // Getters publics (exposition de l'état en lecture seule)
  List<Task> get tasks => List.unmodifiable(_tasks);
  TasksViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  
  // Computed properties pour l'UI
  int get completedTasksCount => _tasks.where((task) => task.isCompleted).length;
  int get pendingTasksCount => _tasks.where((task) => !task.isCompleted).length;
  bool get hasNoTasks => _tasks.isEmpty;

  /// Initialise le ViewModel en chargeant les tâches
  Future<void> initialize() async {
    await loadTasks();
  }

  /// Charge toutes les tâches depuis le repository
  Future<void> loadTasks() async {
    _setLoadingState(true);
    
    try {
      _tasks = await _repository.getAllTasks();
      _setState(TasksViewState.loaded);
      _clearError();
    } catch (e) {
      _handleError('Erreur lors du chargement des tâches', e);
    } finally {
      _setLoadingState(false);
    }
  }

  /// Ajoute une nouvelle tâche
  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) {
      _setError('Le titre de la tâche ne peut pas être vide');
      return;
    }

    _setLoadingState(true);
    
    try {
      final newTask = Task(
        id: _uuid.v4(),
        title: title.trim(),
        createdAt: DateTime.now(),
      );
      
      final command = AddTaskCommand(_repository, newTask);
      await command.execute();
      
      // Mise à jour optimiste de l'état local
      _tasks = [..._tasks, newTask];
      _setState(TasksViewState.loaded);
      _clearError();
    } catch (e) {
      _handleError('Erreur lors de l\'ajout de la tâche', e);
      // En cas d'erreur, on recharge pour synchroniser l'état
      await loadTasks();
    } finally {
      _setLoadingState(false);
    }
  }

  /// Bascule le statut d'une tâche (complétée/non complétée)
  Future<void> toggleTaskCompletion(String taskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) {
      _setError('Tâche non trouvée');
      return;
    }

    final currentTask = _tasks[taskIndex];
    
    // Mise à jour optimiste de l'UI
    final updatedTask = currentTask.toggleCompletion();
    _tasks = [
      ..._tasks.sublist(0, taskIndex),
      updatedTask,
      ..._tasks.sublist(taskIndex + 1),
    ];
    notifyListeners();

    try {
      final command = ToggleTaskCommand(_repository, updatedTask);
      await command.execute();
      _clearError();
    } catch (e) {
      _handleError('Erreur lors de la mise à jour', e);
      // Rollback en cas d'erreur
      await loadTasks();
    }
  }

  /// Supprime une tâche
  Future<void> deleteTask(String taskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) {
      _setError('Tâche non trouvée');
      return;
    }

    // Sauvegarde pour rollback potentiel
    final removedTask = _tasks[taskIndex];
    
    // Mise à jour optimiste
    _tasks = _tasks.where((task) => task.id != taskId).toList();
    notifyListeners();

    try {
      final command = DeleteTaskCommand(_repository, taskId);
      await command.execute();
      _clearError();
    } catch (e) {
      // Rollback en cas d'erreur
      _tasks = [
        ..._tasks.sublist(0, taskIndex),
        removedTask,
        ..._tasks.sublist(taskIndex),
      ];
      _handleError('Erreur lors de la suppression', e);
      // Recharger pour synchroniser l'état
      await loadTasks();
    }
  }

  // Méthodes privées pour la gestion d'état
  void _setState(TasksViewState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoadingState(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = TasksViewState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == TasksViewState.error) {
      _state = TasksViewState.loaded;
    }
  }

  void _handleError(String message, dynamic error) {
    String finalMessage = message;
    
    if (error is AppException) {
      finalMessage = error.message;
    }
    
    // Log pour le développement
    debugPrint('TasksViewModel Error: $finalMessage - $error');
    _setError(finalMessage);
  }
}
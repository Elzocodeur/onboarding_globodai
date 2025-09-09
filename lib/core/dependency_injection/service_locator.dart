// Configuration de l'injection de dépendances
// ==========================================
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local_task_datasource.dart';
import '../../data/repositories/local_task_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../presentation/viewmodels/tasks_viewmodel.dart';

/// ServiceLocator pour gérer l'injection de dépendances
/// Implémente le pattern Singleton pour une gestion centralisée
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Instances des services
  static SharedPreferences? _sharedPreferences;
  static LocalTaskDataSource? _localTaskDataSource;
  static TaskRepository? _taskRepository;
  static TasksViewModel? _tasksViewModel;

  /// Initialisation asynchrone de toutes les dépendances
  static Future<void> initialize() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    // Injection des dépendances avec le pattern Repository
    _localTaskDataSource = LocalTaskDataSource(_sharedPreferences!);
    _taskRepository = LocalTaskRepository(_localTaskDataSource!);
    _tasksViewModel = TasksViewModel(_taskRepository!);
  }

  // Getters pour accéder aux instances
  static TaskRepository get taskRepository => _taskRepository!;
  static TasksViewModel get tasksViewModel => _tasksViewModel!;
}

// Commands pour les interactions utilisateur
// ==========================================
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../core/errors/app_exception.dart';

/// Command abstrait pour standardiser les interactions
abstract class Command<T> {
  Future<T> execute();
}

/// Command pour ajouter une tâche
class AddTaskCommand extends Command<void> {
  final TaskRepository _repository;
  final Task _task;

  AddTaskCommand(this._repository, this._task);

  @override
  Future<void> execute() async {
    // Validation métier
    if (_task.title.trim().isEmpty) {
      throw const AppException(message: 'Le titre de la tâche ne peut pas être vide');
    }
    
    await _repository.addTask(_task);
  }
}

/// Command pour basculer le statut d'une tâche
class ToggleTaskCommand extends Command<void> {
  final TaskRepository _repository;
  final Task _task;

  ToggleTaskCommand(this._repository, this._task);

  @override
  Future<void> execute() async {
    final updatedTask = _task.toggleCompletion();
    await _repository.updateTask(updatedTask);
  }
}

/// Command pour supprimer une tâche
class DeleteTaskCommand extends Command<void> {
  final TaskRepository _repository;
  final String _taskId;

  DeleteTaskCommand(this._repository, this._taskId);

  @override
  Future<void> execute() async {
    await _repository.deleteTask(_taskId);
  }
}
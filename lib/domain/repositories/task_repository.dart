// Interface abstraite du Repository
// ==========================================
import '../entities/task.dart';

/// Interface abstraite pour le repository des tâches
/// Définit le contrat pour la persistance des données
/// Facilite les tests et permet différentes implémentations
abstract class TaskRepository {
  /// Récupère toutes les tâches stockées
  Future<List<Task>> getAllTasks();

  /// Ajoute une nouvelle tâche
  Future<void> addTask(Task task);

  /// Met à jour une tâche existante
  Future<void> updateTask(Task task);

  /// Supprime une tâche par son ID
  Future<void> deleteTask(String taskId);

  /// Vérifie si une tâche existe
  Future<bool> taskExists(String taskId);
}

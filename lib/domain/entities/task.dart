// Entité métier Task avec Freezed
// ==========================================
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

/// Entité Task immuable représentant une tâche
/// Utilise Freezed pour garantir l'immutabilité et générer les méthodes utilitaires
@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _Task;

  /// Factory constructor pour la désérialisation JSON
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

// Extensions pour ajouter des comportements métier
extension TaskExtensions on Task {
  /// Vérifie si la tâche est récente (créée dans les dernières 24h)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  /// Retourne une copie de la tâche avec le statut inversé
  Task toggleCompletion() {
    return copyWith(
      isCompleted: !isCompleted,
      completedAt: !isCompleted ? DateTime.now() : null,
    );
  }
}

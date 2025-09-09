// Widget de liste des tâches complet
// ==========================================
import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import 'task_item_widget.dart';

/// Widget réutilisable pour afficher une liste de tâches
/// Composant "muet" optimisé avec support du pull-to-refresh
class TaskListWidget extends StatelessWidget {
  final List<Task> tasks;
  final Function(String) onToggleTask;
  final Function(String) onDeleteTask;

  const TaskListWidget({
    super.key,
    required this.tasks,
    required this.onToggleTask,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItemWidget(
          key: Key(task.id), // Clé unique pour optimiser les rebuilds
          task: task,
          onToggle: () => onToggleTask(task.id),
          onDelete: () => onDeleteTask(task.id),
        );
      },
    );
  }
}

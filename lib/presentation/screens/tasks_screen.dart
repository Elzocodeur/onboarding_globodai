// Écran principal complet
// ==========================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../viewmodels/tasks_viewmodel.dart';
import '../widgets/task_list_widget.dart';
import '../widgets/task_stats_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/task_error_widget.dart';
import 'add_task_screen.dart';

/// Écran principal affichant la liste des tâches
/// Widget "muet" qui ne fait qu'afficher les données du ViewModel
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    // Initialisation asynchrone du ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TasksViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Bouton de rechargement des tâches
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshTasks(context),
            tooltip: 'Actualiser les tâches',
          ),
        ],
      ),
      body: Consumer<TasksViewModel>(
        builder: (context, viewModel, child) {
          return _buildBodyContent(context, viewModel);
        },
      ),
      floatingActionButton: Consumer<TasksViewModel>(
        builder: (context, viewModel, child) {
          // Désactiver le FAB pendant le chargement
          return FloatingActionButton(
            onPressed: viewModel.isLoading 
                ? null 
                : () => _navigateToAddTask(context),
            backgroundColor: viewModel.isLoading 
                ? Theme.of(context).disabledColor
                : null,
            child: viewModel.isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.add),
          );
        },
      ),
    );
  }

  /// Construit le contenu principal basé sur l'état du ViewModel
  Widget _buildBodyContent(BuildContext context, TasksViewModel viewModel) {
    switch (viewModel.state) {
      case TasksViewState.initial:
      case TasksViewState.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement des tâches...'),
            ],
          ),
        );
        
      case TasksViewState.error:
        return TaskErrorWidget(
          message: viewModel.errorMessage ?? 'Une erreur est survenue',
          onRetry: () => viewModel.loadTasks(),
        );
        
      case TasksViewState.loaded:
        if (viewModel.hasNoTasks) {
          return const EmptyStateWidget();
        }
        return RefreshIndicator(
          onRefresh: () => viewModel.loadTasks(),
          child: Column(
            children: [
              // Widget des statistiques
              TaskStatsWidget(
                totalTasks: viewModel.tasks.length,
                completedTasks: viewModel.completedTasksCount,
                pendingTasks: viewModel.pendingTasksCount,
              ),
              // Liste des tâches
              Expanded(
                child: TaskListWidget(
                  tasks: viewModel.tasks,
                  onToggleTask: (taskId) => _toggleTask(context, taskId),
                  onDeleteTask: (taskId) => _deleteTask(context, taskId),
                ),
              ),
            ],
          ),
        );
    }
  }

  /// Gère le basculement du statut d'une tâche avec feedback utilisateur
  Future<void> _toggleTask(BuildContext context, String taskId) async {
    try {
      await context.read<TasksViewModel>().toggleTaskCompletion(taskId);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context, 'Erreur lors de la mise à jour de la tâche');
      }
    }
  }

  /// Gère la suppression d'une tâche avec feedback utilisateur
  Future<void> _deleteTask(BuildContext context, String taskId) async {
    try {
      await context.read<TasksViewModel>().deleteTask(taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tâche supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context, 'Erreur lors de la suppression de la tâche');
      }
    }
  }

  /// Actualise les tâches avec feedback utilisateur
  Future<void> _refreshTasks(BuildContext context) async {
    try {
      await context.read<TasksViewModel>().loadTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tâches actualisées'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context, 'Erreur lors de l\'actualisation');
      }
    }
  }

  /// Navigation vers l'écran d'ajout de tâche
  Future<void> _navigateToAddTask(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );

    // Si une tâche a été ajoutée, afficher un feedback
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tâche ajoutée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Affiche une SnackBar d'erreur standardisée
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Réessayer',
          textColor: Colors.white,
          onPressed: () => context.read<TasksViewModel>().loadTasks(),
        ),
      ),
    );
  }
}
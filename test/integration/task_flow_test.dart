// Tests d'intégration pour les flux de tâches
// ==========================================
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:onboarding/domain/repositories/task_repository.dart';
import 'package:onboarding/data/repositories/local_task_repository.dart';
import 'package:onboarding/data/datasources/local_task_datasource.dart';
import 'package:onboarding/presentation/viewmodels/tasks_viewmodel.dart';

void main() {
  group('Tests d\'intégration - Flux de tâches', () {
    late SharedPreferences sharedPreferences;
    late LocalTaskDataSource dataSource;
    late TaskRepository repository;
    late TasksViewModel viewModel;

    setUp(() async {
      // Initialisation des dépendances réelles
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
      dataSource = LocalTaskDataSource(sharedPreferences);
      repository = LocalTaskRepository(dataSource);
      viewModel = TasksViewModel(repository);
    });

    tearDown(() async {
      // Nettoyage après chaque test
      await sharedPreferences.clear();
    });

    group('Flux complet de gestion des tâches', () {
      test('Ajout, modification et suppression d\'une tâche', () async {
        // Act 1: Ajouter une tâche
        await viewModel.addTask('Ma première tâche');

        // Assert 1: Vérifier que la tâche a été ajoutée
        expect(viewModel.tasks, hasLength(1));
        expect(viewModel.tasks.first.title, equals('Ma première tâche'));
        expect(viewModel.tasks.first.isCompleted, isFalse);

        // Act 2: Marquer la tâche comme complétée
        await viewModel.toggleTaskCompletion(viewModel.tasks.first.id);

        // Assert 2: Vérifier que la tâche est marquée comme complétée
        expect(viewModel.tasks.first.isCompleted, isTrue);
        expect(viewModel.completedTasksCount, equals(1));

        // Act 3: Supprimer la tâche
        await viewModel.deleteTask(viewModel.tasks.first.id);

        // Assert 3: Vérifier que la tâche a été supprimée
        expect(viewModel.tasks, isEmpty);
        expect(viewModel.hasNoTasks, isTrue);
      });

      test('Persistance des données entre les sessions', () async {
        // Arrange - Première session
        await viewModel.addTask('Tâche persistante');

        // Act - Deuxième session (nouvelle instance)
        final newViewModel = TasksViewModel(repository);
        await newViewModel.loadTasks();

        // Assert - Vérifier que la tâche est toujours là
        expect(newViewModel.tasks, hasLength(1));
        expect(newViewModel.tasks.first.title, equals('Tâche persistante'));
      });

      test('Gestion des erreurs de validation', () async {
        // Act - Essayer d'ajouter une tâche vide
        await viewModel.addTask('   ');

        // Assert - Vérifier que l'erreur est gérée
        expect(viewModel.state, TasksViewState.error);
        expect(viewModel.errorMessage, equals('Le titre de la tâche ne peut pas être vide'));
        expect(viewModel.tasks, isEmpty);
      });
    });

    group('Tests de performance et de robustesse', () {
      test('Gestion de nombreuses tâches', () async {
        // Act - Ajouter plusieurs tâches rapidement
        for (int i = 0; i < 10; i++) {
          await viewModel.addTask('Tâche $i');
        }

        // Assert - Vérifier que toutes les tâches sont présentes
        expect(viewModel.tasks, hasLength(10));
        for (int i = 0; i < 10; i++) {
          expect(viewModel.tasks.any((task) => task.title == 'Tâche $i'), isTrue);
        }
      });

      test('Actualisation des données', () async {
        // Arrange - Ajouter une tâche
        await viewModel.addTask('Tâche à actualiser');

        // Act - Recharger les tâches
        await viewModel.loadTasks();

        // Assert - Vérifier que la tâche est toujours là
        expect(viewModel.tasks, hasLength(1));
        expect(viewModel.tasks.first.title, equals('Tâche à actualiser'));
      });

      test('Statistiques correctes', () async {
        // Arrange - Ajouter des tâches avec différents statuts
        await viewModel.addTask('Tâche 1');
        await viewModel.addTask('Tâche 2');
        await viewModel.addTask('Tâche 3');

        // Act - Marquer une tâche comme complétée
        await viewModel.toggleTaskCompletion(viewModel.tasks.first.id);

        // Assert - Vérifier les statistiques
        expect(viewModel.tasks.length, equals(3));
        expect(viewModel.completedTasksCount, equals(1));
        expect(viewModel.pendingTasksCount, equals(2));
        expect(viewModel.hasNoTasks, isFalse);
      });
    });
  });
}

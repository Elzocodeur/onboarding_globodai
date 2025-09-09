// Tests unitaires pour TasksViewModel
// ==========================================
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:onboarding/domain/entities/task.dart';
import 'package:onboarding/domain/repositories/task_repository.dart';
import 'package:onboarding/presentation/viewmodels/tasks_viewmodel.dart';
import 'package:onboarding/core/errors/app_exception.dart';

// Génération des mocks
@GenerateMocks([TaskRepository])
import 'tasks_viewmodel_test.mocks.dart';

void main() {
  group('Tests du TasksViewModel', () {
    late MockTaskRepository mockRepository;
    late TasksViewModel viewModel;

    setUp(() {
      mockRepository = MockTaskRepository();
      viewModel = TasksViewModel(mockRepository);
    });

    group('Initialisation', () {
      test('État initial correct', () {
        expect(viewModel.state, TasksViewState.initial);
        expect(viewModel.tasks, isEmpty);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.completedTasksCount, equals(0));
        expect(viewModel.pendingTasksCount, equals(0));
        expect(viewModel.hasNoTasks, isTrue);
      });
    });

    group('Chargement des tâches', () {
      test('Charge les tâches avec succès', () async {
        // Arrange
        final tasks = [
          Task(id: '1', title: 'Tâche 1', createdAt: DateTime.now()),
          Task(id: '2', title: 'Tâche 2', isCompleted: true, createdAt: DateTime.now()),
        ];
        when(mockRepository.getAllTasks()).thenAnswer((_) async => tasks);

        // Act
        await viewModel.loadTasks();

        // Assert
        expect(viewModel.state, TasksViewState.loaded);
        expect(viewModel.tasks, hasLength(2));
        expect(viewModel.completedTasksCount, equals(1));
        expect(viewModel.pendingTasksCount, equals(1));
        expect(viewModel.hasNoTasks, isFalse);
        expect(viewModel.errorMessage, isNull);
        verify(mockRepository.getAllTasks()).called(1);
      });

      test('Gère les erreurs de chargement', () async {
        // Arrange
        when(mockRepository.getAllTasks()).thenThrow(
          AppException(message: 'Erreur de chargement'),
        );

        // Act
        await viewModel.loadTasks();

        // Assert
        expect(viewModel.state, TasksViewState.error);
        expect(viewModel.errorMessage, equals('Erreur de chargement'));
        expect(viewModel.tasks, isEmpty);
      });
    });

    group('Ajout de tâches', () {
      test('Ajoute une tâche avec succès', () async {
        // Arrange
        when(mockRepository.addTask(any)).thenAnswer((_) async {});

        // Act
        await viewModel.addTask('Nouvelle tâche');

        // Assert
        expect(viewModel.tasks, hasLength(1));
        expect(viewModel.tasks.first.title, equals('Nouvelle tâche'));
        expect(viewModel.tasks.first.isCompleted, isFalse);
        expect(viewModel.state, TasksViewState.loaded);
        verify(mockRepository.addTask(any)).called(1);
      });

      test('Rejette les tâches vides', () async {
        // Act
        await viewModel.addTask('   ');

        // Assert
        expect(viewModel.state, TasksViewState.error);
        expect(viewModel.errorMessage, equals('Le titre de la tâche ne peut pas être vide'));
        expect(viewModel.tasks, isEmpty);
        verifyNever(mockRepository.addTask(any));
      });

      test('Gère les erreurs d\'ajout', () async {
        // Arrange
        when(mockRepository.getAllTasks()).thenAnswer((_) async => []);
        when(mockRepository.addTask(any)).thenThrow(
          AppException(message: 'Erreur d\'ajout'),
        );

        // Act
        await viewModel.addTask('Tâche test');

        // Assert
        // Après une erreur, le ViewModel recharge les tâches, donc l'état devient loaded
        expect(viewModel.state, TasksViewState.loaded);
        expect(viewModel.tasks, isEmpty);
        verify(mockRepository.getAllTasks()).called(1); // Une fois pour le reload après erreur
      });
    });

    group('Basculement du statut', () {
      test('Bascule le statut avec succès', () async {
        // Arrange
        final task = Task(id: '1', title: 'Tâche test', createdAt: DateTime.now());
        when(mockRepository.getAllTasks()).thenAnswer((_) async => [task]);
        when(mockRepository.updateTask(any)).thenAnswer((_) async {});
        await viewModel.loadTasks();

        // Act
        await viewModel.toggleTaskCompletion('1');

        // Assert
        expect(viewModel.tasks.first.isCompleted, isTrue);
        expect(viewModel.completedTasksCount, equals(1));
        expect(viewModel.pendingTasksCount, equals(0));
        verify(mockRepository.updateTask(any)).called(1);
      });

      test('Gère les erreurs de basculement', () async {
        // Arrange
        final task = Task(id: '1', title: 'Tâche test', createdAt: DateTime.now());
        when(mockRepository.getAllTasks()).thenAnswer((_) async => [task]);
        when(mockRepository.updateTask(any)).thenThrow(
          AppException(message: 'Erreur de mise à jour'),
        );
        await viewModel.loadTasks();

        // Act
        await viewModel.toggleTaskCompletion('1');

        // Assert
        // Après une erreur, le ViewModel recharge les tâches, donc l'état devient loaded
        expect(viewModel.state, TasksViewState.loaded);
        expect(viewModel.tasks.first.isCompleted, isFalse);
        verify(mockRepository.getAllTasks()).called(2); // Une fois pour le load initial, une fois pour le reload
      });

      test('Gère les tâches inexistantes', () async {
        // Act
        await viewModel.toggleTaskCompletion('inexistant');

        // Assert
        expect(viewModel.state, TasksViewState.error);
        expect(viewModel.errorMessage, equals('Tâche non trouvée'));
      });
    });

    group('Suppression de tâches', () {
      test('Supprime une tâche avec succès', () async {
        // Arrange
        final task = Task(id: '1', title: 'Tâche test', createdAt: DateTime.now());
        when(mockRepository.getAllTasks()).thenAnswer((_) async => [task]);
        when(mockRepository.deleteTask(any)).thenAnswer((_) async {});
        await viewModel.loadTasks();

        // Act
        await viewModel.deleteTask('1');

        // Assert
        expect(viewModel.tasks, isEmpty);
        expect(viewModel.hasNoTasks, isTrue);
        verify(mockRepository.deleteTask('1')).called(1);
      });

      test('Gère les erreurs de suppression', () async {
        // Arrange
        final task = Task(id: '1', title: 'Tâche test', createdAt: DateTime.now());
        when(mockRepository.getAllTasks()).thenAnswer((_) async => [task]);
        when(mockRepository.deleteTask(any)).thenThrow(
          AppException(message: 'Erreur de suppression'),
        );
        await viewModel.loadTasks();

        // Act
        await viewModel.deleteTask('1');

        // Assert
        // Après une erreur, le ViewModel recharge les tâches, donc l'état devient loaded
        expect(viewModel.state, TasksViewState.loaded);
        expect(viewModel.tasks, hasLength(1));
        expect(viewModel.tasks.first.title, equals('Tâche test'));
        verify(mockRepository.getAllTasks()).called(2); // Une fois pour le load initial, une fois pour le reload
      });

      test('Gère les tâches inexistantes', () async {
        // Act
        await viewModel.deleteTask('inexistant');

        // Assert
        expect(viewModel.state, TasksViewState.error);
        expect(viewModel.errorMessage, equals('Tâche non trouvée'));
      });
    });

    group('Propriétés calculées', () {
      test('Calcule correctement les statistiques', () async {
        // Arrange
        final tasks = [
          Task(id: '1', title: 'Tâche 1', createdAt: DateTime.now()),
          Task(id: '2', title: 'Tâche 2', isCompleted: true, createdAt: DateTime.now()),
          Task(id: '3', title: 'Tâche 3', createdAt: DateTime.now()),
        ];
        when(mockRepository.getAllTasks()).thenAnswer((_) async => tasks);

        // Act
        await viewModel.loadTasks();

        // Assert
        expect(viewModel.tasks.length, equals(3));
        expect(viewModel.completedTasksCount, equals(1));
        expect(viewModel.pendingTasksCount, equals(2));
        expect(viewModel.hasNoTasks, isFalse);
      });
    });
  });
}

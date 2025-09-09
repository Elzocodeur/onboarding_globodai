// Tests unitaires pour LocalTaskRepository
// ==========================================
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:onboarding/domain/entities/task.dart';
import 'package:onboarding/data/repositories/local_task_repository.dart';
import 'package:onboarding/data/datasources/local_task_datasource.dart';
import 'package:onboarding/core/errors/app_exception.dart';

// Génération des mocks
@GenerateMocks([LocalTaskDataSource])
import 'local_task_repository_test.mocks.dart';

void main() {
  group('Tests du LocalTaskRepository', () {
    late MockLocalTaskDataSource mockDataSource;
    late LocalTaskRepository repository;

    setUp(() {
      mockDataSource = MockLocalTaskDataSource();
      repository = LocalTaskRepository(mockDataSource);
    });

    group('getAllTasks', () {
      test('Retourne la liste des tâches avec succès', () async {
        // Arrange
        final tasks = [
          Task(id: '1', title: 'Tâche 1', createdAt: DateTime.now()),
          Task(id: '2', title: 'Tâche 2', createdAt: DateTime.now()),
        ];
        when(mockDataSource.getTasks()).thenAnswer((_) async => tasks);

        // Act
        final result = await repository.getAllTasks();

        // Assert
        expect(result, hasLength(2));
        expect(result.first.title, equals('Tâche 1'));
        expect(result.last.title, equals('Tâche 2'));
        verify(mockDataSource.getTasks()).called(1);
      });

      test('Retourne une liste vide quand aucune tâche', () async {
        // Arrange
        when(mockDataSource.getTasks()).thenAnswer((_) async => <Task>[]);

        // Act
        final result = await repository.getAllTasks();

        // Assert
        expect(result, isEmpty);
        verify(mockDataSource.getTasks()).called(1);
      });

      test('Gère les erreurs de lecture', () async {
        // Arrange
        when(mockDataSource.getTasks()).thenThrow(
          StorageException(message: 'Erreur de lecture', operation: 'getTasks'),
        );

        // Act & Assert
        expect(
          () => repository.getAllTasks(),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('addTask', () {
      test('Ajoute une tâche avec succès', () async {
        // Arrange
        final existingTasks = [
          Task(id: '1', title: 'Tâche existante', createdAt: DateTime.now()),
        ];
        final newTask = Task(id: '2', title: 'Nouvelle tâche', createdAt: DateTime.now());
        
        when(mockDataSource.getTasks()).thenAnswer((_) async => existingTasks);
        when(mockDataSource.saveTasks(any)).thenAnswer((_) async {});

        // Act
        await repository.addTask(newTask);

        // Assert
        verify(mockDataSource.getTasks()).called(1);
        verify(mockDataSource.saveTasks(argThat(hasLength(2)))).called(1);
      });

      test('Rejette les tâches avec ID dupliqué', () async {
        // Arrange
        final existingTasks = [
          Task(id: '1', title: 'Tâche existante', createdAt: DateTime.now()),
        ];
        final duplicateTask = Task(id: '1', title: 'Tâche dupliquée', createdAt: DateTime.now());
        
        when(mockDataSource.getTasks()).thenAnswer((_) async => existingTasks);

        // Act & Assert
        expect(
          () => repository.addTask(duplicateTask),
          throwsA(isA<AppException>()),
        );
        verifyNever(mockDataSource.saveTasks(any));
      });

      test('Gère les erreurs de sauvegarde', () async {
        // Arrange
        final newTask = Task(id: '1', title: 'Nouvelle tâche', createdAt: DateTime.now());
        when(mockDataSource.getTasks()).thenAnswer((_) async => <Task>[]);
        when(mockDataSource.saveTasks(any)).thenThrow(
          StorageException(message: 'Erreur de sauvegarde', operation: 'saveTasks'),
        );

        // Act & Assert
        expect(
          () => repository.addTask(newTask),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('updateTask', () {
      test('Met à jour une tâche existante avec succès', () async {
        // Arrange
        final originalTask = Task(id: '1', title: 'Tâche originale', createdAt: DateTime.now());
        final updatedTask = Task(id: '1', title: 'Tâche mise à jour', createdAt: DateTime.now());
        final tasks = [originalTask];
        
        when(mockDataSource.getTasks()).thenAnswer((_) async => tasks);
        when(mockDataSource.saveTasks(any)).thenAnswer((_) async {});

        // Act
        await repository.updateTask(updatedTask);

        // Assert
        verify(mockDataSource.getTasks()).called(1);
        verify(mockDataSource.saveTasks(argThat(hasLength(1)))).called(1);
      });

      test('Lance une exception pour les tâches inexistantes', () async {
        // Arrange
        final nonExistentTask = Task(id: '999', title: 'Tâche inexistante', createdAt: DateTime.now());
        when(mockDataSource.getTasks()).thenAnswer((_) async => <Task>[]);

        // Act & Assert
        expect(
          () => repository.updateTask(nonExistentTask),
          throwsA(isA<AppException>()),
        );
        verifyNever(mockDataSource.saveTasks(any));
      });

      test('Gère les erreurs de sauvegarde', () async {
        // Arrange
        final task = Task(id: '1', title: 'Tâche test', createdAt: DateTime.now());
        when(mockDataSource.getTasks()).thenAnswer((_) async => [task]);
        when(mockDataSource.saveTasks(any)).thenThrow(
          StorageException(message: 'Erreur de sauvegarde', operation: 'saveTasks'),
        );

        // Act & Assert
        expect(
          () => repository.updateTask(task),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('deleteTask', () {
      test('Supprime une tâche avec succès', () async {
        // Arrange
        final tasks = [
          Task(id: '1', title: 'Tâche 1', createdAt: DateTime.now()),
          Task(id: '2', title: 'Tâche 2', createdAt: DateTime.now()),
        ];
        
        when(mockDataSource.getTasks()).thenAnswer((_) async => tasks);
        when(mockDataSource.saveTasks(any)).thenAnswer((_) async {});

        // Act
        await repository.deleteTask('1');

        // Assert
        verify(mockDataSource.getTasks()).called(1);
        verify(mockDataSource.saveTasks(argThat(hasLength(1)))).called(1);
      });

      test('Lance une exception pour les tâches inexistantes', () async {
        // Arrange
        when(mockDataSource.getTasks()).thenAnswer((_) async => <Task>[]);

        // Act & Assert
        expect(
          () => repository.deleteTask('999'),
          throwsA(isA<AppException>()),
        );
        verifyNever(mockDataSource.saveTasks(any));
      });

      test('Gère les erreurs de sauvegarde', () async {
        // Arrange
        final tasks = [Task(id: '1', title: 'Tâche test', createdAt: DateTime.now())];
        when(mockDataSource.getTasks()).thenAnswer((_) async => tasks);
        when(mockDataSource.saveTasks(any)).thenThrow(
          StorageException(message: 'Erreur de sauvegarde', operation: 'saveTasks'),
        );

        // Act & Assert
        expect(
          () => repository.deleteTask('1'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('taskExists', () {
      test('Retourne true pour une tâche existante', () async {
        // Arrange
        final tasks = [
          Task(id: '1', title: 'Tâche 1', createdAt: DateTime.now()),
          Task(id: '2', title: 'Tâche 2', createdAt: DateTime.now()),
        ];
        when(mockDataSource.getTasks()).thenAnswer((_) async => tasks);

        // Act
        final result = await repository.taskExists('1');

        // Assert
        expect(result, isTrue);
        verify(mockDataSource.getTasks()).called(1);
      });

      test('Retourne false pour une tâche inexistante', () async {
        // Arrange
        final tasks = [Task(id: '1', title: 'Tâche 1', createdAt: DateTime.now())];
        when(mockDataSource.getTasks()).thenAnswer((_) async => tasks);

        // Act
        final result = await repository.taskExists('999');

        // Assert
        expect(result, isFalse);
        verify(mockDataSource.getTasks()).called(1);
      });

      test('Retourne false en cas d\'erreur', () async {
        // Arrange
        when(mockDataSource.getTasks()).thenThrow(
          StorageException(message: 'Erreur de lecture', operation: 'getTasks'),
        );

        // Act
        final result = await repository.taskExists('1');

        // Assert
        expect(result, isFalse);
      });
    });
  });
}

// Tests unitaires pour les extensions Task
// ==========================================
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding/domain/entities/task.dart';

void main() {
  group('Tests des extensions Task', () {
    group('isRecent', () {
      test('Retourne true pour une tâche créée récemment', () {
        // Arrange
        final recentTask = Task(
          id: '1',
          title: 'Tâche récente',
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        );

        // Act
        final result = recentTask.isRecent;

        // Assert
        expect(result, isTrue);
      });

      test('Retourne false pour une tâche ancienne', () {
        // Arrange
        final oldTask = Task(
          id: '1',
          title: 'Tâche ancienne',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );

        // Act
        final result = oldTask.isRecent;

        // Assert
        expect(result, isFalse);
      });

      test('Retourne true pour une tâche créée exactement il y a 24h', () {
        // Arrange
        final task = Task(
          id: '1',
          title: 'Tâche limite',
          createdAt: DateTime.now().subtract(const Duration(hours: 24)),
        );

        // Act
        final result = task.isRecent;

        // Assert
        expect(result, isFalse); // 24h exactement n'est pas considéré comme récent
      });
    });

    group('toggleCompletion', () {
      test('Marque une tâche non complétée comme complétée', () {
        // Arrange
        final incompleteTask = Task(
          id: '1',
          title: 'Tâche incomplète',
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        // Act
        final result = incompleteTask.toggleCompletion();

        // Assert
        expect(result.isCompleted, isTrue);
        expect(result.completedAt, isNotNull);
        expect(result.id, equals('1'));
        expect(result.title, equals('Tâche incomplète'));
        expect(result.createdAt, equals(incompleteTask.createdAt));
      });

      test('Marque une tâche complétée comme non complétée', () {
        // Arrange
        final completedTask = Task(
          id: '1',
          title: 'Tâche complétée',
          isCompleted: true,
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
        );

        // Act
        final result = completedTask.toggleCompletion();

        // Assert
        expect(result.isCompleted, isFalse);
        expect(result.completedAt, isNull);
        expect(result.id, equals('1'));
        expect(result.title, equals('Tâche complétée'));
        expect(result.createdAt, equals(completedTask.createdAt));
      });

      test('Préserve l\'immutabilité de la tâche originale', () {
        // Arrange
        final originalTask = Task(
          id: '1',
          title: 'Tâche originale',
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        // Act
        final toggledTask = originalTask.toggleCompletion();

        // Assert
        expect(originalTask.isCompleted, isFalse);
        expect(originalTask.completedAt, isNull);
        expect(toggledTask.isCompleted, isTrue);
        expect(toggledTask.completedAt, isNotNull);
      });

      test('Définit completedAt lors de la complétion', () {
        // Arrange
        final now = DateTime.now();
        final task = Task(
          id: '1',
          title: 'Tâche test',
          isCompleted: false,
          createdAt: now,
        );

        // Act
        final result = task.toggleCompletion();

        // Assert
        expect(result.completedAt, isNotNull);
        expect(result.completedAt!.isAfter(now.subtract(const Duration(seconds: 1))), isTrue);
        expect(result.completedAt!.isBefore(now.add(const Duration(seconds: 1))), isTrue);
      });
    });

    group('Sérialisation JSON', () {
      test('Sérialise correctement une tâche en JSON', () {
        // Arrange
        final task = Task(
          id: 'test-id',
          title: 'Tâche de test',
          isCompleted: true,
          createdAt: DateTime(2024, 1, 1, 12, 0),
          completedAt: DateTime(2024, 1, 1, 14, 0),
        );

        // Act
        final json = task.toJson();

        // Assert
        expect(json['id'], equals('test-id'));
        expect(json['title'], equals('Tâche de test'));
        expect(json['isCompleted'], isTrue);
        expect(json['createdAt'], isNotNull);
        expect(json['completedAt'], isNotNull);
      });

      test('Désérialise correctement une tâche depuis JSON', () {
        // Arrange
        final json = {
          'id': 'test-id',
          'title': 'Tâche de test',
          'isCompleted': true,
          'createdAt': '2024-01-01T12:00:00.000Z',
          'completedAt': '2024-01-01T14:00:00.000Z',
        };

        // Act
        final task = Task.fromJson(json);

        // Assert
        expect(task.id, equals('test-id'));
        expect(task.title, equals('Tâche de test'));
        expect(task.isCompleted, isTrue);
        expect(task.createdAt, isNotNull);
        expect(task.completedAt, isNotNull);
      });

      test('Gère les tâches sans completedAt', () {
        // Arrange
        final json = {
          'id': 'test-id',
          'title': 'Tâche incomplète',
          'isCompleted': false,
          'createdAt': '2024-01-01T12:00:00.000Z',
        };

        // Act
        final task = Task.fromJson(json);

        // Assert
        expect(task.id, equals('test-id'));
        expect(task.title, equals('Tâche incomplète'));
        expect(task.isCompleted, isFalse);
        expect(task.completedAt, isNull);
      });
    });
  });
}

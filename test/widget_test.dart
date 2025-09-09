// Tests unitaires pour l'application de gestion de tâches
// ==========================================
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:onboarding/presentation/app.dart';
import 'package:onboarding/domain/entities/task.dart';
import 'package:onboarding/domain/repositories/task_repository.dart';
import 'package:onboarding/presentation/viewmodels/tasks_viewmodel.dart';
import 'package:onboarding/presentation/screens/tasks_screen.dart';
import 'package:onboarding/presentation/widgets/empty_state_widget.dart';

// Génération des mocks
@GenerateMocks([TaskRepository])
import 'widget_test.mocks.dart';

void main() {
  group('Tests de l\'application principale', () {
    testWidgets('L\'application se lance correctement', (WidgetTester tester) async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final mockRepository = MockTaskRepository();
      final viewModel = TasksViewModel(mockRepository);
      
      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<TasksViewModel>(
          create: (_) => viewModel,
          child: const MaterialApp(
            home: TasksScreen(),
            title: 'Gestionnaire de Tâches',
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Gestionnaire de Tâches'), findsOneWidget);
      expect(find.byType(TasksScreen), findsOneWidget);
    });
  });

  group('Tests du TasksScreen', () {
    late MockTaskRepository mockRepository;
    late TasksViewModel viewModel;

    setUp(() {
      mockRepository = MockTaskRepository();
      viewModel = TasksViewModel(mockRepository);
    });

    testWidgets('Affiche l\'état de chargement initial', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllTasks()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<TasksViewModel>(
          create: (_) => viewModel,
          child: const MaterialApp(home: TasksScreen()),
        ),
      );

      // Assert
      expect(find.text('Chargement des tâches...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Affiche l\'état vide quand aucune tâche', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllTasks()).thenAnswer((_) async => []);
      await viewModel.initialize();

      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<TasksViewModel>(
          create: (_) => viewModel,
          child: const MaterialApp(home: TasksScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });

    testWidgets('Affiche la liste des tâches', (WidgetTester tester) async {
      // Arrange
      final tasks = [
        Task(id: '1', title: 'Tâche 1', createdAt: DateTime.now()),
        Task(id: '2', title: 'Tâche 2', createdAt: DateTime.now()),
      ];
      when(mockRepository.getAllTasks()).thenAnswer((_) async => tasks);
      await viewModel.initialize();

      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<TasksViewModel>(
          create: (_) => viewModel,
          child: const MaterialApp(home: TasksScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Tâche 1'), findsOneWidget);
      expect(find.text('Tâche 2'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
    });
  });
}

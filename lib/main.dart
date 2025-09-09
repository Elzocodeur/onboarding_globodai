import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/dependency_injection/service_locator.dart';
import 'presentation/app.dart';

/// Point d'entrée principal de l'application
/// Initialise les dépendances et lance l'application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation du ServiceLocator pour l'injection de dépendances
  await ServiceLocator.initialize();

  runApp(const TodoApp());
}

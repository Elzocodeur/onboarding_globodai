import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/dependency_injection/service_locator.dart';
import 'screens/tasks_screen.dart';

/// Widget principal de l'application
/// Configure les providers, le thème et la navigation
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Injection du ViewModel principal
        ChangeNotifierProvider.value(
          value: ServiceLocator.tasksViewModel,
        ),
      ],
      child: MaterialApp(
        title: 'Gestionnaire de Tâches Pro',
        debugShowCheckedModeBanner: false,
        
        // Configuration du thème principal
        theme: _buildLightTheme(),
        
        // Configuration du thème sombre (optionnel)
        darkTheme: _buildDarkTheme(),
        
        // Mode de thème automatique
        themeMode: ThemeMode.system,
        
        // Écran d'accueil
        home: const TasksScreen(),
        
        // Configuration des routes nommées pour une meilleure navigation
        routes: {
          '/tasks': (context) => const TasksScreen(),
        },
        
        // Gestionnaire de routes inconnues
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const TasksScreen(),
          );
        },
      ),
    );
  }

  /// Construit le thème clair de l'application
  ThemeData _buildLightTheme() {
    const primaryColor = Colors.blue;
    
    return ThemeData(
      useMaterial3: true,
      
      // Schéma de couleurs
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      
      // Configuration de l'AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 2,
        scrolledUnderElevation: 4,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Configuration des Cards
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      ),
      
      // Configuration des boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
      
      // Configuration des FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // Configuration des champs de texte
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      
      // Configuration des ListTiles
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      
      // Configuration des Dialogs
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
      
      // Configuration des SnackBars
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Construit le thème sombre de l'application
  ThemeData _buildDarkTheme() {
    const primaryColor = Colors.blue;
    
    return ThemeData(
      useMaterial3: true,
      
      // Schéma de couleurs sombres
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      
      // Réutiliser les configurations du thème clair
      appBarTheme: _buildLightTheme().appBarTheme,
      cardTheme: _buildLightTheme().cardTheme,
      elevatedButtonTheme: _buildLightTheme().elevatedButtonTheme,
      floatingActionButtonTheme: _buildLightTheme().floatingActionButtonTheme,
      inputDecorationTheme: _buildLightTheme().inputDecorationTheme,
      listTileTheme: _buildLightTheme().listTileTheme,
      dialogTheme: _buildLightTheme().dialogTheme,
      snackBarTheme: _buildLightTheme().snackBarTheme,
    );
  }
}
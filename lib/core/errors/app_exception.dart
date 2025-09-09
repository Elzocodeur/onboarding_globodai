// Gestion personnalisée des exceptions
// ==========================================
/// Exception personnalisée pour l'application
/// Permet une gestion centralisée et typée des erreurs avec contexte détaillé
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('AppException: $message');
    if (code != null) {
      buffer.write(' (Code: $code)');
    }
    if (originalError != null) {
      buffer.write(' - Original: $originalError');
    }
    return buffer.toString();
  }

  /// Crée une AppException à partir d'une autre exception
  factory AppException.from(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }
    
    return AppException(
      message: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Exception spécifique pour les erreurs de validation
class ValidationException extends AppException {
  final String field;

  const ValidationException({
    required String message,
    required this.field,
    String? code,
  }) : super(message: message, code: code);

  @override
  String toString() => 'ValidationException ($field): $message';
}

/// Exception pour les tâches non trouvées
class TaskNotFoundException extends AppException {
  final String taskId;

  const TaskNotFoundException(this.taskId) 
      : super(
          message: 'Tâche non trouvée',
          code: 'TASK_NOT_FOUND',
        );

  @override
  String toString() => 'TaskNotFoundException: Tâche $taskId non trouvée';
}

/// Exception pour les erreurs de stockage
class StorageException extends AppException {
  final String operation;

  const StorageException({
    required String message,
    required this.operation,
    dynamic originalError,
  }) : super(
          message: message,
          code: 'STORAGE_ERROR',
          originalError: originalError,
        );

  @override
  String toString() => 'StorageException ($operation): $message';
}

/// Exception pour les erreurs réseau (future usage)
class NetworkException extends AppException {
  final int? statusCode;
  final String? endpoint;

  const NetworkException({
    required String message,
    this.statusCode,
    this.endpoint,
    dynamic originalError,
  }) : super(
          message: message,
          code: 'NETWORK_ERROR',
          originalError: originalError,
        );

  @override
  String toString() {
    final buffer = StringBuffer('NetworkException');
    if (statusCode != null) {
      buffer.write(' ($statusCode)');
    }
    if (endpoint != null) {
      buffer.write(' [$endpoint]');
    }
    buffer.write(': $message');
    return buffer.toString();
  }
}

/// Gestionnaire centralisé des erreurs
class ErrorHandler {
  /// Traite une exception et retourne un message utilisateur approprié
  static String getDisplayMessage(dynamic error) {
    if (error is ValidationException) {
      return error.message;
    }
    
    if (error is TaskNotFoundException) {
      return 'Cette tâche n\'existe plus';
    }
    
    if (error is StorageException) {
      return 'Erreur de sauvegarde des données';
    }
    
    if (error is NetworkException) {
      return 'Problème de connexion réseau';
    }
    
    if (error is AppException) {
      return error.message;
    }
    
    // Erreur générique
    return 'Une erreur inattendue s\'est produite';
  }

  /// Log une erreur pour le développement
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    // En production, on pourrait envoyer vers un service de logging
    print('ERROR: $error');
    if (stackTrace != null) {
      print('STACK: $stackTrace');
    }
  }

  /// Traite une exception de manière complète
  static AppException handleError(dynamic error, [StackTrace? stackTrace]) {
    logError(error, stackTrace);
    
    if (error is AppException) {
      return error;
    }
    
    return AppException.from(error, stackTrace);
  }
}
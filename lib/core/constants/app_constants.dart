// Constantes globales de l'application
// ==========================================
/// Classe contenant toutes les constantes utilisées dans l'application
/// Centralise les textes, clés et valeurs pour faciliter la maintenance
class AppConstants {
  // Empêcher l'instanciation de cette classe utilitaire
  AppConstants._();

  // === STOCKAGE LOCAL ===
  static const String tasksStorageKey = 'tasks_list_v1';
  
  // === MESSAGES D'ERREUR ===
  static const String errorLoadingTasks = 'Erreur lors du chargement des tâches';
  static const String errorSavingTask = 'Erreur lors de la sauvegarde';
  static const String errorDeletingTask = 'Erreur lors de la suppression';
  static const String errorUpdatingTask = 'Erreur lors de la mise à jour';
  static const String errorGeneral = 'Une erreur inattendue s\'est produite';
  
  // === MESSAGES DE VALIDATION ===
  static const String emptyTaskError = 'Le titre de la tâche ne peut pas être vide';
  static const String taskTooShortError = 'Le titre doit contenir au moins 3 caractères';
  static const String taskTooLongError = 'Le titre ne peut pas dépasser 100 caractères';
  
  // === TEXTES DE L'INTERFACE UTILISATEUR ===
  static const String appTitle = 'Gestionnaire de Tâches';
  static const String addTaskTitle = 'Nouvelle Tâche';
  static const String editTaskTitle = 'Modifier la Tâche';
  static const String taskTitleHint = 'Titre de la tâche';
  static const String noTasksMessage = 'Aucune tâche à afficher';
  
  // === MESSAGES DE CONFIRMATION ===
  static const String deleteConfirmTitle = 'Confirmer la suppression';
  static const String deleteConfirmMessage = 'Êtes-vous sûr de vouloir supprimer cette tâche ?';
  static const String unsavedChangesTitle = 'Modifications non sauvegardées';
  static const String unsavedChangesMessage = 'Voulez-vous vraiment quitter sans sauvegarder ?';
  
  // === ACTIONS ===
  static const String addAction = 'Ajouter';
  static const String saveAction = 'Sauvegarder';
  static const String cancelAction = 'Annuler';
  static const String deleteAction = 'Supprimer';
  static const String editAction = 'Modifier';
  static const String retryAction = 'Réessayer';
  static const String okAction = 'OK';
  
  // === MESSAGES DE SUCCÈS ===
  static const String taskAddedSuccess = 'Tâche ajoutée avec succès';
  static const String taskUpdatedSuccess = 'Tâche mise à jour avec succès';
  static const String taskDeletedSuccess = 'Tâche supprimée avec succès';
  static const String tasksRefreshedSuccess = 'Tâches actualisées';
  
  // === STATISTIQUES ===
  static const String statsTitle = 'Statistiques';
  static const String totalTasksLabel = 'Total';
  static const String completedTasksLabel = 'Terminées';
  static const String pendingTasksLabel = 'En attente';
  static const String progressLabel = 'Progression';
  
  // === CONSEILS ET INSTRUCTIONS ===
  static const String emptyStateInstruction = 'Appuyez sur le bouton + pour créer votre première tâche';
  static const String swipeToDeleteHint = 'Glissez pour supprimer une tâche';
  static const String tapToToggleHint = 'Appuyez pour marquer comme terminée';
  
  // === LIMITES ET CONTRAINTES ===
  static const int maxTaskTitleLength = 100;
  static const int minTaskTitleLength = 3;
  static const int recentTaskHours = 24;
  
  // === DURÉES D'ANIMATION ===
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 600);
  static const Duration longAnimationDuration = Duration(milliseconds: 1000);
  
  // === FORMATS DE DATE ===
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy à HH:mm';
}

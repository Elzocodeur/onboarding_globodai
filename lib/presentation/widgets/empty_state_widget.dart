// Widget d'état vide complet
// ==========================================
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../screens/add_task_screen.dart';

/// Widget d'affichage pour l'état vide (aucune tâche)
/// Encourage l'utilisateur à créer sa première tâche avec une interface attrayante
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration d'état vide
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt,
                size: 80,
                color: Colors.blue[400],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Titre principal
            Text(
              AppConstants.noTasksMessage,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Description encourageante
            Text(
              'Commencez par créer votre première tâche\npour mieux organiser votre journée',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Bouton d'action principal
            ElevatedButton.icon(
              onPressed: () => _navigateToAddTask(context),
              icon: const Icon(Icons.add),
              label: const Text('Créer ma première tâche'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Conseils d'utilisation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Conseils d\'utilisation',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Appuyez sur + pour ajouter une tâche\n'
                    '• Cochez pour marquer comme terminée\n'
                    '• Glissez pour supprimer une tâche',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue[600],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigation vers l'écran d'ajout de tâche
  Future<void> _navigateToAddTask(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );
  }
}
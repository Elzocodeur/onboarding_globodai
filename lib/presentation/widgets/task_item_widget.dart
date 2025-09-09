// Widget d'item de tâche complet
// ==========================================
import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

/// Widget pour afficher une tâche individuelle
/// Gère l'affichage et les interactions avec animations fluides
class TaskItemWidget extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskItemWidget({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<TaskItemWidget> createState() => _TaskItemWidgetState();
}

class _TaskItemWidgetState extends State<TaskItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            margin: EdgeInsets.zero,
            elevation: widget.task.isCompleted ? 1 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: widget.task.isCompleted 
                    ? Colors.green.withOpacity(0.3)
                    : Colors.transparent,
                width: widget.task.isCompleted ? 1 : 0,
              ),
            ),
            child: Dismissible(
              key: Key(widget.task.id),
              direction: DismissDirection.endToStart,
              background: _buildDeleteBackground(),
              confirmDismiss: (direction) => _showDeleteConfirmation(context),
              onDismissed: (direction) => widget.onDelete(),
              child: _buildTaskContent(context),
            ),
          ),
        );
      },
    );
  }

  /// Construit le contenu principal de la tâche
  Widget _buildTaskContent(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: _buildCheckbox(context),
        title: _buildTaskTitle(context),
        subtitle: _buildTaskSubtitle(context),
        trailing: _buildActionButtons(context),
        onTap: widget.onToggle,
      ),
    );
  }

  /// Construit la checkbox avec animation
  Widget _buildCheckbox(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.task.isCompleted 
            ? Colors.green.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: Checkbox(
        value: widget.task.isCompleted,
        onChanged: (_) => widget.onToggle(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        activeColor: Colors.green,
      ),
    );
  }

  /// Construit le titre de la tâche avec style conditionnel
  Widget _buildTaskTitle(BuildContext context) {
    return Text(
      widget.task.title,
      style: TextStyle(
        decoration: widget.task.isCompleted 
            ? TextDecoration.lineThrough 
            : null,
        decorationColor: Colors.grey,
        color: widget.task.isCompleted 
            ? Theme.of(context).disabledColor 
            : Theme.of(context).textTheme.bodyLarge?.color,
        fontWeight: widget.task.isCompleted 
            ? FontWeight.normal 
            : FontWeight.w500,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Construit les informations secondaires de la tâche
  Widget _buildTaskSubtitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          'Créée le ${_formatDate(widget.task.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        if (widget.task.isCompleted && widget.task.completedAt != null) ...[
          const SizedBox(height: 2),
          Text(
            'Complétée le ${_formatDate(widget.task.completedAt!)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (widget.task.isRecent) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Récente',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Construit les boutons d'action
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton de suppression
        IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Colors.red[400],
            size: 20,
          ),
          onPressed: () => _showDeleteConfirmation(context),
          tooltip: 'Supprimer la tâche',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  /// Construit l'arrière-plan de suppression pour le swipe
  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(height: 4),
          Text(
            'Supprimer',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Formate une date pour l'affichage français
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    // Si c'est aujourd'hui
    if (difference.inDays == 0) {
      return 'aujourd\'hui à ${_formatTime(date)}';
    }
    // Si c'est hier
    else if (difference.inDays == 1) {
      return 'hier à ${_formatTime(date)}';
    }
    // Si c'est cette semaine
    else if (difference.inDays < 7) {
      return '${_getWeekdayName(date.weekday)} à ${_formatTime(date)}';
    }
    // Sinon format complet
    else {
      return '${date.day.toString().padLeft(2, '0')}/'
             '${date.month.toString().padLeft(2, '0')}/'
             '${date.year} à ${_formatTime(date)}';
    }
  }

  /// Formate l'heure
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }

  /// Retourne le nom du jour de la semaine en français
  String _getWeekdayName(int weekday) {
    const weekdays = [
      'lundi', 'mardi', 'mercredi', 'jeudi', 
      'vendredi', 'samedi', 'dimanche'
    ];
    return weekdays[weekday - 1];
  }

  /// Affiche une confirmation avant suppression
  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer la tâche "${widget.task.title}" ?',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Annuler',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    ) ?? false;
  }
}
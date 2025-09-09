import 'package:flutter/material.dart';

/// Widget d'affichage des statistiques des tâches
/// Composant réutilisable avec animations et design moderne
class TaskStatsWidget extends StatefulWidget {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;

  const TaskStatsWidget({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
  });

  @override
  State<TaskStatsWidget> createState() => _TaskStatsWidgetState();
}

class _TaskStatsWidgetState extends State<TaskStatsWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late List<AnimationController> _numberControllers;
  late List<Animation<int>> _numberAnimations;

  @override
  void initState() {
    super.initState();
    
    // Animation pour la barre de progression
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );

    // Animations pour les chiffres
    _initializeNumberAnimations();
    
    // Démarrer les animations
    _startAnimations();
  }

  void _initializeNumberAnimations() {
    _numberControllers = List.generate(3, (index) => 
      AnimationController(
        duration: Duration(milliseconds: 800 + (index * 200)),
        vsync: this,
      ),
    );

    _numberAnimations = [
      IntTween(begin: 0, end: widget.totalTasks).animate(
        CurvedAnimation(parent: _numberControllers[0], curve: Curves.easeOut),
      ),
      IntTween(begin: 0, end: widget.completedTasks).animate(
        CurvedAnimation(parent: _numberControllers[1], curve: Curves.easeOut),
      ),
      IntTween(begin: 0, end: widget.pendingTasks).animate(
        CurvedAnimation(parent: _numberControllers[2], curve: Curves.easeOut),
      ),
    ];
  }

  void _startAnimations() {
    _progressController.forward();
    for (var controller in _numberControllers) {
      controller.forward();
    }
  }

  @override
  void didUpdateWidget(TaskStatsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Redémarrer les animations si les données ont changé
    if (widget.totalTasks != oldWidget.totalTasks ||
        widget.completedTasks != oldWidget.completedTasks ||
        widget.pendingTasks != oldWidget.pendingTasks) {
      
      _resetAnimations();
      _initializeNumberAnimations();
      _startAnimations();
    }
  }

  void _resetAnimations() {
    _progressController.reset();
    for (var controller in _numberControllers) {
      controller.reset();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    for (var controller in _numberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completionRate = widget.totalTasks > 0 
        ? (widget.completedTasks / widget.totalTasks * 100).round() 
        : 0;

    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 6,
        shadowColor: Colors.blue.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.withOpacity(0.05),
                Colors.purple.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec titre et icône
              _buildHeader(context),
              
              const SizedBox(height: 24),
              
              // Statistiques numériques avec animations
              _buildStatistics(context),
              
              const SizedBox(height: 24),
              
              // Barre de progression animée
              _buildProgressSection(context, completionRate),
              
              if (widget.totalTasks > 0) ...[
                const SizedBox(height: 16),
                _buildInsights(context, completionRate),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Construit l'en-tête du widget
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.analytics_outlined,
            color: Colors.blue[600],
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistiques',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              Text(
                'Vue d\'ensemble de vos tâches',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construit les statistiques numériques
  Widget _buildStatistics(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          icon: Icons.list_alt,
          label: 'Total',
          valueAnimation: _numberAnimations[0],
          color: Colors.blue,
        ),
        Container(
          width: 1,
          height: 40,
          color: Colors.grey[300],
        ),
        _StatItem(
          icon: Icons.check_circle,
          label: 'Terminées',
          valueAnimation: _numberAnimations[1],
          color: Colors.green,
        ),
        Container(
          width: 1,
          height: 40,
          color: Colors.grey[300],
        ),
        _StatItem(
          icon: Icons.pending,
          label: 'En attente',
          valueAnimation: _numberAnimations[2],
          color: Colors.orange,
        ),
      ],
    );
  }

  /// Construit la section de progression
  Widget _buildProgressSection(BuildContext context, int completionRate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progression',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                final animatedRate = (_progressAnimation.value * completionRate).round();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getProgressColor(completionRate).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$animatedRate%',
                    style: TextStyle(
                      color: _getProgressColor(completionRate),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Barre de progression personnalisée
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: widget.totalTasks > 0 
                    ? _progressAnimation.value * (widget.completedTasks / widget.totalTasks)
                    : 0,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(completionRate),
                ),
                borderRadius: BorderRadius.circular(4),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Construit les insights basés sur les statistiques
  Widget _buildInsights(BuildContext context, int completionRate) {
    String insightText;
    IconData insightIcon;
    Color insightColor;

    if (completionRate == 100) {
      insightText = 'Félicitations ! Toutes vos tâches sont terminées !';
      insightIcon = Icons.celebration;
      insightColor = Colors.green;
    } else if (completionRate >= 75) {
      insightText = 'Excellent travail ! Vous êtes sur la bonne voie.';
      insightIcon = Icons.trending_up;
      insightColor = Colors.green;
    } else if (completionRate >= 50) {
      insightText = 'Bon progrès ! Continuez comme ça.';
      insightIcon = Icons.schedule;
      insightColor = Colors.orange;
    } else if (completionRate >= 25) {
      insightText = 'Bon début ! Il reste encore du travail à faire.';
      insightIcon = Icons.play_arrow;
      insightColor = Colors.blue;
    } else {
      insightText = 'Commencez par terminer quelques tâches !';
      insightIcon = Icons.flag;
      insightColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: insightColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: insightColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            insightIcon,
            color: insightColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              insightText,
              style: TextStyle(
                color: insightColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Retourne la couleur appropriée pour la progression
  Color _getProgressColor(int completionRate) {
    if (completionRate >= 75) return Colors.green;
    if (completionRate >= 50) return Colors.orange;
    if (completionRate >= 25) return Colors.blue;
    return Colors.grey;
  }
}

/// Widget privé pour afficher une statistique individuelle avec animation
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Animation<int> valueAnimation;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.valueAnimation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // Icône avec conteneur coloré
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              icon, 
              color: color,
              size: 24,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Valeur animée
          AnimatedBuilder(
            animation: valueAnimation,
            builder: (context, child) {
              return Text(
                valueAnimation.value.toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              );
            },
          ),
          
          const SizedBox(height: 4),
          
          // Label
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
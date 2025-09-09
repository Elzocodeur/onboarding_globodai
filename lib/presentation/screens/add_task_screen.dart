// Écran d'ajout de nouvelles tâches
// ==========================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../viewmodels/tasks_viewmodel.dart';

/// Écran pour ajouter une nouvelle tâche
/// Respecte le principe de séparation : uniquement de l'affichage et validation simple
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _titleFocusNode = FocusNode();
  
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configuration des animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Démarrer l'animation et focus automatique
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          AppConstants.addTaskTitle,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => _handleBackPress(),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: _buildBody(context),
            ),
          );
        },
      ),
    );
  }

  /// Construit le contenu principal de l'écran
  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions utilisateur
            _buildInstructions(context),
            
            const SizedBox(height: 24),
            
            // Champ de saisie principal
            _buildTaskTitleField(),
            
            const SizedBox(height: 16),
            
            // Conseils de saisie
            _buildInputTips(context),
            
            const SizedBox(height: 32),
            
            // Boutons d'action
            _buildActionButtons(context),
            
            const SizedBox(height: 24),
            
            // Exemples de tâches
            _buildTaskExamples(context),
          ],
        ),
      ),
    );
  }

  /// Construit les instructions pour l'utilisateur
  Widget _buildInstructions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.blue[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Décrivez votre tâche de manière claire et concise.',
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit le champ de saisie du titre
  Widget _buildTaskTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _titleController,
        focusNode: _titleFocusNode,
        decoration: InputDecoration(
          labelText: AppConstants.taskTitleHint,
          hintText: 'Ex: Terminer le rapport mensuel',
          prefixIcon: Icon(
            Icons.task_alt,
            color: Colors.blue[600],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return AppConstants.emptyTaskError;
          }
          if (value.trim().length < 3) {
            return 'Le titre doit contenir au moins 3 caractères';
          }
          if (value.trim().length > 100) {
            return 'Le titre ne peut pas dépasser 100 caractères';
          }
          return null;
        },
        maxLength: 100,
        maxLines: 2,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _handleAddTask(),
      ),
    );
  }

  /// Construit les conseils de saisie
  Widget _buildInputTips(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conseils pour une bonne tâche :',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          ...const [
            '• Utilisez un verbe d\'action (terminer, appeler, rédiger...)',
            '• Soyez spécifique et mesurable',
            '• Évitez les termes vagues comme "faire quelque chose"',
          ].map((tip) => Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
          )),
        ],
      ),
    );
  }

  /// Construit les boutons d'action
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Bouton principal d'ajout
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleAddTask,
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.add_task),
            label: Text(
              _isLoading ? 'Ajout en cours...' : 'Ajouter la tâche',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Bouton secondaire d'annulation
        TextButton(
          onPressed: _isLoading ? null : _handleBackPress,
          child: Text(
            'Annuler',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Construit les exemples de tâches
  Widget _buildTaskExamples(BuildContext context) {
    const examples = [
      'Préparer la présentation client',
      'Faire les courses pour ce soir',
      'Appeler le médecin pour RDV',
      'Réviser le chapitre 3 de math',
      'Organiser le bureau',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exemples de tâches :',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: examples.map((example) => 
            _buildExampleChip(example),
          ).toList(),
        ),
      ],
    );
  }

  /// Construit un chip d'exemple cliquable
  Widget _buildExampleChip(String example) {
    return GestureDetector(
      onTap: () => _fillExample(example),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app,
              size: 14,
              color: Colors.blue[600],
            ),
            const SizedBox(width: 4),
            Text(
              example,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Remplit le champ avec l'exemple sélectionné
  void _fillExample(String example) {
    _titleController.text = example;
    _titleFocusNode.requestFocus();
    // Positionner le curseur à la fin
    _titleController.selection = TextSelection.fromPosition(
      TextPosition(offset: _titleController.text.length),
    );
  }

  /// Gère l'ajout d'une nouvelle tâche
  Future<void> _handleAddTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final title = _titleController.text.trim();
      await context.read<TasksViewModel>().addTask(title);
      
      if (mounted) {
        Navigator.of(context).pop(true); // Retourner true pour indiquer le succès
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erreur lors de l\'ajout de la tâche: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Gère le retour en arrière avec confirmation si nécessaire
  Future<void> _handleBackPress() async {
    if (_titleController.text.trim().isNotEmpty) {
      final shouldLeave = await _showUnsavedChangesDialog();
      if (shouldLeave == true && mounted) {
        Navigator.of(context).pop(false);
      }
    } else {
      Navigator.of(context).pop(false);
    }
  }

  /// Affiche une dialog d'erreur
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Affiche une confirmation pour les modifications non sauvegardées
  Future<bool?> _showUnsavedChangesDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifications non sauvegardées'),
        content: const Text(
          'Vous avez commencé à saisir une tâche. '
          'Voulez-vous vraiment quitter sans sauvegarder ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Rester'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }
}
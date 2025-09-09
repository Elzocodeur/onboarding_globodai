# 📱 Gestionnaire de Tâches Pro - Application Flutter

## 📋 Description du Projet

**Gestionnaire de Tâches Pro** est une application mobile Flutter moderne et professionnelle permettant la gestion efficace de tâches personnelles. L'application implémente une architecture MVVM robuste avec les meilleures pratiques de développement Flutter.

### 🎯 Fonctionnalités Principales

- ✅ **Affichage des tâches** : Liste complète avec statut (complétée/non complétée)
- ➕ **Ajout de tâches** : Interface intuitive pour créer de nouvelles tâches
- 🔄 **Modification du statut** : Basculement facile entre complétée/non complétée
- 🗑️ **Suppression de tâches** : Suppression avec confirmation
- 💾 **Persistance locale** : Sauvegarde automatique avec SharedPreferences
- 📊 **Statistiques** : Vue d'ensemble des tâches (total, terminées, en attente)
- 🎨 **Thème adaptatif** : Support du mode sombre/clair automatique
- 🔄 **Actualisation** : Pull-to-refresh et bouton de rechargement

## 🚀 Instructions d'Installation et d'Exécution

### Prérequis

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code avec extensions Flutter
- Un émulateur Android/iOS ou un appareil physique

### Installation

1. **Cloner le projet**
   ```bash
   git clone <repository-url>
   cd onboarding
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Générer les fichiers de code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Lancer l'application**
   ```bash
   flutter run
   ```

### Tests

```bash
# Tests unitaires
flutter test

# Tests avec couverture
flutter test --coverage

# Tests d'intégration
flutter test integration_test/
```

## 🏗️ Architecture et Choix Techniques

### Architecture MVVM (Model-View-ViewModel)

L'application suit strictement le pattern MVVM avec une séparation claire des responsabilités :

```
lib/
├── domain/           # Couche métier (entités, interfaces)
├── data/            # Couche données (repositories, datasources)
├── presentation/    # Couche présentation (viewmodels, widgets, screens)
└── core/           # Couche infrastructure (DI, erreurs, constantes)
```

### Repository Pattern

- **Interface abstraite** : `TaskRepository` définit le contrat
- **Implémentation concrète** : `LocalTaskRepository` pour la persistance locale
- **DataSource** : `LocalTaskDataSource` encapsule SharedPreferences
- **Injection de dépendances** : `ServiceLocator` pour la gestion centralisée

### Modèles de Données Immuables

- Utilisation de **Freezed** pour des modèles immuables et sérialisables
- Extension `TaskExtensions` pour la logique métier
- Gestion automatique de la sérialisation JSON

### Gestion d'État

- **Provider** pour la gestion d'état réactive
- **ChangeNotifier** dans le ViewModel
- **Flux de données unidirectionnel**
- **Mise à jour optimiste** avec rollback en cas d'erreur

### Gestion d'Erreurs

- **Exceptions typées** : `AppException`, `TaskNotFoundException`, `StorageException`
- **Gestionnaire centralisé** : `ErrorHandler` pour le traitement uniforme
- **Messages utilisateur** : Feedback approprié selon le type d'erreur

## 🧪 Tests et Qualité

### Tests Unitaires

- **Repository** : Tests de la logique métier avec mocks
- **ViewModel** : Tests des états et transitions
- **Extensions** : Tests des méthodes utilitaires
- **DataSource** : Tests de la persistance locale

### Tests d'Intégration

- **Navigation** : Tests des flux utilisateur complets
- **Persistance** : Tests de sauvegarde/chargement
- **UI** : Tests des interactions utilisateur

### Qualité du Code

- **Linting** : Configuration `flutter_lints` pour la cohérence
- **Documentation** : Commentaires détaillés sur les méthodes complexes
- **Conventions** : Respect des conventions Dart/Flutter
- **Modularité** : Code organisé en modules cohérents

## 📱 Expérience Utilisateur

### Interface Moderne

- **Material Design 3** : Design moderne et cohérent
- **Thème adaptatif** : Support automatique du mode sombre
- **Animations fluides** : Transitions et feedback visuels
- **Accessibilité** : Support des lecteurs d'écran

### Feedback Utilisateur

- **SnackBars** : Messages de succès/erreur
- **Indicateurs de chargement** : Feedback pendant les opérations
- **États vides** : Messages informatifs quand aucune tâche
- **Confirmations** : Dialogs pour les actions destructives

## 🔧 Technologies Utilisées

### Dépendances Principales

- **flutter** : Framework principal
- **provider** : Gestion d'état
- **shared_preferences** : Persistance locale
- **freezed** : Modèles immuables
- **uuid** : Génération d'identifiants uniques

### Outils de Développement

- **build_runner** : Génération de code
- **json_serializable** : Sérialisation JSON
- **mockito** : Mocks pour les tests
- **flutter_lints** : Analyse statique du code

## 🚧 Difficultés Rencontrées et Solutions

### 1. Gestion de l'État Asynchrone

**Problème** : Synchronisation entre l'état local et la persistance
**Solution** : Mise à jour optimiste avec rollback automatique en cas d'erreur

### 2. Tests avec SharedPreferences

**Problème** : Tests unitaires avec dépendances externes
**Solution** : Utilisation de mocks avec Mockito et injection de dépendances

### 3. Gestion des Erreurs

**Problème** : Messages d'erreur cohérents et informatifs
**Solution** : Système d'exceptions typées avec gestionnaire centralisé

### 4. Performance de l'UI

**Problème** : Rebuilds inutiles lors des mises à jour
**Solution** : Utilisation de `Consumer` sélectif et `List.unmodifiable`

## 📈 Améliorations Futures

- **Tests d'intégration** : Couverture complète des flux utilisateur
- **Performance** : Optimisation des listes avec `ListView.builder`
- **Fonctionnalités** : Catégories, priorités, dates d'échéance
- **Synchronisation** : Support multi-appareils avec backend
- **Analytics** : Suivi des métriques d'utilisation

## 📄 Licence

Ce projet est développé dans le cadre d'une évaluation technique pour une entreprise française.

## 👨‍💻 Développeur

Développé avec ❤️ en respectant les meilleures pratiques Flutter et les standards professionnels de l'industrie.

---
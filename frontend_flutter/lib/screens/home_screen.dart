import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'calendar_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';
import 'task/add_edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _userMood = '😊'; // Default mood

  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    
    // Charger les tâches du jour à l'initialisation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchTasks(date: DateTime.now());
    });

    _tabs = [
      const TasksTab(),
      const CalendarScreen(),
      const StatisticsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textLight,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.check_box_outlined),
              activeIcon: Icon(Icons.check_box),
              label: 'Tâches',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Calendrier',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddEditTaskScreen(selectedDate: DateTime.now()),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
    );
  }
}

// Premier Onglet - Liste des tâches du jour
class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  String _currentMood = '😊';

  Color _getCategoryColor(TaskCategory cat) {
    switch (cat) {
      case TaskCategory.STUDY: return AppColors.study;
      case TaskCategory.WORK: return AppColors.work;
      case TaskCategory.PERSONAL: return AppColors.personal;
      case TaskCategory.HEALTH: return AppColors.health;
      case TaskCategory.SPORT: return AppColors.sport;
      case TaskCategory.MEETINGS: return AppColors.meetings;
      case TaskCategory.OTHER: return AppColors.other;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.HIGH: return AppColors.priorityHigh;
      case TaskPriority.MEDIUM: return AppColors.priorityMedium;
      case TaskPriority.LOW: return AppColors.priorityLow;
    }
  }

  String _getCategoryName(TaskCategory cat) {
    switch (cat) {
      case TaskCategory.STUDY: return 'Études';
      case TaskCategory.WORK: return 'Travail';
      case TaskCategory.PERSONAL: return 'Personnel';
      case TaskCategory.HEALTH: return 'Santé';
      case TaskCategory.SPORT: return 'Sport';
      case TaskCategory.MEETINGS: return 'Réunion';
      case TaskCategory.OTHER: return 'Autre';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    
    final username = authProvider.currentUser?.username ?? 'Utilisateur';
    final todayStr = DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now());
    // Capitaliser la première lettre de la date en français
    final formattedDate = todayStr.substring(0, 1).toUpperCase() + todayStr.substring(1);

    // Calculer les métriques
    final totalTasks = taskProvider.tasks.length;
    final completedTasks = taskProvider.tasks.where((t) => t.completed).length;
    final progress = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;
    final progressPct = (progress * 100).toInt();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => taskProvider.fetchTasks(date: DateTime.now()),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Salutations & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, $username',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    radius: 24,
                    child: Text(
                      username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Carte de progression du jour (Smart visualization)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.premiumShadow,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryMedium],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Progression du jour',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            totalTasks > 0
                                ? '$completedTasks tâches sur $totalTasks terminées'
                                : 'Aucune tâche planifiée aujourd\'hui',
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Barre de progression simplifiée
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Progression circulaire
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 6,
                            backgroundColor: AppColors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        ),
                        Text(
                          '$progressPct%',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tracker d'humeur / satisfaction
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  children: [
                    const Text(
                      'Comment se passe votre journée ?',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['😔', '😐', '😊', '🚀'].map((mood) {
                        final isSelected = _currentMood == mood;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentMood = mood;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryLight : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              mood,
                              style: TextStyle(
                                fontSize: isSelected ? 28 : 22,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // En-tête de la liste
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mes tâches du jour',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      taskProvider.fetchTasks(date: DateTime.now());
                    },
                    icon: const Icon(Icons.sync_rounded, size: 18),
                    label: const Text('Actualiser'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Liste des tâches
              taskProvider.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  : taskProvider.tasks.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.textLight.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.checklist_rounded, size: 60, color: AppColors.textLight.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              const Text(
                                'Toutes les tâches sont faites !',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMedium,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Profitez de votre temps libre ou créez une tâche.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textLight, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: taskProvider.tasks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final task = taskProvider.tasks[index];
                            
                            return Dismissible(
                              key: Key(task.id ?? index.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.priorityHigh.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.delete_outline_rounded, color: AppColors.priorityHigh, size: 28),
                              ),
                              onDismissed: (_) {
                                if (task.id != null) {
                                  taskProvider.deleteTask(task.id!);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: AppColors.softShadow,
                                  border: Border.all(
                                    color: task.completed 
                                        ? AppColors.textLight.withOpacity(0.1) 
                                        : Colors.transparent,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Checkbox(
                                    value: task.completed,
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    onChanged: (_) {
                                      taskProvider.toggleTaskCompletion(task);
                                    },
                                  ),
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: task.completed ? AppColors.textLight : AppColors.textDark,
                                      decoration: task.completed ? TextDecoration.lineThrough : null,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (task.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          task.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: task.completed ? AppColors.textLight : AppColors.textMedium,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          // Badge Catégorie
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getCategoryColor(task.category).withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: _getCategoryColor(task.category),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  _getCategoryName(task.category),
                                                  style: TextStyle(
                                                    color: _getCategoryColor(task.category),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Badge Priorité
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getPriorityColor(task.priority).withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              task.priority == TaskPriority.HIGH 
                                                  ? 'Urgent' 
                                                  : (task.priority == TaskPriority.MEDIUM ? 'Moyen' : 'Bas'),
                                              style: TextStyle(
                                                color: _getPriorityColor(task.priority),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                          if (task.time != null) ...[
                                            const SizedBox(width: 8),
                                            Icon(Icons.access_time_rounded, size: 12, color: AppColors.textLight),
                                            const SizedBox(width: 2),
                                            Text(
                                              task.time!,
                                              style: TextStyle(color: AppColors.textLight, fontSize: 11),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => AddEditTaskScreen(task: task),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

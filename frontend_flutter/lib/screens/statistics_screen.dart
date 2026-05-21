import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../providers/task_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final tasks = Provider.of<TaskProvider>(context).tasks;

    final total = tasks.length;

    final completed =
        tasks.where((t) => t.completed).length;

    final pending = total - completed;

    final progress =
        total == 0 ? 0 : ((completed / total) * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Statistiques",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),

                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryMedium,
                  ],
                ),
              ),

              child: Column(
                children: [

                  const Text(
                    "Progression de la semaine",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "$progress%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  LinearProgressIndicator(
                    value: total == 0
                        ? 0
                        : completed / total,

                    backgroundColor:
                        Colors.white.withOpacity(0.3),

                    valueColor:
                        const AlwaysStoppedAnimation(
                      Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [

                Expanded(
                  child: _card(
                    title: "Total",
                    value: "$total",
                    icon: Icons.task_alt,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _card(
                    title: "Terminées",
                    value: "$completed",
                    icon: Icons.check_circle,
                    color: AppColors.priorityLow,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [

                Expanded(
                  child: _card(
                    title: "En attente",
                    value: "$pending",
                    icon: Icons.pending_actions,
                    color: AppColors.priorityMedium,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _card(
                    title: "Succès",
                    value: "$progress%",
                    icon: Icons.bar_chart,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.softShadow,
      ),

      child: Column(
        children: [

          Icon(icon, color: color, size: 32),

          const SizedBox(height: 10),

          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}
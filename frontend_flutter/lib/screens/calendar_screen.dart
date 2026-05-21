import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/app_colors.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<TaskProvider>(
        context,
        listen: false,
      ).fetchTasks(date: _selectedDay);
    });
  }

  bool sameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    final tasks = taskProvider.tasks;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Calendrier",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [

          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppColors.softShadow,
            ),

            child: TableCalendar(
              firstDay: DateTime.utc(2024),
              lastDay: DateTime.utc(2035),
              focusedDay: _focusedDay,

              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },

              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                taskProvider.fetchTasks(date: selectedDay);
              },

              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryMedium,
                  shape: BoxShape.circle,
                ),

                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),

                selectedTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tâches du jour",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),

                Text(
                  "${tasks.length} tâche(s)",
                  style: TextStyle(
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Text(
                      "Aucune tâche pour cette date",
                      style: TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 16,
                      ),
                    ),
                  )

                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,

                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.softShadow,
                        ),

                        child: Row(
                          children: [

                            Icon(
                              task.completed
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: task.completed
                                  ? AppColors.priorityLow
                                  : AppColors.textMedium,
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [

                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      decoration: task.completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    task.description,
                                    style: TextStyle(
                                      color: AppColors.textMedium,
                                      fontSize: 13,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [

                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),

                                        decoration: BoxDecoration(
                                          color: task.completed
                                              ? AppColors.priorityLow
                                                  .withOpacity(0.15)
                                              : AppColors.primaryLight,

                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),

                                        child: Text(
                                          task.completed
                                              ? "Terminée"
                                              : "En attente",

                                          style: TextStyle(
                                            color: task.completed
                                                ? AppColors.priorityLow
                                                : AppColors.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      Text(
                                        task.time ?? "",
                                        style: TextStyle(
                                          color: AppColors.textMedium,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
class ProductivityStats {
  final int completedCount;
  final int pendingCount;
  final double completionRate;
  final double averageSatisfaction;
  final Map<String, int> categoryBreakdown;
  final Map<String, int> priorityBreakdown;
  final Map<String, double> weeklyProductivity;
  final Map<String, double> monthlyProductivity;

  ProductivityStats({
    required this.completedCount,
    required this.pendingCount,
    required this.completionRate,
    required this.averageSatisfaction,
    required this.categoryBreakdown,
    required this.priorityBreakdown,
    required this.weeklyProductivity,
    required this.monthlyProductivity,
  });

  factory ProductivityStats.fromJson(Map<String, dynamic> json) {
    // Parser categoryBreakdown
    final Map<String, int> catBreak = {};
    if (json['categoryBreakdown'] != null) {
      (json['categoryBreakdown'] as Map<String, dynamic>).forEach((k, v) {
        catBreak[k] = (v as num).toInt();
      });
    }

    // Parser priorityBreakdown
    final Map<String, int> prioBreak = {};
    if (json['priorityBreakdown'] != null) {
      (json['priorityBreakdown'] as Map<String, dynamic>).forEach((k, v) {
        prioBreak[k] = (v as num).toInt();
      });
    }

    // Parser weeklyProductivity
    final Map<String, double> weekProd = {};
    if (json['weeklyProductivity'] != null) {
      (json['weeklyProductivity'] as Map<String, dynamic>).forEach((k, v) {
        weekProd[k] = (v as num).toDouble();
      });
    }

    // Parser monthlyProductivity
    final Map<String, double> monthProd = {};
    if (json['monthlyProductivity'] != null) {
      (json['monthlyProductivity'] as Map<String, dynamic>).forEach((k, v) {
        monthProd[k] = (v as num).toDouble();
      });
    }

    return ProductivityStats(
      completedCount: json['completedCount'] ?? 0,
      pendingCount: json['pendingCount'] ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
      averageSatisfaction: (json['averageSatisfaction'] as num?)?.toDouble() ?? 0.0,
      categoryBreakdown: catBreak,
      priorityBreakdown: prioBreak,
      weeklyProductivity: weekProd,
      monthlyProductivity: monthProd,
    );
  }
}

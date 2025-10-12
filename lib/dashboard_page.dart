import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'course_provider.dart';
import 'models.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final courses = provider.courses;

    final totalVideos = courses.fold<int>(
      0,
      (prev, course) => prev + course.videos.length,
    );
    final completedVideos = courses.fold<int>(
      0,
      (prev, course) => prev + course.videos.where((v) => v.isComplete).length,
    );
    final overallPercent = totalVideos == 0
        ? 0.0
        : completedVideos / totalVideos;

    return Scaffold(
      appBar: AppBar(title: const Text("📊 My Dashboard")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Overall Progress ---
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      "Overall Progress",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CircularPercentIndicator(
                      radius: 100,
                      lineWidth: 12,
                      percent: overallPercent,
                      center: Text(
                        "${(overallPercent * 100).round()}%",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      progressColor: Colors.greenAccent.shade700,
                      backgroundColor: Colors.grey.shade300,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Stats Cards ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatCard(
                  title: "Courses",
                  value: courses.length.toString(),
                  color: Colors.blueAccent,
                  icon: Icons.book,
                ),
                _StatCard(
                  title: "Videos",
                  value: totalVideos.toString(),
                  color: Colors.orangeAccent,
                  icon: Icons.video_library,
                ),
                _StatCard(
                  title: "Completed",
                  value: completedVideos.toString(),
                  color: Colors.greenAccent.shade700,
                  icon: Icons.check_circle,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Course-wise Progress Bar Chart ---
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Course-wise Completion",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: courses.length * 60.0, // adjust width per bar
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              barGroups: courses.map((c) {
                                final total = c.videos.length;
                                final completed = c.videos
                                    .where((v) => v.isComplete)
                                    .length;
                                final percent = total == 0
                                    ? 0.0
                                    : completed / total * 100;

                                return BarChartGroupData(
                                  x: courses.indexOf(c),
                                  barRods: [
                                    BarChartRodData(
                                      toY: percent,
                                      color: Colors.greenAccent.shade700,
                                      width: 20,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ],
                                );
                              }).toList(),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 60,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= courses.length)
                                        return const SizedBox();
                                      String name = courses[index].name;
                                      if (name.length > 8)
                                        name = name.substring(0, 8) + '...';
                                      return Transform.rotate(
                                        angle: -0.5, // rotate -30 degrees
                                        child: Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    },
                                    interval: 1,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 20,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) => Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                horizontalInterval: 20,
                              ),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: color,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

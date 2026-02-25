import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/task_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final total = provider.tasks.length;
    final completed = provider.completedCount;
    final uncompleted = provider.uncompletedCount;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            _SummaryCard(
                total: total, completed: completed, uncompleted: uncompleted),
            const SizedBox(height: 24),

            Text('Completion Ratio',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            if (total == 0)
              _EmptyChartState()
            else
              _PieSection(
                  completed: completed,
                  uncompleted: uncompleted,
                  colorScheme: colorScheme),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int total, completed, uncompleted;
  const _SummaryCard(
      {required this.total,
      required this.completed,
      required this.uncompleted});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pct = total == 0 ? 0 : (completed / total * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                  icon: Icons.list_alt_rounded,
                  label: 'Total',
                  value: '$total',
                  color: colorScheme.primary),
            ),
            Expanded(
              child: _StatItem(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Done',
                  value: '$completed',
                  color: Colors.green.shade600),
            ),
            Expanded(
              child: _StatItem(
                  icon: Icons.radio_button_unchecked_rounded,
                  label: 'Pending',
                  value: '$uncompleted',
                  color: colorScheme.error),
            ),
            Expanded(
              child: _StatItem(
                  icon: Icons.percent_rounded,
                  label: 'Rate',
                  value: '$pct%',
                  color: colorScheme.tertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatItem(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
      ],
    );
  }
}

class _EmptyChartState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.pie_chart_outline_rounded,
                size: 72,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No tasks yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Add tasks in the Tasks tab to see your progress.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _PieSection extends StatelessWidget {
  final int completed, uncompleted;
  final ColorScheme colorScheme;
  const _PieSection(
      {required this.completed,
      required this.uncompleted,
      required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final total = completed + uncompleted;
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: completed.toDouble(),
                  color: Colors.green.shade500,
                  title: '${(completed / total * 100).toStringAsFixed(1)}%',
                  radius: 80,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                PieChartSectionData(
                  value: uncompleted.toDouble(),
                  color: colorScheme.error,
                  title: '${(uncompleted / total * 100).toStringAsFixed(1)}%',
                  radius: 80,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
              sectionsSpace: 3,
              centerSpaceRadius: 45,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: Colors.green.shade500, label: 'Completed ($completed)'),
            const SizedBox(width: 24),
            _LegendDot(color: colorScheme.error, label: 'Pending ($uncompleted)'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
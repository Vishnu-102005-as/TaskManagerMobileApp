import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/streak_task.dart';
import '../provider/streak_provider.dart';

class StreakPage extends StatelessWidget {
  const StreakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Streaks 🔥',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
      ),
      body: Consumer<StreakProvider>(
        builder: (context, provider, _) {
          final tasks = provider.tasks;
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      size: 72,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.35)),
                  const SizedBox(height: 16),
                  Text('No streak habits yet',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    'Tap + to add a daily habit to track.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 90),
            itemCount: tasks.length,
            itemBuilder: (context, index) =>
                _StreakCard(task: tasks[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Daily Habit'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'e.g. Drink 2L of water',
            prefixIcon: Icon(Icons.local_fire_department_outlined),
          ),
          onSubmitted: (_) => _submit(ctx, controller),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _submit(ctx, controller),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext ctx, TextEditingController controller) {
    final title = controller.text.trim();
    if (title.isEmpty) return;
    ctx.read<StreakProvider>().addStreakTask(title);
    Navigator.of(ctx).pop();
  }
}

class _StreakCard extends StatelessWidget {
  final StreakTask task;
  const _StreakCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(14)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text('Delete',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      onDismissed: (_) =>
          context.read<StreakProvider>().deleteStreakTask(task.id),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: task.completedToday
              ? null
              : () => context.read<StreakProvider>().toggleStreakTask(task.id),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Streak Flame + count
                Column(
                  children: [
                    Text(
                      task.completedToday ? '🔥' : '⭕',
                      style: const TextStyle(fontSize: 26),
                    ),
                    Text(
                      '${task.streak}',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: task.streak > 0
                            ? Colors.orange.shade700
                            : colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: task.completedToday
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: task.completedToday
                              ? colorScheme.onSurface.withValues(alpha: 0.45)
                              : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.completedToday
                            ? 'Completed today ✓'
                            : task.streak > 0
                                ? '${task.streak}-day streak — tap to complete today'
                                : 'Tap to start your streak!',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                if (task.completedToday)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Done',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../provider/task_provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.read<TaskProvider>().toggleTask(task.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: task.completed,
                    activeColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    onChanged: (_) =>
                        context.read<TaskProvider>().toggleTask(task.id),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: task.completed
                                ? colorScheme.onSurface.withValues(alpha: 0.45)
                                : colorScheme.onSurface,
                          ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            task.description,
                            style: textTheme.bodySmall?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.55),
                              decoration: task.completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (task.completed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Done',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                ],
              ),

              // Time info row
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Wrap(
                  spacing: 12,
                  children: [
                    _TimeChip(
                      icon: Icons.access_time_rounded,
                      label: 'Created: ${formatTime(task.createdAt)}',
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    if (task.completed && task.completedAt != null)
                      _TimeChip(
                        icon: Icons.check_circle_outline_rounded,
                        label:
                            'Done: ${formatTime(task.completedAt!)} · ${computeDuration(task.createdAt, task.completedAt!)}',
                        color: Colors.green.shade600,
                      ),
                  ],
                ),
              ),

              // Image thumbnail
              if (task.imagePath != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(task.imagePath!),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 60,
                      color: colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Text('Image not found',
                            style: textTheme.bodySmall),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}  $h:$m';
  }

  String computeDuration(DateTime start, DateTime end) {
    final diff = end.difference(start);
    if (diff.inMinutes < 1) return '<1m';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

class _TimeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _TimeChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label,
            style:
                Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
      ],
    );
  }
}

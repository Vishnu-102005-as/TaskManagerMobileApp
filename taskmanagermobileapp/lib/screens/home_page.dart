import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../provider/task_provider.dart';
import '../widgets/task_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('My Tasks',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          final tasks = provider.tasks;
          if (tasks.isEmpty) return const _EmptyView();
          return _TaskList(tasks: tasks);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-task'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  const _TaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 90),
      itemCount: tasks.length,
      itemBuilder: (context, index) =>
          _SwipableTaskCard(task: tasks[index]),
    );
  }
}

class _SwipableTaskCard extends StatelessWidget {
  final Task task;
  const _SwipableTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: _deletionBackground(),
      onDismissed: (_) => _handleDelete(context),
      child: TaskCard(task: task),
    );
  }

  Widget _deletionBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(14),
      ),
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
    );
  }

  void _handleDelete(BuildContext context) {
    final provider = context.read<TaskProvider>();
    final deleted = task;
    provider.deleteTask(deleted.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          content: Text('"${deleted.title}" deleted',
              overflow: TextOverflow.ellipsis),
          action: SnackBarAction(
              label: 'Undo',
              onPressed: () => provider.restoreTask(deleted)),
        ),
      );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checklist_rounded,
              size: 72,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.35)),
          const SizedBox(height: 16),
          Text('No tasks yet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Tap the + button below to add your first task.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
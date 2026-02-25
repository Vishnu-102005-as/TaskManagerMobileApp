import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../provider/task_provider.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _imagePath;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    context.read<TaskProvider>().addTask(
          title: _titleController.text,
          description: _descController.text,
          imagePath: _imagePath,
        );

    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Discard',
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _fieldLabel(context, 'Task Title', colorScheme),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
                    colorScheme, 'e.g. Buy groceries', Icons.title_rounded),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a task title.';
                  }
                  if (v.trim().length < 3) {
                    return 'Title must be at least 3 characters.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              _fieldLabel(context, 'Description (optional)', colorScheme),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(colorScheme,
                    'Add more details about this task…', Icons.description_outlined),
              ),

              const SizedBox(height: 20),
              _fieldLabel(context, 'Image (optional)', colorScheme),
              const SizedBox(height: 8),

              // Image Picker Section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: _imagePath != null ? 180 : 80,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.4)),
                  ),
                  child: _imagePath != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.file(File(_imagePath!),
                                  fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _imagePath = null),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: colorScheme.primary, size: 26),
                            const SizedBox(width: 10),
                            Text('Tap to attach an image',
                                style: TextStyle(color: colorScheme.primary)),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.add_task_rounded),
                label: Text(
                  _isSubmitting ? 'Adding…' : 'Add Task',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(
      BuildContext context, String label, ColorScheme colorScheme) {
    return Text(label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.primary, fontWeight: FontWeight.w600));
  }

  InputDecoration _inputDecoration(
      ColorScheme colorScheme, String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/notes_repository.dart';
import '../models/note.dart';

class NoteDetailsPage extends StatelessWidget {
  final int id;
  final NotesRepository repo;
  const NoteDetailsPage({super.key, required this.id, required this.repo});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Note>(
      future: repo.get(id),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snap.error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Назад'),
                  ),
                ],
              ),
            ),
          );
        }

        final n = snap.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text('Заметка #${n.id}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDialog(context, n),
                tooltip: 'Редактировать',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${n.id}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      n.body,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Note note) {
    final titleController = TextEditingController(text: note.title);
    final bodyController = TextEditingController(text: note.body);
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Редактировать заметку'),
            content: isLoading
                ? const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Заголовок',
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: bodyController,
                        decoration: const InputDecoration(
                          labelText: 'Текст заметки',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        minLines: 3,
                      ),
                    ],
                  ),
            actions: [
              if (!isLoading) ...[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () async {
                    final newTitle = titleController.text.trim();
                    final newBody = bodyController.text.trim();

                    if (newTitle.isEmpty || newBody.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Заполните все поля')),
                      );
                      return;
                    }

                    setDialogState(() => isLoading = true);

                    try {
                      await repo.update(note.id, newTitle, newBody);

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        // Обновляем страницу
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) =>
                                NoteDetailsPage(id: note.id, repo: repo),
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Заметка обновлена')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        setDialogState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ошибка обновления: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'models/note.dart';

class EditNotePage extends StatefulWidget {
  final Note? existing;
  const EditNotePage({super.key, this.existing});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late String _title = widget.existing?.title ?? '';
  late String _body = widget.existing?.body ?? '';

  // Определяем цвет
  final Color _primaryColor = const Color.fromARGB(255, 65, 105, 214);

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final result = (widget.existing == null)
        ? Note(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: _title,
            body: _body,
          )
        : widget.existing!.copyWith(title: _title, body: _body);

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Редактировать' : 'Новая заметка'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Заголовок',
                  labelStyle: TextStyle(color: _primaryColor),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _primaryColor),
                  ),
                ),
                onSaved: (v) => _title = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _body,
                decoration: InputDecoration(
                  labelText: 'Текст',
                  labelStyle: TextStyle(color: _primaryColor),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _primaryColor),
                  ),
                ),
                minLines: 3,
                maxLines: 6,
                onSaved: (v) => _body = v!.trim(),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Введите текст заметки'
                    : null,
              ),
              const Spacer(),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check),
                    SizedBox(width: 8),
                    Text('Сохранить', style: TextStyle(fontSize: 17)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

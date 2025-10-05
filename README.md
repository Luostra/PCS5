# Программирование корпоративных систем - практика 5
## Подготовил Ключников А.Д., ЭФБО-09-23
### Цели и задачи ПЗ:
* Научиться отображать коллекции данных с помощью ListView.builder.
* Освоить базовую навигацию Navigator.push / Navigator.pop и передачу данных через конструктор.
* Научиться добавлять, редактировать и удалять элементы списка без внешних пакетов и сложных архитектур.
* Разработать мини-приложение «Simple Notes» с одним списком заметок, позволяющее добавлять, изменять и удалять записи.
* Применить Dismissible для удаления заметок.
* Добавить поле поиска в AppBar.

### Демонстрация работы приложения

* Добавление заметки (GIF)

![Запись 2025-10-06 000422](https://github.com/user-attachments/assets/86ce49fe-1501-43bd-b538-1c1b0c780725)

* Редактирование заметки (GIF)

![Запись экрана 2025-10-06 002331](https://github.com/user-attachments/assets/d13867b4-e5d3-4983-9ce0-c7a7e5afdd46)

* Поиск заметок (GIF)

![Запись экрана 2025-10-06 002003](https://github.com/user-attachments/assets/0805ac20-f3c3-46bd-9abe-f79e1b1862e8)

* Удаление заметок (GIF)

![Запись экрана 2025-10-06 002559](https://github.com/user-attachments/assets/a6872733-9e36-4fbc-b378-215d8fcd7c33)

### Ход работы

* Создал проект приложения на Flutter
* Подготовил структуру файлов:
<img width="463" height="168" alt="image" src="https://github.com/user-attachments/assets/753c02e2-73ca-4898-9ea8-f65a93d2c4f6" />

* В note.dart написал класс Note (модель данных заметки)

      class Note {
        final String id;
        String title;
        String body;
      
        Note({required this.id, required this.title, required this.body});
      
        Note copyWith({String? title, String? body}) => Note(
          id: id,
          title: title ?? this.title,
          body: body ?? this.body,
        );
      }
  
* Создал главный экран со списком в main.dart. Код списка ниже:

      final List<Note> _notes = [
        Note(id: '1', title: 'Пример', body: 'Это пример заметки'),
        Note(id: '2', title: 'Второй пример', body: 'Это пример заметки'),
        Note(id: '3', title: 'Третий пример', body: 'Это пример заметки'),
        Note(id: '4', title: 'Четвёртый пример', body: 'Это пример заметки'),
        Note(id: '5', title: 'Пятый пример', body: 'Это очередной пример заметки'),
        Note(id: '6', title: 'Шестой пример', body: 'Это пример заметки'),
        Note(id: '7', title: 'Седьмой пример', body: 'Это ещё один пример заметки'),
        Note(id: '8', title: 'Восьмой пример', body: 'Это пример заметки'),
      ];

* в edit_note_page.dart реализовал экран добавления/редактирования заметки. Пример кода для перехода на эту страницу с главного экрана ниже (применение Navigator.push):

      Future<void> _addNote() async {
          final newNote = await Navigator.push<Note>(
            context,
            MaterialPageRoute(builder: (_) => EditNotePage()),
          );
          if (newNote != null) {
            setState(() => _notes.add(newNote));
          }
        }

для возврата на главный экран из edit_note_page используется `Navigator.pop(context, result)`

* Помимо кнопки, удаление заметки реализовано через свайп (Dismissible):

              ListView.builder(
                    itemCount: _filteredNotes.length,
                    itemBuilder: (context, i) {
                      final note = _filteredNotes[i];
                      return Dismissible(
                        background: Container(
                          color: Colors.red,
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                        ),
                        key: ValueKey(note.id),
                        onDismissed: (DismissDirection direction) {
                          _delete(note);
                        },
                        child: ListTile(
                          key: ValueKey(note.id),
                          title: Text(
                            note.title.isEmpty ? '(без названия)' : note.title,
                          ),
                          subtitle: Text(
                            note.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _edit(note),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _delete(note),
                          ),
                        ),
                      );
                    },
                  ),

* Для реализации строки поиска по названию был добавлен отдельный список _filtered_notes, а также ряд методов, реализующих поиск (_onSearchChanged(), _startSearch(), _stopSearching(), _clearSearchQuery() и другие). Также был создан виджет для поисковой строки, код ниже:


      Widget _buildSearchField() {
        return TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Поиск по заголовку...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.white),
              onPressed: _clearSearchQuery,
            ),
          ),
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        );
      }

* Для придания единого стиля интерфейсу приложения использовалась определённая палитра цветов (белый, серый и синий `Color.fromARGB(255, 65, 105, 214)`). Чтобы сделать интерфейс интуитивным, активно применялись иконки

### Вывод

В итоге было разработано приложение, позволяющее добавлять, редактировать и удалять заметки. Список заметок отображается на главном экране с помощью ListView.builder (коллекция динамическая). Реализован переход между главным экраном и экраном редактирования заметки с помощью Navigator.push и Navigator.pop. Удалять заметки можно как по кнопке, так и жестом (исп. виджет Dismissible). Наиболее трудным в реализации был поиск по заметкам. Для его реализации потребовалось написать два виджета и несколько методов. 

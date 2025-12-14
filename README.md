# Программирование корпоративных систем - практика 13 (14). Тестирование и оптимизация мобильного приложения. Исправление ошибок (Flutter)
## Подготовил Ключников А.Д., ЭФБО-09-23

Для тестирования была выбрана программа Notes SQLite из ПЗ №9
---

## 1. Цели работы

-	Освоить базовые виды тестирования во Flutter: unit-, widget- и integration-tests.
-	Настроить линтинг и статический анализ, повысить качество кода.
-	Научиться профилировать производительность (FPS, jank, память, пропуски кадров) через DevTools и Performance Overlay.
-	Применить практики оптимизации: уменьшение количества перестроений, работа со списками, изоляция тяжёлых вычислений, оптимизация изображений.
-	Настроить сбор аварий (Crashlytics/Sentry — опционально).
-	Отработать цикл «поиск дефекта → воспроизведение → минимальный пример → исправление → тест/регресс».

---

## 2. Среда разработки и версии ПО

* **ОС:** Windows 11
* **Flutter SDK:** stable 3.35.2
* **IDE:** Visual Studio Code
* **Эмулятор:** Android 16 Emulator (Android Studio)
* **Основные зависимости:**

```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  sqflite: ^2.4.2
  path: ^1.9.1
  path_provider: ^2.1.5
  flutter_lints: ^6.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  sqflite_common_ffi: ^2.3.6
  test: ^1.24.0
```

---

**Выполнение команды** `flutter analyze`

<img width="1827" height="232" alt="Снимок экрана 2025-12-14 222307" src="https://github.com/user-attachments/assets/aef50581-8e5a-4e74-a24e-7c503d4237af" />

**Выполнение команды** `flutter analyze` **после исправления ошибок** 

<img width="1011" height="108" alt="Снимок экрана 2025-12-15 000411" src="https://github.com/user-attachments/assets/6bc5714e-6cb9-4874-8295-a9bf190d3471" />


## 3. Тестирование (unit / widget / integration + coverage)

### Unit-тестирование

Unit-тесты были реализованы для модели `Note`, содержащей чистую бизнес-логику и не зависящей от платформенных API. Тестами проверены:

* метод `copyWith`,
* сериализация и десериализация (`toMap` / `fromMap`),
* значения по умолчанию,
* корректность работы с датами.

Всего реализовано **5 unit-тестов**.

<img width="1098" height="133" alt="Снимок экрана 2025-12-14 223808" src="https://github.com/user-attachments/assets/012f3beb-af32-459a-8187-c8208376220b" />

### Coverage

Покрытие модели `Note` составляет около **95–100%**.
Класс `DBHelper` не покрывался unit-тестами осознанно, так как зависит от платформенных API и предназначен для проверки на уровне integration-тестов.  

Скриншот ковередж результатов

<img width="621" height="779" alt="image" src="https://github.com/user-attachments/assets/59f976f6-007d-4058-b16e-9713f16ebbeb" />



### Widget-тестирование

Widget-тесты проверяют корректность работы пользовательского интерфейса экрана `NotesPage`:

* рендер заголовка и кнопки добавления,
* открытие диалога создания заметки,
* отображение индикатора загрузки.

Тестирование выполнялось без обращения к SQLite, с ручным управлением кадрами (`pump()`).


<img width="983" height="83" alt="Снимок экрана 2025-12-14 225755" src="https://github.com/user-attachments/assets/81f6e7e5-5844-4fba-9fa6-49e968a8ec93" />


---

## 4. Профилирование до оптимизации

Профилирование выполнялось в режиме `profile` с использованием Flutter DevTools. В ходе тестирования фиксировались показатели FPS, количество пропущенных кадров (jank), 
частота перестроений виджетов и использование памяти.

**Скриншот вкладки Performance**

<img width="2559" height="490" alt="Снимок экрана 2025-12-15 000841" src="https://github.com/user-attachments/assets/fa2af96a-e15b-46f0-b0bd-a6d2dfdd6456" />

<img width="2559" height="397" alt="Снимок экрана 2025-12-15 000927" src="https://github.com/user-attachments/assets/f524b3c9-7848-48ab-8e0a-30dd23358ffc" />

Наблюдаются заметные фризы (junk'и ~27ms), средний FPS: 53

**Скриншоты вкладки Memory**

<img width="2552" height="1305" alt="Снимок экрана 2025-12-14 235636" src="https://github.com/user-attachments/assets/642c8577-d622-46ac-9799-2dabacc89eab" />

Повышенное количество объектов в памяти

---

## 5. Перечень оптимизаций (с пояснениями и кодом)

### Основные оптимизации:

1. Элемент списка заметок вынесен в отдельный `StatelessWidget`, что позволило сократить количество перестроений UI.
2. Добавлены `const` конструкторы для неизменяемых виджетов, что уменьшило количество аллокаций.
3. Сокращена область вызова `setState`, обновление данных вынесено в отдельный метод.
4. Устранено использование deprecated API (`withOpacity` заменён на `withValues`).
5. В запросы SQLite добавлена пагинация (`LIMIT`, `OFFSET`) для повышения масштабируемости.
6. Используются стабильные ключи (`ValueKey`) для элементов списка.

### Пример оптимизации (вынос элемента списка):

```dart
class NoteListItem extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;

  const NoteListItem({
    super.key,
    required this.note,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}
```

---

## 6. Профилирование после оптимизации

**Скриншоты вкладки Performance**

<img width="2529" height="447" alt="Снимок экрана 2025-12-14 235536" src="https://github.com/user-attachments/assets/0efdb0b9-dce9-485b-9bff-15555e960fa1" />

<img width="2559" height="545" alt="Снимок экрана 2025-12-14 235622" src="https://github.com/user-attachments/assets/89a025fe-9b41-4adb-b320-386b61b1525e" />

Всё еще наблюдаются junk'и, но их частота и интенсивность слегка снижена. Средний FPS вырос с 53 до 56.

**Скриншот вкладки Memory**

<img width="2559" height="1281" alt="Снимок экрана 2025-12-15 001332" src="https://github.com/user-attachments/assets/1fd8d28a-15e1-4f04-a2e6-b68a13ba9737" />

Уменьшенное и более стабильное потребление памяти

Результаты:

* FPS (UI и Raster): около 56 кадров в секунду;
* критических просадок производительности не выявлено;
* при добавлении и удалении заметок наблюдалось полное перестроение экрана `NotesPage`;
* использование памяти оставалось стабильным, утечек не выявлено.


---

## 7. Анализ размера приложения «до/после»

Анализ размера выполнялся с помощью команды `flutter build apk --analyze-size`.

Скриншот отчёта Analyze Size (до принятия мер по снижению размеров)

![photo_2025-12-15_01-52-48](https://github.com/user-attachments/assets/3a2584be-adb1-4926-8127-487ea505b40b)

Скриншот отчёта Analyze Size (после принятия мер по снижению размеров)

![photo_2025-12-15_01-56-42](https://github.com/user-attachments/assets/4e2e9301-890d-4a62-bce3-c5324451b0f4)

Список предпринятых мер:

- Удаление неиспользуемых ассетов и шрифтов
- Tree-shake 
- APK разеделены по архитектурам процессора (ABI)

Существенных резервов для уменьшения размера приложения выявлено не было.

---

## 8. Обработка ошибок

В приложении реализована многоуровневая обработка ошибок:

* глобальный перехват исключений с помощью `runZonedGuarded`;

Пример глобального перехватчика (добавлен в `main.dart`:

```dart
runZonedGuarded(
    () {
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('Flutter error: ${details.exception}');
      };

      runApp(const MyApp());
    },
    (error, stackTrace) {
      debugPrint('Uncaught zone error: $error');
    },
  );
```



* обработка ошибок Flutter через `FlutterError.onError`;
* fallback-интерфейс с использованием `ErrorWidget.builder`;
* локальная обработка ошибок SQLite с использованием `try-catch`;
* обработка ошибок асинхронных операций через `FutureBuilder.hasError`.

Данный подход предотвращает аварийное завершение приложения и повышает его устойчивость.

---

## 9. Выводы

В ходе выполнения работы были реализованы основные виды тестирования Flutter-приложения, выполнено профилирование и проведена оптимизация производительности. Анализ показал, что даже небольшие архитектурные изменения позволяют сократить количество перестроений интерфейса и повысить плавность работы UI. Реализация обработки ошибок повысила стабильность приложения и улучшила пользовательский опыт. Полученные навыки могут быть применены при разработке и оптимизации реальных Flutter-приложений.






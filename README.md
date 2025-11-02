# Программирование корпоративных систем - практика 7 (Работа с базами данных. Подключение приложения к Firebase)
## Подготовил Ключников А.Д., ЭФБО-09-23

1.	Скриншот настроенного проекта Firebase (страница проекта или Firestore с коллекцией notes).
<img width="2559" height="1410" alt="image" src="https://github.com/user-attachments/assets/aeea67c4-0ff5-450c-af02-5c420f6a5d7d" />

2.	Скриншот запущенного приложения с отображением списка (пустого или с данными).
<img width="669" height="1524" alt="image" src="https://github.com/user-attachments/assets/36108328-95e9-45d3-8069-0db8a82335cd" />

3.	Скриншот после добавления заметки (элемент появился в списке).
<img width="666" height="1521" alt="image" src="https://github.com/user-attachments/assets/12f2c3b3-978e-4a23-b9c9-406a9bde1e3a" />
<img width="664" height="1520" alt="image" src="https://github.com/user-attachments/assets/b166ba70-4b56-4ae6-9385-d5a7d9497769" />

4.	Скриншот после редактирования (обновлённый заголовок/текст).
<img width="664" height="1517" alt="image" src="https://github.com/user-attachments/assets/37167d66-312e-427c-b8c2-244eaf7bd9f9" />
<img width="659" height="1526" alt="image" src="https://github.com/user-attachments/assets/ccf5ba68-cb3c-49d7-b22d-882da42f8921" />



5.	Скриншот после удаления (элемент исчез).

<img width="661" height="1520" alt="image" src="https://github.com/user-attachments/assets/dc4652f8-e953-4333-8853-b2eb31f8ba3b" />

## Отчёт по работе

### **Создание и привязка Firebase-проекта**
Проект Firebase был создан через **Firebase Console** с последующей привязкой через **FlutterFire CLI**:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
CLI автоматически сгенерировал файлы конфигурации для платформы Android и `firebase_options.dart`.

---

### **Используемые пакеты и инициализация Firebase**

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  cloud_firestore: ^5.4.4
```

**Инициализация** выполнена в `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const NotesApp());
}
```

---

### **Структура Firestore**
```
/notes
  /{noteId}
    - title: string
    - content: string
    - createdAt: timestamp
    - updatedAt: timestamp
```

---

### **Правила безопасности (текущие)**
```javascript
// Firestore Security Rules (учебный режим!):
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      // Разрешить чтение/запись всем в рамках практики
      allow read, write: if true;
    }
  }
}
```

Полный доступ для всех пользователей — это небезопасно для продакшена.

---

### **Безопасность: что необходимо поменять в продакшене**

* подключить аутентификацию пользователей (firebase_auth);
* ужесточить правила безопасности (allow read, write: if request.auth != null;);
* предусмотреть валидацию данных и обработку ошибок.


### Итог
В результате выполнения практической работы было создано полноценное приложение для заметок, в котором все изменения мгновенно отображаются в интерфейсе пользователя благодаря реактивной модели Firestore. Текущая конфигурация приложения подходит для обучения и разработки, но требует существенного усиления безопасности.

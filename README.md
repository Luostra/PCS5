# Программирование корпоративных систем - практика 8 (Работа с базами данных. Подключение приложения к Supabase)
## Подготовил Ключников А.Д., ЭФБО-09-23

1.	Скриншоты настроенного проекта Supabase (Dashboard: Database → notes, включён RLS, список Policies).
<img width="1920" height="1008" alt="Снимок экрана 2025-11-06 173810" src="https://github.com/user-attachments/assets/bd669884-cb2d-44ee-a17b-cdea237312f8" />

<img width="1920" height="1005" alt="Снимок экрана 2025-11-06 173722" src="https://github.com/user-attachments/assets/6b568810-1d87-4684-836a-359574a2b417" />

2.	Скриншот экрана входа и экрана со списком (пустого и с данными).

 - экран входа:
<img width="1080" height="1424" alt="Снимок экрана 2025-11-06 172037" src="https://github.com/user-attachments/assets/465dd6ad-e2cd-4c9b-87b8-ad48a9e3b07a" />

 - экран со списком (пустым):
<img width="1108" height="1408" alt="Снимок экрана 2025-11-06 171659" src="https://github.com/user-attachments/assets/0edd2bcf-e017-44ed-a0ea-fbbdb134f606" />

 - экран со списком (с данными):
<img width="1114" height="1417" alt="Снимок экрана 2025-11-06 172136" src="https://github.com/user-attachments/assets/a2c2eb7e-a00d-4db9-be3a-2bcd6353ba73" />

3.	Скриншот после добавления заметки (элемент появился).
<img width="1073" height="1425" alt="Снимок экрана 2025-11-06 172519" src="https://github.com/user-attachments/assets/bdfdf628-623a-4549-b48a-b08008e21fb6" />

4.	Скриншоты после удаления и после редактирования.

 - после удаления:
<img width="1132" height="1440" alt="Снимок экрана 2025-11-06 172726" src="https://github.com/user-attachments/assets/2f035262-1edc-42f0-95fc-513fbeeb5cec" />

 - после редактирования:
<img width="1230" height="1434" alt="Снимок экрана 2025-11-06 172823" src="https://github.com/user-attachments/assets/b7218134-35a5-4990-aad3-475f6700ca18" />

**1. Подключение Supabase:**
- создан проект на [supabase.com](https://supabase.com), получены **Project URL** и **anon (public) key** из настроек проекта в Dashboard;
- в проекте создана таблица `notes` с включённым RLS (Row Level Security).

---

**2. Зависимости и инициализация:**
В `pubspec.yaml` добавлен пакет:  
  ```yaml
  dependencies:
    supabase_flutter: ^2.10.3
  ```
Инициализация выполнена в `main.dart`:  
  ```dart
  const supabaseUrl = 'https://ehiqncbnfmsilvrprzfc.supabase.co';
  const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVoaXFuY2JuZm1zaWx2cnByemZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0MTI4NDAsImV4cCI6MjA3Nzk4ODg0MH0.OhjnMA4meU6jJp86GviXtjyxQhMxFoYHygt5AsbaOMY';

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    runApp(const NotesApp());
  }

  ```

---

**3. Поля таблицы `notes`:**
  - `id` (uuid, первичный ключ)  
  - `user_id` (uuid, не nullable)  
  - `title` (text)  
  - `content` (text)  
  - `created_at` (timestamp с timezone)  
  - `updated_at` (timestamp с timezone)  

---

**4. Политики безопасности (RLS) для таблицы `notes`:**
- включён RLS на таблице;  
- созданы политики для операций:  
  - **SELECT**: только свои записи (`user_id = auth.uid()`);  
  - **INSERT**: только с своим `user_id`;  
  - **UPDATE**: только свои записи;  
  - **DELETE**: только свои записи.  

Пример политики для SELECT:  
```sql
create policy "Read own notes"
on public.notes
for select
to authenticated
using (user_id = auth.uid());
```


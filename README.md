# Программирование корпоративных систем - практика 11 (12). Аппаратная часть мобильных устройств. Работа с камерой

## Подготовил Ключников А.Д., ЭФБО-09-23

### Цели работы:

- Изучить архитектуру и возможности аппаратной части мобильных устройств.
- Ознакомиться с API камеры и галереи во Flutter.
- Научиться создавать приложения, использующие камеру и хранилище устройства.
- Разобраться с разрешениями, обработкой изображений и сохранением данных.

### Ход выполнения:

#### 1. Установка зависимостей

Были установлены следующие зависимости:

```
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  image_picker: ^1.2.1
  permission_handler: ^12.0.1
  path_provider: ^2.1.5
  image: ^4.5.4
  chewie: ^1.13.0
  video_player: ^2.10.1
```

#### 2. Разрешения

Для работы с камерой или файлами необходимо запросить разрешение у пользователя

Android:

```
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

Строки выше нужно было добавить в файл `android/app/src/main/AndroidManifest.xml`

iOS:

```
<key>NSCameraUsageDescription</key>
<string>Для работы приложения требуется доступ к камере</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Для выбора изображений из галереи требуется разрешение</string>
```

Строки выше нужно было добавить в файл `ios/Runner/Info.plist`

#### 3. Код:

Основные классы:

`CameraApp` - корневой виджет приложения

```dart
class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Demo',
      theme: ThemeData(useMaterial3: true),
      home: const CameraPage(),
    );
  }
}
```

`CameraPage` - главный экран с StatefulWidget

```dart
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}
```

`_CameraPageState` - состояние со всей бизнес-логикой

Основные функции:

Работа с фото:

```dart
_getImage()       // Выбор фото из камеры/галереи
_applyFilter()    // Применение фильтров к изображению
_saveImage()      // Сохранение фото в память устройства
```

Работа с видео:

```dart
_getVideo()       // Запись/выбор видео
_initializeVideoPlayer() // Инициализация видеоплеера
_saveVideo()      // Сохранение видео файла
```

10 дополнительных фильтров для фото:

1. чёрно-белый,
2. сепия,
3. негатив,
4. размытие,
5. яркость+,
6. яркость-,
7. контраст+,
8. оттенки синего,
9. оттенки красного,
10. пикселизация.

```dart
final Map<String, img.Image Function(img.Image)> _filters = {
  'Оригинал': (image) => image,
  'Черно-белый': (image) => img.grayscale(image),
  'Сепия': (image) => img.sepia(image),
  'Негатив': (image) => img.invert(image),
  'Размытие': (image) => img.gaussianBlur(image, radius: 10),
  'Яркость+': (image) => img.adjustColor(image, brightness: 1.5),
  'Яркость-': (image) => img.adjustColor(image, brightness: 0.7),
  'Контраст+': (image) => img.adjustColor(image, contrast: 1.5),
  'Оттенки синего': (image) => img.colorOffset(image, blue: 50),
  'Оттенки красного': (image) => img.colorOffset(image, red: 50),
  'Пикселизация': (image) {
    final small = img.copyResize(image, width: 32);
    return img.copyResize(
      small,
      width: image.width,
      interpolation: img.Interpolation.nearest,
    );
  },
};
```

#### Демонстрация работы приложения:

1. Скриншот главного экрана

<img width="350" height="1431" alt="image" src="https://github.com/user-attachments/assets/7184891a-eb13-40b1-b885-037d68e0d96b" />

2. Создание фото, применение фильтра и сохранение (GIF):

![CreatePhoto1](https://github.com/user-attachments/assets/a5d913cf-b3e8-4500-b529-4ff9a76b50f0)

3. Выбор фото из галереи, применение фильтров и сохранение (GIF):

![GalleryPhoto](https://github.com/user-attachments/assets/1d8d9985-8e6f-48d7-9ca0-6b62d0ea3339)

4. Создание видео, воспроизведение и сохранение:

![CreateVideo](./video/CreateVideo.mp4)

5. Выбор видео из галереи, воспроизведение и сохранение:

![GalleryVideo](./video/GalleryVideo.mp4)

#### Вывод:

Готовое приложение представляет собой многофункциональный медиаплеер, успешно объединяющий работу с фотографиями и видео в едином интерфейсе. Оно обеспечивает полный цикл обработки контента: от захвата через камеру или выбора из галереи до сохранения на устройстве. Для фотографий реализована палитра из 11 фильтров (считая оригинал), включая черно-белые преобразования, цветокоррекцию и художественные эффекты. Видеофункционал позволяет не только записывать и выбирать ролики, но и воспроизводить их непосредственно в приложении с полноценным плеером и элементами управления. Интуитивный интерфейс с цветовым кодированием кнопок и простой группировкой элементов делает навигацию лёгкой и понятной для пользователя.

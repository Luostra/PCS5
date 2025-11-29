import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

void main() => runApp(const CameraApp());

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

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _image;
  File? _video;
  File? _originalImage;
  final picker = ImagePicker();

  String _currentFilter = 'Оригинал';
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoPlaying = false;

  // Доступные фильтры
  final Map<String, img.Image Function(img.Image)> _filters = {
    'Оригинал': (image) => image,
    'Черно-белый': (image) => img.grayscale(image),
    'Сепия': (image) => img.sepia(image),
    'Инверсия': (image) => img.invert(image),
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    await Permission.camera.request();
    await Permission.photos.request();
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> _getImage(ImageSource source) async {
    await _checkPermissions();
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      _stopVideo(); // Останавливаем видео при выборе нового изображения
      setState(() {
        _originalImage = File(pickedFile.path);
        _image = _originalImage;
        _video = null;
        _currentFilter = 'Оригинал';
      });
    }
  }

  Future<void> _getVideo(ImageSource source) async {
    await _checkPermissions();
    final XFile? pickedFile = await picker.pickVideo(source: source);
    if (pickedFile != null) {
      _stopVideo(); // Останавливаем предыдущее видео
      setState(() {
        _video = File(pickedFile.path);
        _image = null;
        _originalImage = null;
      });
      _initializeVideoPlayer(_video!);
    }
  }

  Future<void> _initializeVideoPlayer(File videoFile) async {
    _videoController?.dispose();
    _chewieController?.dispose();

    _videoController = VideoPlayerController.file(videoFile);
    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.blue,
        handleColor: Colors.blue,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey.withOpacity(0.5),
      ),
    );

    setState(() {
      _isVideoPlaying = true;
    });
  }

  void _stopVideo() {
    _videoController?.pause();
    _chewieController?.pause();
    setState(() {
      _isVideoPlaying = false;
    });
  }

  Future<void> _applyFilter(String filterName) async {
    if (_originalImage == null) return;

    setState(() {
      _currentFilter = filterName;
    });

    if (filterName == 'Оригинал') {
      setState(() {
        _image = _originalImage;
      });
      return;
    }

    final bytes = await _originalImage!.readAsBytes();
    final originalImage = img.decodeImage(bytes);

    if (originalImage != null) {
      final processedImage = await _processImageInBackground(
        originalImage,
        _filters[filterName]!,
      );

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(img.encodeJpg(processedImage));

      setState(() {
        _image = tempFile;
      });
    }
  }

  Future<img.Image> _processImageInBackground(
    img.Image image,
    img.Image Function(img.Image) filter,
  ) async {
    return filter(image);
  }

  Future<void> _saveImage() async {
    if (_image == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final newFile = await _image!.copy(
      '${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Фото сохранено: ${newFile.path}')));
  }

  Future<void> _saveVideo() async {
    if (_video == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final newFile = await _video!.copy(
      '${dir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Видео сохранено: ${newFile.path}')));
  }

  Widget _buildMediaPreview() {
    if (_image != null) {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _image!,
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Фильтр: $_currentFilter',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      );
    } else if (_video != null && _chewieController != null) {
      return Column(
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Chewie(controller: _chewieController!),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Видео: ${_video!.path.split('/').last}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text('Файл не выбран'),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Отображение медиа
              _buildMediaPreview(),

              const SizedBox(height: 20),

              // Кнопки для фото
              const Text(
                'Фотографии:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _getImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Сделать фото'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _getImage(ImageSource.gallery),
                    icon: const Icon(Icons.image),
                    label: const Text('Галерея'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Кнопки для видео
              const Text(
                'Видео:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _getVideo(ImageSource.camera),
                    icon: const Icon(Icons.videocam),
                    label: const Text('Снять видео'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _getVideo(ImageSource.gallery),
                    icon: const Icon(Icons.video_library),
                    label: const Text('Галерея'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Фильтры (только для фото)
              if (_image != null) ...[
                const Text(
                  'Фильтры:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _filters.keys.map((filterName) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(filterName),
                          selected: _currentFilter == filterName,
                          onSelected: (selected) => _applyFilter(filterName),
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.blue[200],
                          checkmarkColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: _currentFilter == filterName
                                ? Colors.blue
                                : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),
              ],

              // Кнопки сохранения
              if (_image != null || _video != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_image != null)
                      ElevatedButton.icon(
                        onPressed: _saveImage,
                        icon: const Icon(Icons.save),
                        label: const Text('Сохранить фото'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    if (_video != null) ...[
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _saveVideo,
                        icon: const Icon(Icons.save_alt),
                        label: const Text('Сохранить видео'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

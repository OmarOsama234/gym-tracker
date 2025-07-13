import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PhotoService extends ChangeNotifier {
  static final PhotoService _instance = PhotoService._internal();
  factory PhotoService() => _instance;
  PhotoService._internal();

  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _errorMessage;

  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  Future<String?> pickAndSaveImage({
    required ImageSource source,
    required String category, // 'profile', 'post', 'machine', 'gym'
    String? userId,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image == null) {
        _isUploading = false;
        notifyListeners();
        return null;
      }

      final savedPath = await _saveImageToLocal(image, category, userId);
      return savedPath;
    } catch (e) {
      _errorMessage = 'Failed to pick image: ${e.toString()}';
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<List<String>> pickMultipleImages({
    required String category,
    String? userId,
    int maxImages = 5,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (images.isEmpty) {
        _isUploading = false;
        notifyListeners();
        return [];
      }

      final List<String> savedPaths = [];
      final imagesToProcess = images.take(maxImages).toList();

      for (final image in imagesToProcess) {
        final savedPath = await _saveImageToLocal(image, category, userId);
        if (savedPath != null) {
          savedPaths.add(savedPath);
        }
      }

      return savedPaths;
    } catch (e) {
      _errorMessage = 'Failed to pick images: ${e.toString()}';
      return [];
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<String?> _saveImageToLocal(XFile image, String category, String? userId) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String categoryDir = '${appDir.path}/images/$category';
      
      // Create directory if it doesn't exist
      final Directory dir = Directory(categoryDir);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      // Generate unique filename
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '${userId ?? 'unknown'}_${timestamp}_${image.name}';
      final String filePath = '$categoryDir/$fileName';

      // Copy file to local directory
      final File imageFile = File(image.path);
      await imageFile.copy(filePath);

      // Save path to Hive for reference
      await _saveImagePath(filePath, category, userId);

      return filePath;
    } catch (e) {
      _errorMessage = 'Failed to save image: ${e.toString()}';
      return null;
    }
  }

  Future<void> _saveImagePath(String path, String category, String? userId) async {
    try {
      final box = await Hive.openBox<String>('image_paths');
      final key = '${category}_${userId ?? 'unknown'}_${DateTime.now().millisecondsSinceEpoch}';
      await box.put(key, path);
    } catch (e) {
      // Non-critical error, just log it
      print('Failed to save image path reference: $e');
    }
  }

  Future<List<String>> getImagesByCategory(String category, {String? userId}) async {
    try {
      final box = await Hive.openBox<String>('image_paths');
      final List<String> images = [];
      
      for (final key in box.keys) {
        if (key.toString().startsWith(category)) {
          if (userId == null || key.toString().contains(userId)) {
            final path = box.get(key);
            if (path != null && File(path).existsSync()) {
              images.add(path);
            }
          }
        }
      }
      
      return images;
    } catch (e) {
      _errorMessage = 'Failed to load images: ${e.toString()}';
      return [];
    }
  }

  Future<void> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (imageFile.existsSync()) {
        await imageFile.delete();
      }

      // Remove from Hive
      final box = await Hive.openBox<String>('image_paths');
      String? keyToRemove;
      
      for (final key in box.keys) {
        if (box.get(key) == imagePath) {
          keyToRemove = key.toString();
          break;
        }
      }
      
      if (keyToRemove != null) {
        await box.delete(keyToRemove);
      }
    } catch (e) {
      _errorMessage = 'Failed to delete image: ${e.toString()}';
    }
  }

  Future<void> clearAllImages() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = '${appDir.path}/images';
      
      final Directory dir = Directory(imagesDir);
      if (dir.existsSync()) {
        await dir.delete(recursive: true);
      }

      // Clear Hive references
      final box = await Hive.openBox<String>('image_paths');
      await box.clear();
    } catch (e) {
      _errorMessage = 'Failed to clear images: ${e.toString()}';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper method to show image picker options
  Future<String?> showImagePickerOptions(BuildContext context, {
    required String category,
    String? userId,
  }) async {
    return await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePath = await pickAndSaveImage(
                    source: ImageSource.camera,
                    category: category,
                    userId: userId,
                  );
                  if (context.mounted) {
                    Navigator.pop(context, imagePath);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePath = await pickAndSaveImage(
                    source: ImageSource.gallery,
                    category: category,
                    userId: userId,
                  );
                  if (context.mounted) {
                    Navigator.pop(context, imagePath);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
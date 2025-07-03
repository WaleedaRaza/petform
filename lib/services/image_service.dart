import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      // Add a small delay to ensure the picker is ready
      await Future.delayed(const Duration(milliseconds: 100));
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  // Take photo with camera
  static Future<File?> takePhotoWithCamera() async {
    try {
      // Add a small delay to ensure the picker is ready
      await Future.delayed(const Duration(milliseconds: 100));
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      debugPrint('Error taking photo with camera: $e');
      return null;
    }
  }

  // Save image to local storage and return the path
  static Future<String?> saveImageLocally(File imageFile, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${directory.path}/images');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      
      final savedFile = await imageFile.copy('${imageDir.path}/$fileName');
      return savedFile.path;
    } catch (e) {
      debugPrint('Error saving image locally: $e');
      return null;
    }
  }

  // Convert image to base64 for storage in SharedPreferences
  static Future<String?> imageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
      return null;
    }
  }

  // Convert base64 to image bytes
  static Uint8List? base64ToImageBytes(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      debugPrint('Error converting base64 to image bytes: $e');
      return null;
    }
  }

  // Save image as base64 to SharedPreferences
  static Future<bool> saveImageAsBase64(String key, File imageFile) async {
    try {
      final base64 = await imageToBase64(imageFile);
      if (base64 != null) {
        final prefs = await SharedPreferences.getInstance();
        return await prefs.setString(key, base64);
      }
      return false;
    } catch (e) {
      debugPrint('Error saving image as base64: $e');
      return false;
    }
  }

  // Get image from SharedPreferences
  static Future<Uint8List?> getImageFromBase64(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64 = prefs.getString(key);
      if (base64 != null) {
        return base64ToImageBytes(base64);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting image from base64: $e');
      return null;
    }
  }

  // Delete image from SharedPreferences
  static Future<bool> deleteImage(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(key);
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  // Show image picker dialog
  static Future<File?> showImagePickerDialog(BuildContext context) async {
    return showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    final image = await pickImageFromGallery();
                    if (image != null) {
                      Navigator.of(context).pop(image);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to pick image from gallery')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    final image = await takePhotoWithCamera();
                    if (image != null) {
                      Navigator.of(context).pop(image);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to take photo')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Simple image picker without dialog (more reliable)
  static Future<File?> pickImageSimple(BuildContext context) async {
    try {
      final result = await showModalBottomSheet<File?>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Photo Library'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Future.delayed(const Duration(milliseconds: 300));
                    final image = await pickImageFromGallery();
                    if (image != null) {
                      Navigator.pop(context, image);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Future.delayed(const Duration(milliseconds: 300));
                    final image = await takePhotoWithCamera();
                    if (image != null) {
                      Navigator.pop(context, image);
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
      return result;
    } catch (e) {
      debugPrint('Error in pickImageSimple: $e');
      // Fallback to direct picker if modal fails
      return await _fallbackImagePicker(context);
    }
  }

  // Fallback image picker method
  static Future<File?> _fallbackImagePicker(BuildContext context) async {
    try {
      // Try gallery first
      final galleryImage = await pickImageFromGallery();
      if (galleryImage != null) return galleryImage;
      
      // If gallery fails, try camera
      return await takePhotoWithCamera();
    } catch (e) {
      debugPrint('Error in fallback image picker: $e');
      return null;
    }
  }
} 
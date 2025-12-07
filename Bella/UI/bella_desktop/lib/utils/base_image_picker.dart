import 'dart:convert';
import 'package:flutter/material.dart';

// Orange color scheme matching the app
const Color _orangePrimary = Color(0xFFFF8C42);
const Color _orangeDark = Color(0xFFFF6B1A);

/// A reusable image picker widget that matches the app's design language
/// 
/// This widget provides a consistent way to display, select, and clear images
/// with the orange gradient theme and modern styling.
class BaseImagePicker extends StatelessWidget {
  /// The base64 encoded image string (or null if no image)
  final String? base64Image;
  
  /// Callback when image is selected
  final VoidCallback onSelectImage;
  
  /// Callback when image is cleared
  final VoidCallback onClearImage;
  
  /// Size of the image preview (default: 200)
  /// Used when width or height are not specified
  final double imageSize;
  
  /// Optional width of the image container
  /// If null, uses imageSize
  final double? width;
  
  /// Optional height of the image container
  /// If null, uses imageSize
  final double? height;
  
  /// Label text above the image (default: "Profile Picture")
  final String label;
  
  /// Icon to show in placeholder (default: Icons.person)
  final IconData placeholderIcon;
  
  /// Whether to show the clear button (default: true)
  final bool showClearButton;

  const BaseImagePicker({
    super.key,
    required this.base64Image,
    required this.onSelectImage,
    required this.onClearImage,
    this.imageSize = 200,
    this.width,
    this.height,
    this.label = "Profile Picture",
    this.placeholderIcon = Icons.person,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final containerWidth = width ?? imageSize;
    final containerHeight = height ?? imageSize;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: containerWidth,
            height: containerHeight,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: _buildImageContent(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _orangePrimary,
                      _orangeDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _orangePrimary.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: onSelectImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Select Image"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            if (showClearButton) ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onClearImage,
                  icon: const Icon(Icons.clear),
                  label: const Text("Clear Image"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 162, 159, 159),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (base64Image != null && base64Image!.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            base64Decode(base64Image!),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          ),
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          placeholderIcon,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        const Text(
          "No profile picture",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        const Text(
          textAlign: TextAlign.center,
          "Click 'Select Image' to add a profile picture",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}


import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;

class ProjectDetail extends StatelessWidget {
  final Map<String, dynamic> project;

  const ProjectDetail({Key? key, required this.project}) : super(key: key);

  void _showFullScreenImage(BuildContext context, dynamic image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: _buildProjectImage(image, fullScreen: true),
        ),
      ),
    );
  }

  Widget _buildProjectImage(dynamic image, {bool fullScreen = false}) {
    if (image is Uint8List) {
      return Image.memory(
        image,
        width: fullScreen ? double.infinity : 100,
        height: fullScreen ? double.infinity : 100,
        fit: fullScreen ? BoxFit.contain : BoxFit.cover,
      );
    } else if (image is String && image.isNotEmpty) {
      // For mobile, assume the image is a file path
      if (!kIsWeb) {
        try {
          return Image.file(
            io.File(image),
            width: fullScreen ? double.infinity : 100,
            height: fullScreen ? double.infinity : 100,
            fit: fullScreen ? BoxFit.contain : BoxFit.cover,
          );
        } catch (e) {
          return const Icon(Icons.image_not_supported, size: 100);
        }
      }
      // For web, assume the image is a base64 encoded string
      else {
        try {
          Uint8List decodedImage = base64Decode(image);
          return Image.memory(
            decodedImage,
            width: fullScreen ? double.infinity : 100,
            height: fullScreen ? double.infinity : 100,
            fit: fullScreen ? BoxFit.contain : BoxFit.cover,
          );
        } catch (e) {
          return const Icon(Icons.image_not_supported, size: 100);
        }
      }
    } else {
      return const Icon(Icons.image, size: 100); // Default icon size
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(project['title'] ?? 'Project Detail'),
        backgroundColor: const Color(0xFF3FBFBF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project['title'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3FBFBF),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              project['description'] ?? 'No Description',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Text(
              'Deadline: ${project['deadline'] ?? 'No Deadline'}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                _showFullScreenImage(context, project['image']);
              },
              child: Center(
                child: Container(
                  width: screenWidth, // Full screen width
                  height: 100, // Fixed height
                  child: project['image'] != null
                      ? _buildProjectImage(project['image'])
                      : const Icon(Icons.image, size: 100),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

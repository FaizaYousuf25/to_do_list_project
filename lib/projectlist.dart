import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'dart:typed_data';

import 'package:to_do_list_project/saveproject.dart';

import 'ProjectDetail.dart';


Uint8List decodeBase64(String base64String) {
  return base64Decode(base64String);
}

class ProjectList extends StatefulWidget {
  const ProjectList({super.key});

  @override
  _ProjectListState createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  List<Map<String, dynamic>> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? projectsString = prefs.getString('projects');

    if (projectsString != null) {
      try {
        List<dynamic> projectsList = jsonDecode(projectsString);

        _projects = projectsList.map((dynamic project) {
          if (project is Map<String, dynamic>) {
            // Ensure proper handling of the project map
            Map<String, dynamic> projectMap = Map<String, dynamic>.from(project);

            if (kIsWeb && projectMap['image'] is String) {
              projectMap['image'] = decodeBase64(projectMap['image']);
            } else if (projectMap['image'] is String) {
              // Handle file paths or URLs for mobile
              projectMap['image'] = projectMap['image']; // Placeholder for file handling
            }
            return projectMap;
          }
          return {}; // Fallback in case of unexpected data format
        }).toList().cast<Map<String, dynamic>>(); // Cast to the expected type
      } catch (e) {
        // Handle JSON decode errors
        print('Error decoding projects: $e');
      }
      setState(() {});
    }
  }

  Future<void> _saveProjects() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonProjects = jsonEncode(_projects);
    await prefs.setString('projects', jsonProjects);
  }

  Future<void> _navigateToSaveProject([Map<String, dynamic>? project]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaveProject(project: project),
      ),
    );

    if (result != null) {
      setState(() {
        if (project != null) {
          int index = _projects.indexOf(project);
          if (index != -1) {
            _projects[index] = result;
          }
        } else {
          _projects.add(result);
        }
        _saveProjects();
      });
    }
  }

  void _deleteProject(Map<String, dynamic> project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/BIN.png', // Path to your image
              height: 100,        // Adjust size as needed
              width: 100,
            ),
            const SizedBox(height: 20), // Space between image and text
            const Text('Are you sure you want to delete this project?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _projects.remove(project);
                _saveProjects();
                Navigator.pop(context);
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  Widget _buildProjectImage(dynamic image) {
    if (image is Uint8List) {
      return Image.memory(
        image,
        width: 50,  // Set width to make it small like a logo
        height: 50, // Set height as well
        fit: BoxFit.cover,
      );
    } else if (image is String && image.isNotEmpty) {
      // For mobile, assume the image is a file path
      if (!kIsWeb) {
        return Image.file(
          File(image),
          width: 50,  // Set width to make it small like a logo
          height: 50, // Set height as well
          fit: BoxFit.cover,
        );
      }
      // For web, assume the image is a base64 encoded string
      else {
        try {
          Uint8List decodedImage = base64Decode(image);
          return Image.memory(
            decodedImage,
            width: 50,  // Set width to make it small like a logo
            height: 50, // Set height as well
            fit: BoxFit.cover,
          );
        } catch (e) {
          return const Icon(Icons.image_not_supported, size: 50);
        }
      }
    } else {
      return const Icon(Icons.image, size: 50); // Default icon size 50
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/ellipse.png',
              width: 150,
              height: 150,
            ),
          ),
          Positioned(
            top: 54,
            left: 10,
            child: IconButton(
              icon: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.arrow_back,
                  color: Color(0xFF3FBFBF),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 54,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Project List',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3FBFBF),
                ),
              ),
            ),
          ),
          Positioned(
            top: 130,
            left: 45,
            right: 45,
            bottom: 120,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                final project = _projects[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetail(project: project),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // Ensure alignment at the top
                      children: [
                        // Image container
                        _buildProjectImage(project['image']),

                        // Space between image and content
                        const SizedBox(width: 16),

                        // Expanded column to prevent overflow
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Project title
                              Text(
                                project['title'] ?? 'No Title',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3FBFBF),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis, // Prevent overflow
                              ),

                              // Space between title and description
                              const SizedBox(height: 4),

                              // Project description
                              Text(
                                project['description'] ?? 'No Description',
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis, // Prevent overflow
                              ),

                              // Space between description and deadline
                              const SizedBox(height: 8),

                              // Deadline text
                              Text(
                                'Deadline: ${project['deadline'] ?? 'No Deadline'}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                        // Edit and Delete buttons with flexible width
                        Row(
                          mainAxisSize: MainAxisSize.min, // Ensure it doesn't take too much space
                          children: [
                            // Edit button
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _navigateToSaveProject(project),
                            ),

                            // Delete button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProject(project),
                            ),
                          ],
                        ),
                      ],
                    ),

                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () => _navigateToSaveProject(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3FBFBF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "New Project",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 40),
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF3FBFBF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

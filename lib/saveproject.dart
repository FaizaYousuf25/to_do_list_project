import 'dart:convert'; // For base64 encoding
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SaveProject extends StatefulWidget {
  const SaveProject({super.key, this.project});

  final Map<String, dynamic>? project;

  @override
  _SaveProjectState createState() => _SaveProjectState();
}

class _SaveProjectState extends State<SaveProject> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();

  io.File? _image; // For mobile
  Uint8List? _webImage; // For web

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      final project = widget.project!;
      _titleController.text = project['title'] ?? '';
      _descriptionController.text = project['description'] ?? '';
      _deadlineController.text = project['deadline'] ?? '';

      if (kIsWeb) {
        _webImage = project['image'] != null ? base64Decode(project['image']) : null;
      } else {
        _image = project['image'] != null ? io.File(project['image']) : null;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      if (kIsWeb) {
        final bytes = await pickedImage.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        setState(() {
          _image = io.File(pickedImage.path);
        });
      }
    }
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _deadlineController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void _deleteImage() {
    setState(() {
      _image = null;
      _webImage = null;
    });
  }

  void _submitProject() {
    String title = _titleController.text;
    String description = _descriptionController.text;
    String deadline = _deadlineController.text;

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    String? imageString;
    if (kIsWeb && _webImage != null) {
      imageString = base64Encode(_webImage!);
    } else if (_image != null) {
      imageString = _image!.path;
    }

    final project = {
      'title': title,
      'description': description,
      'deadline': deadline,
      'image': imageString,
    };

    Navigator.pop(context, project);
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
          const Positioned(
            top: 54,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'To-Do List',
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
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3FBFBF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: const TextStyle(color: Colors.white),
                            filled: false,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Description',
                            hintStyle: const TextStyle(color: Colors.white),
                            filled: false,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => _selectDeadline(context),
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _deadlineController,
                              decoration: InputDecoration(
                                hintText: 'Deadline (Optional)',
                                hintStyle: const TextStyle(color: Colors.white),
                                filled: false,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.white, width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.white, width: 2),
                                ),
                                suffixIcon: _deadlineController.text.isNotEmpty
                                    ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _deadlineController.clear();
                                    });
                                  },
                                )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: _pickImage,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            backgroundColor: const Color(0xFF3FBFBF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (kIsWeb ? _webImage != null : _image != null) ...[
                                Stack(
                                  children: [
                                    kIsWeb
                                        ? Image.memory(_webImage!, height: 50, width: 50, fit: BoxFit.cover)
                                        : Image.file(_image!, height: 50, width: 50, fit: BoxFit.cover),
                                    Positioned(
                                      right: -10,
                                      top: -10,
                                      child: IconButton(
                                        icon: const Icon(Icons.cancel, color: Colors.red, size: 24),
                                        onPressed: _deleteImage,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else
                                const Text('Add Image', style: TextStyle(color: Colors.white)),
                              const Icon(Icons.image, color: Colors.white),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child:  ElevatedButton(
                onPressed: _submitProject,
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
                      "Save Project",
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

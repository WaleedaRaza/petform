import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../services/image_service.dart';
import '../providers/user_provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/rounded_button.dart';
import '../models/pet_types.dart';
import '../models/post.dart';

class CreatePostScreen extends StatefulWidget {
  final Post? postToEdit; // For editing existing posts
  
  const CreatePostScreen({super.key, this.postToEdit});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedPetType = 'Dog';
  final List<String> _petTypes = ['All', ...petTypes];
  bool _isLoading = false;
  File? _selectedImage;
  String? _imageBase64;

  @override
  void initState() {
    super.initState();
    if (widget.postToEdit != null) {
      // Edit mode - populate fields
      _titleController.text = widget.postToEdit!.title;
      _contentController.text = widget.postToEdit!.content;
      _selectedPetType = widget.postToEdit!.petType;
      // Note: We don't load the image here as it would be a URL, not a file
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImageService.pickImageSimple(context);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
      // Convert to base64 for storage
      final base64 = await ImageService.imageToBase64(image);
      if (base64 != null) {
        _imageBase64 = base64;
      }
    }
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        
        if (widget.postToEdit != null) {
          // Edit existing post
          await appState.updatePost(
            postId: widget.postToEdit!.id!,
            title: _titleController.text,
            content: _contentController.text,
            petType: _selectedPetType,
            imageBase64: _imageBase64,
          );
        } else {
          // Create new post
          await Provider.of<ApiService>(context, listen: false).createPost(
            title: _titleController.text,
            content: _contentController.text,
            petType: _selectedPetType,
            author: userProvider.email ?? 'Anonymous',
            imageBase64: _imageBase64,
          );
        }
        
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to ${widget.postToEdit != null ? 'update' : 'create'} post: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/assets/petform_backdrop.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.postToEdit != null ? 'Edit Post' : 'Create Post'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedPetType,
                  decoration: const InputDecoration(
                    labelText: 'Pet Type',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _petTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPetType = value!;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a pet type' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 5,
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Please enter content' : null,
                ),
                const SizedBox(height: 16),
                
                // Image upload section
                Card(
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.image, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text(
                              'Add Photo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_selectedImage != null) ...[
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.add_photo_alternate),
                              label: Text(_selectedImage != null ? 'Change Photo' : 'Add Photo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            if (_selectedImage != null) ...[
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                    _imageBase64 = null;
                                  });
                                },
                                icon: const Icon(Icons.delete),
                                label: const Text('Remove'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RoundedButton(
                        text: widget.postToEdit != null ? 'Update Post' : 'Submit Post',
                        onPressed: _submitPost,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
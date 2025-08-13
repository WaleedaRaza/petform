import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/rounded_button.dart';
import '../widgets/video_background.dart';
import '../models/pet_types.dart';
import '../models/post.dart';
import '../services/supabase_auth_service.dart';
import '../services/supabase_service.dart';

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

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final userEmail = SupabaseAuthService().currentUser?.email ?? 'Anonymous';
        final username = userProvider.currentUsername ?? userEmail.split('@')[0];

        if (widget.postToEdit != null && widget.postToEdit!.id != null) {
          // Edit existing post
          await SupabaseService.updatePost(widget.postToEdit!.id!, {
            'title': _titleController.text,
            'content': _contentController.text,
            'pet_type': _selectedPetType,
            'author': username,
            'post_type': 'community',
            'updated_at': DateTime.now().toIso8601String(),
          });
        } else {
          // Create new post
          await SupabaseService.createPost({
            'title': _titleController.text,
            'content': _contentController.text,
            'pet_type': _selectedPetType,
            'author': username,
            'post_type': 'community',
          });
        }
        
        // Refresh the feed to show the new post
        final feedProvider = Provider.of<FeedProvider>(context, listen: false);
        await feedProvider.fetchPosts(context);
        
        if (!mounted) return;
        Navigator.pop(context, true); // Return true to indicate post was created
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
    return VideoBackground(
      videoPath: 'lib/assets/animation2.mp4',
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
                  decoration: InputDecoration(
                  labelText: 'Pet Type',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                  filled: true,
                    fillColor: Colors.grey[800],
                ),
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
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
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                  labelText: 'Title',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                  filled: true,
                    fillColor: Colors.grey[800],
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                  labelText: 'Content',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                  filled: true,
                    fillColor: Colors.grey[800],
                ),
                maxLines: 5,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter content' : null,
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
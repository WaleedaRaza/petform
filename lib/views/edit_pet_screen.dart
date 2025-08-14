import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/pet.dart';
import '../providers/app_state_provider.dart';
import '../services/image_service.dart';
import '../widgets/rounded_button.dart';
import '../widgets/video_background.dart';
import '../models/pet_types.dart';

class EditPetScreen extends StatefulWidget {
  final Pet pet;
  
  const EditPetScreen({super.key, required this.pet});

  @override
  _EditPetScreenState createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPetType = '';
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _breedController = TextEditingController();
  final _personalityController = TextEditingController();
  final _foodSourceController = TextEditingController();
  final Map<String, TextEditingController> _additionalFieldControllers = {};
  final List<MapEntry<String, TextEditingController>> _customFields = [];
  File? _selectedImage;
  String? _imageBase64;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with existing pet data
    _selectedPetType = widget.pet.species;
    _nameController.text = widget.pet.name;
    _ageController.text = widget.pet.age?.toString() ?? '';
    _breedController.text = widget.pet.breed ?? '';
    _personalityController.text = widget.pet.personality ?? '';
    _foodSourceController.text = widget.pet.foodSource ?? '';
    
    // Initialize additional field controllers
    petFields.forEach((petType, fields) {
      for (var field in fields) {
        _additionalFieldControllers['$petType-$field'] = TextEditingController();
      }
    });
    
    // Populate additional fields with existing data
    if (widget.pet.favoritePark != null) {
      _additionalFieldControllers['${widget.pet.species}-Favorite Park']?.text = widget.pet.favoritePark!;
    }
    if (widget.pet.leashSource != null) {
      _additionalFieldControllers['${widget.pet.species}-Leash Source']?.text = widget.pet.leashSource!;
    }
    if (widget.pet.litterType != null) {
      _additionalFieldControllers['${widget.pet.species}-Litter Type']?.text = widget.pet.litterType!;
    }
    if (widget.pet.waterProducts != null) {
      _additionalFieldControllers['${widget.pet.species}-Water Products']?.text = widget.pet.waterProducts!;
    }
    if (widget.pet.tankSize != null) {
      _additionalFieldControllers['${widget.pet.species}-Tank Size']?.text = widget.pet.tankSize!;
    }
    if (widget.pet.cageSize != null) {
      _additionalFieldControllers['${widget.pet.species}-Cage Size']?.text = widget.pet.cageSize!;
    }
    if (widget.pet.favoriteToy != null) {
      _additionalFieldControllers['${widget.pet.species}-Favorite Toy']?.text = widget.pet.favoriteToy!;
    }
    
    // Initialize custom fields
    if (widget.pet.customFields != null) {
      for (var entry in widget.pet.customFields!.entries) {
        final controller = TextEditingController(text: entry.value);
        _customFields.add(MapEntry(entry.key, controller));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _breedController.dispose();
    _personalityController.dispose();
    _foodSourceController.dispose();
    _additionalFieldControllers.forEach((key, controller) => controller.dispose());
    for (var entry in _customFields) {
      entry.value.dispose();
    }
    super.dispose();
  }

  void _addCustomField() {
    setState(() {
      final controller = TextEditingController();
      _customFields.add(MapEntry('Custom Field ${_customFields.length + 1}', controller));
    });
  }

  Future<void> _pickImage() async {
    final image = await ImageService.showImagePickerDialog(context);
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final additionalFields = <String, String>{};
        for (var field in petFields[_selectedPetType] ?? []) {
          additionalFields[field] = _additionalFieldControllers['$_selectedPetType-$field']?.text ?? '';
        }
        final customFields = <String, String>{};
        for (var entry in _customFields) {
          if (entry.value.text.trim().isNotEmpty) {
            customFields[entry.key] = entry.value.text;
          }
        }

        final updatedPet = Pet(
          id: widget.pet.id,
          name: _nameController.text,
          species: _selectedPetType,
          breed: _breedController.text.isNotEmpty ? _breedController.text : null,
          age: int.tryParse(_ageController.text),
          personality: _personalityController.text.isNotEmpty ? _personalityController.text : null,
          foodSource: _foodSourceController.text.isNotEmpty ? _foodSourceController.text : null,
          favoritePark: additionalFields['Favorite Park'],
          leashSource: additionalFields['Leash Source'],
          litterType: additionalFields['Litter Type'],
          waterProducts: additionalFields['Water Products'],
          tankSize: additionalFields['Tank Size'],
          cageSize: additionalFields['Cage Size'],
          favoriteToy: additionalFields['Favorite Toy'],
          photoUrl: _imageBase64 != null ? 'data:image/jpeg;base64,$_imageBase64' : widget.pet.photoUrl,
          customFields: customFields,
          shoppingList: widget.pet.shoppingList,
          trackingMetrics: widget.pet.trackingMetrics,
        );

        final appState = Provider.of<AppStateProvider>(context, listen: false);
        await appState.updatePet(updatedPet.id!, updatedPet);
        if (!mounted) return;
        Navigator.pop(context, true); // Return true to indicate success
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update pet: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      videoPath: 'lib/assets/backdrop2.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Edit ${widget.pet.name}'),
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
                // Pet Photo Section
                Card(
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pet Photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey[300]!, width: 2),
                                color: Colors.grey[100],
                              ),
                              child: _selectedImage != null
                                  ? ClipOval(
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : widget.pet.photoUrl != null
                                      ? ClipOval(
                                          child: Image.network(
                                            widget.pet.photoUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(
                                              Icons.add_a_photo,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.add_a_photo,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: _pickImage,
                            child: Text(_selectedImage != null ? 'Change Photo' : 'Change Photo'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Form Fields
                Card(
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedPetType,
                          decoration: const InputDecoration(
                            labelText: 'Pet Type',
                            border: OutlineInputBorder(),
                          ),
                          items: petTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedPetType = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null) return 'Please select a pet type';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Please enter a name';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ageController,
                          decoration: const InputDecoration(
                            labelText: 'Age (Optional)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _breedController,
                          decoration: const InputDecoration(
                            labelText: 'Breed (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _personalityController,
                          decoration: const InputDecoration(
                            labelText: 'Personality (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _foodSourceController,
                          decoration: const InputDecoration(
                            labelText: 'Food Source (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (petFields[_selectedPetType] != null) ...[
                          const Text(
                            'Additional Information (Optional)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...(petFields[_selectedPetType] ?? []).map((field) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: TextFormField(
                                controller: _additionalFieldControllers['$_selectedPetType-$field'],
                                decoration: InputDecoration(
                                  labelText: field,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            );
                          }),
                        ],
                        const SizedBox(height: 16),
                        const Text(
                          'Custom Fields (Optional)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ..._customFields.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: TextFormField(
                              controller: entry.value,
                              decoration: InputDecoration(
                                labelText: entry.key,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          );
                        }),
                        TextButton(
                          onPressed: _addCustomField,
                          child: const Text('Add Custom Field'),
                        ),
                        const SizedBox(height: 16),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : RoundedButton(
                                text: 'Update Pet Profile',
                                onPressed: _submitForm,
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/pet.dart';
import '../providers/app_state_provider.dart';
import '../services/image_service.dart';
import '../widgets/rounded_button.dart';
import '../models/pet_types.dart';

class PetProfileCreationScreen extends StatefulWidget {
  const PetProfileCreationScreen({super.key});

  @override
  _PetProfileCreationScreenState createState() => _PetProfileCreationScreenState();
}

class _PetProfileCreationScreenState extends State<PetProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPetType = petTypes.first;
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _breedController = TextEditingController();
  final _personalityController = TextEditingController();
  final _foodSourceController = TextEditingController();
  final Map<String, TextEditingController> _additionalFieldControllers = {};
  final List<MapEntry<String, TextEditingController>> _customFields = [];
  File? _selectedImage;
  String? _imageBase64;

  @override
  void initState() {
    super.initState();
    petFields.forEach((petType, fields) {
      for (var field in fields) {
        _additionalFieldControllers['$petType-$field'] = TextEditingController();
      }
    });
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
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

      final pet = Pet(
        id: DateTime.now().millisecondsSinceEpoch,
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
        photoUrl: _imageBase64 != null ? 'data:image/jpeg;base64,$_imageBase64' : null,
        customFields: customFields,
        shoppingList: [],
      );

      try {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        await appState.addPet(pet);
        if (!mounted) return;
        Navigator.pop(context, true); // Return true to indicate success
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create pet: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Pet Profile')),
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
              
              // Pet Photo Section
              Card(
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
                          child: Text(_selectedImage != null ? 'Change Photo' : 'Add Photo'),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  )
                );
              }),
              TextButton(
                onPressed: _addCustomField,
                child: const Text('Add Custom Field'),
              ),
              const SizedBox(height: 16),
              RoundedButton(
                text: 'Create Pet Profile',
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../providers/app_state_provider.dart';
import '../widgets/rounded_button.dart';
import '../widgets/video_background.dart';
import '../models/pet_types.dart';
import 'home_screen.dart';

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
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        species: _selectedPetType,
        breed: _breedController.text.isNotEmpty ? _breedController.text : null,
        age: int.tryParse(_ageController.text), // This will be stored in customFields instead
        personality: _personalityController.text.isNotEmpty ? _personalityController.text : null,
        foodSource: _foodSourceController.text.isNotEmpty ? _foodSourceController.text : null,
        // Store all pet-specific fields in customFields since they don't exist in the database table
        favoritePark: null,
        leashSource: null,
        litterType: null,
        waterProducts: null,
        tankSize: null,
        cageSize: null,
        favoriteToy: null,
        photoUrl: null, // Remove photo functionality
        customFields: {
          ...customFields,
          'age': _ageController.text.isNotEmpty ? _ageController.text : null,
          'favoritePark': additionalFields['Favorite Park'],
          'leashSource': additionalFields['Leash Source'],
          'litterType': additionalFields['Litter Type'],
          'waterProducts': additionalFields['Water Products'],
          'tankSize': additionalFields['Tank Size'],
          'cageSize': additionalFields['Cage Size'],
          'favoriteToy': additionalFields['Favorite Toy'],
        },
        shoppingList: [],
      );

      try {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        await appState.addPet(pet);
        if (!mounted) return;
        // Navigate to home screen instead of going back
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
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
    return VideoBackground(
      videoPath: 'lib/assets/animation2.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Create Pet Profile'),
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
                Card(
                  color: Colors.grey[850]!.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedPetType,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Pet Type',
                            labelStyle: const TextStyle(color: Colors.white),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[700]!),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                            filled: true,
                            fillColor: Colors.grey[800],
                          ),
                          dropdownColor: Colors.grey[800],
                          items: petTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type, style: const TextStyle(color: Colors.white)),
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
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Pet Name',
                            labelStyle: const TextStyle(color: Colors.white),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[700]!),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                            filled: true,
                            fillColor: Colors.grey[800],
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a pet name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _ageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Age (years)',
                            labelStyle: const TextStyle(color: Colors.white),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[700]!),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                            filled: true,
                            fillColor: Colors.grey[800],
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _breedController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Breed',
                            labelStyle: const TextStyle(color: Colors.white),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[700]!),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                            filled: true,
                            fillColor: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _personalityController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Personality',
                            labelStyle: const TextStyle(color: Colors.white),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[700]!),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                            filled: true,
                            fillColor: Colors.grey[800],
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _foodSourceController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Food Source',
                            labelStyle: const TextStyle(color: Colors.white),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[700]!),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                            filled: true,
                            fillColor: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        RoundedButton(
                          text: 'Create Pet Profile',
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
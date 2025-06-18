import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../views/main_screen.dart';
import '../widgets/rounded_button.dart';

class PetProfileCreationScreen extends StatefulWidget {
  const PetProfileCreationScreen({super.key});

  @override
  _PetProfileCreationScreenState createState() => _PetProfileCreationScreenState();
}

class _PetProfileCreationScreenState extends State<PetProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPetType = 'Dog';
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final Map<String, TextEditingController> _additionalFieldControllers = {};

  final Map<String, List<String>> _petFields = {
    'Dog': ['Breed', 'Favorite Toy'],
    'Cat': ['Breed', 'Litter Type'],
    'Turtle': ['Species', 'Tank Size'],
    'Bird': ['Species', 'Cage Size'],
  };

  final List<String> _petTypes = ['Dog', 'Cat', 'Turtle', 'Bird'];

  @override
  void initState() {
    super.initState();
    // Initialize controllers for additional fields
    _petFields.forEach((petType, fields) {
      for (var field in fields) {
        _additionalFieldControllers['$petType-$field'] = TextEditingController();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _additionalFieldControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final additionalFields = <String, String>{};
      for (var field in _petFields[_selectedPetType] ?? []) {
        additionalFields[field] = _additionalFieldControllers['$_selectedPetType-$field']?.text ?? '';
      }

      final pet = Pet(
        name: _nameController.text,
        species: _selectedPetType,
        breed: additionalFields['Breed'],
        age: int.tryParse(_ageController.text),
        litterType: additionalFields['Litter Type'],
        tankSize: additionalFields['Tank Size'],
        cageSize: additionalFields['Cage Size'],
        favoriteToy: additionalFields['Favorite Toy'],
      );

      try {
        await Provider.of<ApiService>(context, listen: false).createPet(pet);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.setUser(userProvider.email!); // Refresh pets
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create pet')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Pet Profile'),
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
                ),
                items: _petTypes.map((String type) {
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
                  if (value == null) {
                    return 'Please select a pet type';
                  }
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
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
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
              if (_petFields[_selectedPetType] != null) ...[
                const Text(
                  'Additional Information (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...(_petFields[_selectedPetType] ?? []).map((field) {
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
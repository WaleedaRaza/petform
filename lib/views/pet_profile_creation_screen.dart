import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../models/tracking_metric.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import 'home_screen.dart';
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
  final _breedController = TextEditingController();
  final _personalityController = TextEditingController();
  final _foodSourceController = TextEditingController();
  final Map<String, TextEditingController> _additionalFieldControllers = {};
  final List<MapEntry<String, TextEditingController>> _customFields = [];

final Map<String, List<String>> _petFields = {
  'Dog': ['Favorite Park', 'Leash Source', 'Favorite Toy'],
  'Cat': ['Litter Type'],
  'Turtle': ['Tank Size', 'Water Products'],
  'Bird': ['Cage Size'],
  'Hamster': ['Cage Size', 'Wheel Type', 'Bedding Brand', 'Favorite Snack'],
  'Ferret': ['Play Tunnel Type', 'Litter Training', 'Diet Preference', 'Favorite Toy'],
  'Parrot': ['Cage Size', 'Favorite Word', 'Noise Level', 'Favorite Treat'],
  'Rabbit': ['Cage Size', 'Favorite Veggie', 'Litter Trained', 'Exercise Routine'],
  'Snake': ['Tank Size', 'Heating Source', 'Feeding Frequency', 'Handling Preference'],
  'Lizard': ['Tank Type', 'UVB Light Brand', 'Humidity Level', 'Feeding Schedule'],
  'Fish': ['Tank Size', 'Water Type', 'Filter Type', 'Feeding Schedule'],
  'Hedgehog': ['Wheel Type', 'Temperature Range', 'Hide Spot Type', 'Favorite Insect'],
  'Guinea Pig': ['Cage Liner Type', 'Pellet Brand', 'Veggie Routine', 'Social Needs'],
  'Chinchilla': ['Dust Bath Frequency', 'Cage Level Count', 'Favorite Chew Toy'],
  'Frog': ['Humidity Source', 'Tank Setup Type', 'Feeding Time'],
  'Tarantula': ['Enclosure Type', 'Humidity Level', 'Feeding Insects'],
  'Axolotl': ['Water Temp', 'Tank Decor', 'Feeding Schedule'],
  'Mouse': ['Wheel Type', 'Nest Material', 'Feeding Schedule'],
  'Chicken': ['Outdoor Time', 'Diet Type', 'Favorite Spot'],
  'Goat': ['Enclosure Size', 'Grazing Area', 'Milking Schedule'],
};

  final List<String> _petTypes = ['Dog', 'Cat', 'Turtle', 'Bird', 'Hamster', 'Ferret', 'Parrot', 'Rabbit', 'Snake', 'Lizard', 'Fish','Hedgehog', 'Guinea Pig', 'Chinchilla', 'Frog', 'Tarantula', 'Axolotl', 'Mouse', 'Chicken', 'Goat'];

  List<TrackingMetric> getDefaultMetrics(String petType) {
    switch (petType) {
      case 'Dog':
        return [
          TrackingMetric(name: 'Weight', frequency: 'Monthly'),
          TrackingMetric(name: 'Exercise', frequency: 'Daily'),
          TrackingMetric(name: 'Feeding', frequency: 'Daily'),
        ];
      case 'Cat':
        return [
          TrackingMetric(name: 'Weight', frequency: 'Monthly'),
          TrackingMetric(name: 'Litter Box', frequency: 'Daily'),
        ];
      case 'Turtle':
        return [
          TrackingMetric(name: 'Weight', frequency: 'Monthly'),
          TrackingMetric(name: 'Water Temperature', frequency: 'Daily'),
        ];
      case 'Bird':
        return [
          TrackingMetric(name: 'Weight', frequency: 'Monthly'),
          TrackingMetric(name: 'Flight Time', frequency: 'Daily'),
        ];
      default:
        return [
          TrackingMetric(name: 'Weight', frequency: 'Monthly'),
        ];
    }
  }

  @override
  void initState() {
    super.initState();
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
      for (var field in _petFields[_selectedPetType] ?? []) {
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
        customFields: customFields,
        shoppingList: [],
        trackingMetrics: getDefaultMetrics(_selectedPetType),
      );

      try {
        await Provider.of<ApiService>(context, listen: false).createPet(pet);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.setUser(userProvider.email!);
        if (!mounted) return;
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petform/providers/user_provider.dart';
import 'package:petform/views/feed_screen.dart';
import 'package:petform/views/tracking_screen.dart';
import 'package:petform/views/pet_detail_screen.dart';
import 'package:petform/widgets/rounded_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user.email}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: user.pets.length,
              itemBuilder: (context, index) {
                final pet = user.pets[index];
                return ListTile(
                  title: Text(pet.name),
                  subtitle: Text('${pet.species} - Age: ${pet.age ?? 'Unknown'}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetDetailScreen(pet: pet),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          RoundedButton(
            text: 'View Feed',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedScreen()));
            },
          ),
          RoundedButton(
            text: 'Track Metrics',
            onPressed: () {
              if (user.pets.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackingScreen(petId: user.pets.first.id.toString()),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please add a pet first')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
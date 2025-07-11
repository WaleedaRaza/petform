import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../models/pet.dart';
import '../models/tracking_metric.dart';
import '../widgets/video_background.dart';

import '../providers/app_state_provider.dart';

class AiMessage {
  final String text;
  final bool isUser;
  final String queryType;
  final DateTime timestamp;

  AiMessage({
    required this.text,
    required this.isUser,
    required this.queryType,
    required this.timestamp,
  });
}

class AiProvider with ChangeNotifier {
  String _selectedQueryType = 'general';
  List<AiMessage> _messages = [];
  bool _isLoading = false;
  Pet? _selectedPet;
  String _userInput = '';

  String get selectedQueryType => _selectedQueryType;
  List<AiMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  Pet? get selectedPet => _selectedPet;
  String get userInput => _userInput;

  void setQueryType(String queryType) {
    _selectedQueryType = queryType;
    notifyListeners();
  }

  void setSelectedPet(Pet? pet) {
    _selectedPet = pet;
    notifyListeners();
  }

  void setUserInput(String input) {
    _userInput = input;
    notifyListeners();
  }

  Future<void> sendMessage(String userInput, BuildContext? context) async {
    if (userInput.trim().isEmpty) return;

    _isLoading = true;
    notifyListeners();

    // Add user message
    final userMessage = AiMessage(
      text: userInput,
      isUser: true,
      queryType: _selectedQueryType,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);

    try {
      // Get app state for comprehensive context
      final appState = context != null 
          ? Provider.of<AppStateProvider>(context, listen: false)
          : null;
      
      // Get tracking metrics for selected pet
      List<TrackingMetric>? petMetrics;
      if (_selectedPet != null && appState != null) {
        petMetrics = appState.trackingMetrics
            .where((metric) => metric.petId == _selectedPet!.id.toString())
            .toList();
      }

      // Get AI response with comprehensive context
      final aiResponse = await AIService.sendMessage(
        userQuery: userInput,
        selectedPet: _selectedPet,
        allPets: appState?.pets,
        trackingMetrics: petMetrics,
        shoppingItems: appState?.shoppingItems,
        queryType: _selectedQueryType,
        context: context,
      );

      // Add AI response
      final aiMessage = AiMessage(
        text: aiResponse,
        isUser: false,
        queryType: _selectedQueryType,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMessage);
    } catch (e) {
      // Add error message
      final errorMessage = AiMessage(
        text: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        queryType: _selectedQueryType,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearChat() {
    _messages = [];
    notifyListeners();
  }

  // Quick action methods
  Future<void> getPersonalizedTips(BuildContext? context) async {
    if (_selectedPet == null) {
      _messages.add(AiMessage(
        text: 'Please select a pet first to get personalized tips.',
        isUser: false,
        queryType: 'tips',
        timestamp: DateTime.now(),
      ));
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final appState = context != null 
          ? Provider.of<AppStateProvider>(context, listen: false)
          : null;
      
      final petMetrics = appState?.trackingMetrics
          .where((metric) => metric.petId == _selectedPet!.id.toString())
          .toList();

      final tips = await AIService.getPersonalizedTips(
        pet: _selectedPet!,
        trackingMetrics: petMetrics,
        shoppingItems: appState?.shoppingItems,
      );
      
      final tipsText = tips.map((tip) => '• $tip').join('\n');
      
      _messages.add(AiMessage(
        text: '🐾 Personalized Care Tips for ${_selectedPet!.name}:\n\n$tipsText',
        isUser: false,
        queryType: 'tips',
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _messages.add(AiMessage(
        text: 'Unable to get tips right now. Please try again.',
        isUser: false,
        queryType: 'tips',
        timestamp: DateTime.now(),
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> testConnection() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AIService.testConnection();
      _messages.add(AiMessage(
        text: '🔧 Connection Test:\n\n$result',
        isUser: false,
        queryType: 'test',
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _messages.add(AiMessage(
        text: '🔧 Test failed: $e',
        isUser: false,
        queryType: 'test',
        timestamp: DateTime.now(),
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getEmergencyAdvice(String situation) async {
    _isLoading = true;
    notifyListeners();

    try {
      final advice = await AIService.getEmergencyAdvice(
        situation: situation,
        pet: _selectedPet,
      );
      
      _messages.add(AiMessage(
        text: '🚨 Emergency Advice:\n\n$advice',
        isUser: false,
        queryType: 'emergency',
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _messages.add(AiMessage(
        text: '🚨 If this is an emergency, please contact your veterinarian immediately or go to the nearest emergency animal hospital.',
        isUser: false,
        queryType: 'emergency',
        timestamp: DateTime.now(),
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getHealthAdvice(String question) async {
    if (_selectedPet == null) {
      _messages.add(AiMessage(
        text: 'Please select a pet first to get health advice.',
        isUser: false,
        queryType: 'health',
        timestamp: DateTime.now(),
      ));
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final appState = Provider.of<AppStateProvider>(navigatorKey.currentContext!, listen: false);
      
      final petMetrics = appState.trackingMetrics
          .where((metric) => metric.petId == _selectedPet!.id.toString())
          .toList();

      final advice = await AIService.getHealthAdvice(
        question: question,
        pet: _selectedPet!,
        trackingMetrics: petMetrics,
      );
      
      _messages.add(AiMessage(
        text: '🏥 Health Advice for ${_selectedPet!.name}:\n\n$advice',
        isUser: false,
        queryType: 'health',
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _messages.add(AiMessage(
        text: 'Unable to get health advice right now. Please try again.',
        isUser: false,
        queryType: 'health',
        timestamp: DateTime.now(),
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getBehaviorAdvice(String behavior) async {
    if (_selectedPet == null) {
      _messages.add(AiMessage(
        text: 'Please select a pet first to get behavior advice.',
        isUser: false,
        queryType: 'behavior',
        timestamp: DateTime.now(),
      ));
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final appState = Provider.of<AppStateProvider>(navigatorKey.currentContext!, listen: false);
      
      final petMetrics = appState.trackingMetrics
          .where((metric) => metric.petId == _selectedPet!.id.toString())
          .toList();

      final advice = await AIService.getBehaviorAdvice(
        behavior: behavior,
        pet: _selectedPet!,
        trackingMetrics: petMetrics,
      );
      
      _messages.add(AiMessage(
        text: '🐕 Behavior Analysis for ${_selectedPet!.name}:\n\n$advice',
        isUser: false,
        queryType: 'behavior',
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _messages.add(AiMessage(
        text: 'Unable to get behavior advice right now. Please try again.',
        isUser: false,
        queryType: 'behavior',
        timestamp: DateTime.now(),
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getNutritionAdvice(String question) async {
    if (_selectedPet == null) {
      _messages.add(AiMessage(
        text: 'Please select a pet first to get nutrition advice.',
        isUser: false,
        queryType: 'nutrition',
        timestamp: DateTime.now(),
      ));
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final appState = Provider.of<AppStateProvider>(navigatorKey.currentContext!, listen: false);

      final advice = await AIService.getNutritionAdvice(
        question: question,
        pet: _selectedPet!,
        shoppingItems: appState.shoppingItems,
      );
      
      _messages.add(AiMessage(
        text: '🍽️ Nutrition Advice for ${_selectedPet!.name}:\n\n$advice',
        isUser: false,
        queryType: 'nutrition',
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _messages.add(AiMessage(
        text: 'Unable to get nutrition advice right now. Please try again.',
        isUser: false,
        queryType: 'nutrition',
        timestamp: DateTime.now(),
      ));
    }

    _isLoading = false;
    notifyListeners();
  }
}

// Global navigator key for accessing context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class QueryTypeDropdown extends StatelessWidget {
  const QueryTypeDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AiProvider>(context);
    const queryTypes = [
      {'value': 'general', 'label': 'General Care'},
      {'value': 'health', 'label': 'Health & Wellness'},
      {'value': 'behavior', 'label': 'Behavior & Training'},
      {'value': 'nutrition', 'label': 'Nutrition & Diet'},
      {'value': 'emergency', 'label': 'Emergency'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: aiProvider.selectedQueryType,
            isExpanded: true,
            hint: const Text('Select query type'),
            items: queryTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type['value'],
                child: Text(type['label']!),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                aiProvider.setQueryType(newValue);
              }
            },
          ),
        ),
      ),
    );
  }
}

class PetSelector extends StatelessWidget {
  const PetSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AiProvider>(context);
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DropdownButtonFormField<Pet?>(
        value: aiProvider.selectedPet,
        decoration: InputDecoration(
          labelText: 'Select Pet (Optional)',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        items: [
          const DropdownMenuItem<Pet?>(
            value: null,
            child: Text('No pet selected'),
          ),
          ...appStateProvider.pets.map((pet) {
            return DropdownMenuItem<Pet?>(
              value: pet,
              child: Text('${pet.name} (${pet.species})'),
            );
          }).toList(),
        ],
        onChanged: (pet) {
          aiProvider.setSelectedPet(pet);
        },
      ),
    );
  }
}

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AiProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: aiProvider.isLoading ? null : () => aiProvider.getPersonalizedTips(context),
        icon: const Icon(Icons.lightbulb_outline),
        label: const Text('Personalized Tips'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final AiMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue[800] : Colors.grey[700],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }
}

class AskAiScreen extends StatelessWidget {
  const AskAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AiProvider(),
      builder: (context, child) {
        final aiProvider = Provider.of<AiProvider>(context);
        final textController = TextEditingController();
        return VideoBackground(
          videoPath: 'lib/assets/animation2.mp4',
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                // Header with title and clear button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        'Ask PetPal AI',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => aiProvider.clearChat(),
                        tooltip: 'Clear Chat',
                      ),
                    ],
                  ),
                ),
                const QueryTypeDropdown(),
                const PetSelector(),
                const QuickActions(),
                Expanded(
                  child: aiProvider.messages.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Start a conversation with PetPal!',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Select a pet for personalized advice',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '💡 Tip: Use the quick action buttons above for specific advice',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: aiProvider.messages.length,
                          itemBuilder: (context, index) {
                            return MessageBubble(message: aiProvider.messages[index]);
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: _getHintText(aiProvider.selectedQueryType),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                          onSubmitted: (value) async {
                            await aiProvider.sendMessage(value, context);
                            textController.clear();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      aiProvider.isLoading
                          ? const CircularProgressIndicator()
                          : IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () async {
                                await aiProvider.sendMessage(textController.text, context);
                                textController.clear();
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getHintText(String queryType) {
    switch (queryType) {
      case 'health':
        return 'Ask about health, exercise, or wellness...';
      case 'behavior':
        return 'Describe behavior or ask training questions...';
      case 'nutrition':
        return 'Ask about diet, food, or nutrition...';
      case 'emergency':
        return 'Describe emergency situation...';
      default:
        return 'Ask anything about your pet...';
    }
  }
}

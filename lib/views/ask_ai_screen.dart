import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
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

class AskAiScreen extends StatefulWidget {
  const AskAiScreen({super.key});

  @override
  State<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends State<AskAiScreen> {
  final TextEditingController _textController = TextEditingController();
  late FocusNode _inputFocusNode;
  bool _isInputFocused = false;
  final GlobalKey _inputBarKey = GlobalKey();
  double _inputBarHeight = 64.0;

  @override
  void dispose() {
    _inputFocusNode.removeListener(_handleFocusChange);
    _inputFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _inputFocusNode = FocusNode();
    _inputFocusNode.addListener(_handleFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureInputBar());
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isInputFocused = _inputFocusNode.hasFocus;
      });
      _measureInputBar();
    }
  }

  void _measureInputBar() {
    final box = _inputBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final h = box.size.height;
      if (h != _inputBarHeight && mounted) setState(() => _inputBarHeight = h);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AiProvider(),
      builder: (context, child) {
        final aiProvider = Provider.of<AiProvider>(context);
        final mq = MediaQuery.of(context);
        return VideoBackground(
          videoPath: 'lib/assets/animation2.mp4',
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: AnimatedPadding(
              padding: EdgeInsets.only(
                bottom: kBottomNavigationBarHeight + mq.padding.bottom + 12,
              ),
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              child: SafeArea(
                bottom: false,
                child: AnimatedSlide(
                  offset: Offset(0, MediaQuery.of(context).viewInsets.bottom > 0 ? -(100.0 / mq.size.height) : 0.0),
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  child: Column(
                  children: [
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
                              padding: const EdgeInsets.only(bottom: 8),
                              itemCount: aiProvider.messages.length,
                              itemBuilder: (context, index) {
                                return MessageBubble(message: aiProvider.messages[index]);
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Container(
                        key: _inputBarKey,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade700, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                focusNode: _inputFocusNode,
                                controller: _textController,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: 'Ask anything about your pet...',
                                  hintStyle: TextStyle(color: Colors.grey.shade400),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade600),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade600),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade800.withOpacity(0.5),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                maxLines: null,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (value) async {
                                  if (value.trim().isNotEmpty) {
                                    await aiProvider.sendMessage(value, context);
                                    _textController.clear();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade600,
                                    Colors.purple.shade600,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: aiProvider.isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.send, color: Colors.white),
                                      onPressed: () async {
                                        if (_textController.text.trim().isNotEmpty) {
                                          await aiProvider.sendMessage(_textController.text, context);
                                          _textController.clear();
                                        }
                                      },
                                    ),
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

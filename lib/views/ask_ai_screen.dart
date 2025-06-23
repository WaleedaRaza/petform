import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AiMessage {
  final String text;
  final bool isUser;
  final String promptTemplate;

  AiMessage({
    required this.text,
    required this.isUser,
    required this.promptTemplate,
  });
}

class AiProvider with ChangeNotifier {
  String _selectedPrompt = 'My pet is feeling ___'; // Default prompt
  List<AiMessage> _messages = [];
  bool _isLoading = false;

  String get selectedPrompt => _selectedPrompt;
  List<AiMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void setPrompt(String prompt) {
    _selectedPrompt = prompt;
    notifyListeners();
  }

  void sendMessage(String userInput) {
    if (userInput.trim().isEmpty) return;

    _isLoading = true;
    notifyListeners();

    // Add user message
    _messages.add(AiMessage(
      text: '$_selectedPrompt: $userInput',
      isUser: true,
      promptTemplate: _selectedPrompt,
    ));

    // Simulate AI response placeholder (no mock service)
    // Future server integration will add AI response here

    _isLoading = false;
    notifyListeners();
  }

  void clearChat() {
    _messages = [];
    notifyListeners();
  }
}

class PromptDropdown extends StatelessWidget {
  const PromptDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AiProvider>(context);
    const prompts = [
      'My pet is feeling ___',
      'My pet is ___',
      'My pet needs help with ___',
      'My pet ate ___',
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
      child: DropdownButtonFormField<String>(
        value: aiProvider.selectedPrompt,
        decoration: InputDecoration(
          labelText: 'Select a Prompt',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true, // Rely on inputDecorationTheme.fillColor
        ),
        items: prompts.map((prompt) {
          return DropdownMenuItem(
            value: prompt,
            child: Text(prompt),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            aiProvider.setPrompt(value);
          }
        },
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
        child: Text(
          message.text,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
    );
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

        return Scaffold(
          body: Column(
            children: [
              // Header with title and clear button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      'Ask AI',
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
              const PromptDropdown(),
              Expanded(
                child: aiProvider.messages.isEmpty
                    ? const Center(child: Text('Start a conversation!'))
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
                          hintText: 'Fill in the blank...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true, // Rely on inputDecorationTheme.fillColor
                        ),
                        onSubmitted: (value) {
                          aiProvider.sendMessage(value);
                          textController.clear();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    aiProvider.isLoading
                        ? const CircularProgressIndicator()
                        : IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              aiProvider.sendMessage(textController.text);
                              textController.clear();
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

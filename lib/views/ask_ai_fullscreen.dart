import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/video_background.dart';
import '../widgets/status_bar.dart';
import 'home_screen.dart';
import '../providers/app_state_provider.dart';
import '../providers/user_provider.dart';
import '../models/pet.dart';

// Reuse provider and message/quick action widgets from the existing Ask AI screen
import 'ask_ai_screen.dart' show AiProvider, MessageBubble, QuickActions;

class AskAiFullscreenPage extends StatefulWidget {
  const AskAiFullscreenPage({super.key});

  @override
  State<AskAiFullscreenPage> createState() => _AskAiFullscreenPageState();
}

class _AskAiFullscreenPageState extends State<AskAiFullscreenPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AiProvider(),
      builder: (context, _) {
        final aiProvider = Provider.of<AiProvider>(context);
        final mq = MediaQuery.of(context);
        final bottomInset = mq.viewInsets.bottom;
        final safeBottom = mq.padding.bottom;

        // When keyboard shows, keep messages visible
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (bottomInset > 0 && _scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });

        return VideoBackground(
          videoPath: 'assets/backdrop2.mp4',
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Stack(
                children: [
                  _buildScrollableContent(context, aiProvider),
                  // Floating input anchored to bottom; only this moves with the keyboard
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedPadding(
                      padding: EdgeInsets.only(bottom: bottomInset > 0 ? 80 : 8),
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOut,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildInputRow(context, aiProvider),
                      ),
                    ),
                  ),
                  // Diagnostics overlay (temporary)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'insets: ${bottomInset.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 1,
              selectedItemColor: Colors.orange,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
                BottomNavigationBarItem(icon: Icon(Icons.question_answer), label: 'Ask AI'),
                BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shopping'),
                BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Tracking'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
              onTap: (index) {
                if (index == 1) return; // Stay on Ask AI
                // Replace with HomeScreen but ensure providers are inherited
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      // Wrap in the same providers to avoid initialization issues
                      return MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(value: Provider.of<UserProvider>(context, listen: false)),
                          ChangeNotifierProvider.value(value: Provider.of<AppStateProvider>(context, listen: false)),
                        ],
                        child: HomeScreen(initialIndex: index),
                      );
                    },
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrollableContent(BuildContext context, AiProvider aiProvider) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    return Column(
      children: [
        // Header
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
                icon: const Icon(Icons.close),
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),

        // In-page pickers (no Overlay)
        _QueryTypePicker(
          value: aiProvider.selectedQueryType,
          onChanged: (val) => aiProvider.setQueryType(val),
        ),
        _PetPicker(
          pets: appState.pets,
          selected: aiProvider.selectedPet,
          onChanged: (pet) => aiProvider.setSelectedPet(pet),
        ),

        const QuickActions(),

        // Messages
        Expanded(
          child: Consumer<AiProvider>(
            builder: (_, provider, __) {
              if (provider.messages.isEmpty) {
                return const Center(
                  child: Text(
                    'Start a conversation with PetPal!\nSelect a pet for personalized advice',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: provider.messages.length,
                itemBuilder: (context, index) => MessageBubble(message: provider.messages[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInputRow(BuildContext context, AiProvider aiProvider) {
    return Row(
      children: [
        Expanded(
          child: TextField(
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
              if (value.trim().isEmpty) return;
              await aiProvider.sendMessage(value, context);
              _textController.clear();
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.blue.shade600,
              Colors.purple.shade600,
            ]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Consumer<AiProvider>(
            builder: (_, provider, __) => provider.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () async {
                      if (_textController.text.trim().isEmpty) return;
                      await aiProvider.sendMessage(_textController.text, context);
                      _textController.clear();
                    },
                  ),
          ),
        )
      ],
    );
  }
}

class _QueryTypePicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _QueryTypePicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = [
      {'value': 'general', 'label': 'General Care'},
      {'value': 'health', 'label': 'Health & Wellness'},
      {'value': 'behavior', 'label': 'Behavior & Training'},
      {'value': 'nutrition', 'label': 'Nutrition & Diet'},
      {'value': 'emergency', 'label': 'Emergency'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () async {
          final selected = await showModalBottomSheet<String>(
            context: context,
            backgroundColor: Colors.grey[900],
            builder: (_) => SafeArea(
              child: ListView(
                children: items
                    .map((e) => ListTile(
                          title: Text(e['label']!, style: const TextStyle(color: Colors.white)),
                          onTap: () => Navigator.pop(context, e['value']!),
                        ))
                    .toList(),
              ),
            ),
          );
          if (selected != null) onChanged(selected);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  items.firstWhere((e) => e['value'] == value)['label']!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const Icon(Icons.expand_more, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetPicker extends StatelessWidget {
  final List<Pet> pets;
  final Pet? selected;
  final ValueChanged<Pet?> onChanged;
  const _PetPicker({required this.pets, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () async {
          final result = await showModalBottomSheet<Pet?>(
            context: context,
            backgroundColor: Colors.grey[900],
            builder: (_) => SafeArea(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('No pet selected', style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pop(context, null),
                  ),
                  ...pets.map((p) => ListTile(
                        title: Text('${p.name} (${p.species})', style: const TextStyle(color: Colors.white)),
                        onTap: () => Navigator.pop(context, p),
                      )),
                ],
              ),
            ),
          );
          onChanged(result);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade600),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected == null ? 'No pet selected' : '${selected!.name} (${selected!.species})',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const Icon(Icons.expand_more, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}


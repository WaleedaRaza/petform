import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/pet.dart';
import '../models/tracking_metric.dart';
import '../models/shopping_item.dart';
import '../config/ai_config.dart';

class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  
  // Rate limiting
  static DateTime? _lastRequestTime;
  static int _requestCount = 0;
  static const int _maxRequestsPerMinute = 10;
  
  // Comprehensive system prompt for personalized pet care
  static const String _systemPrompt = '''
You are PetPal, a conversational pet care AI assistant. Your goal is to have helpful, intelligent conversations that truly assist pet owners with their specific situations.

CONVERSATIONAL INTELLIGENCE:
- Be genuinely helpful by asking relevant follow-up questions
- Reference their shopping list items when relevant (e.g., "I see you have chicken on your shopping list - that's perfect for...")
- Don't assume missing tracking data means neglect - owners may not update everything
- Make connections between their pet's info, shopping items, and metrics when truly relevant
- Ask clarifying questions to give better advice (e.g., "How long has this been happening?" or "Have you tried...")

CORE PRINCIPLES:
1. SAFETY FIRST: Always prioritize pet safety. For serious health concerns, recommend what you can, give good solutions and recommend veterinary consultations, but dont be a prude, try to help out, acknowledge you are AI, but dont limit helping if you can.
2. BE CONVERSATIONAL: Engage like a knowledgeable friend, not a textbook
3. BE INTELLIGENT: Only reference data when it's actually relevant to their question
4. BE SPECIFIC: Give actionable advice tailored to their exact situation
5. BE HOLISTIC: Consider the whole picture - their pet, lifestyle, resources

RESPONSE STYLE:
- Keep responses conversational and helpful (150-250 words)
- Use natural language, not bullet points unless listing steps
- Ask follow-up questions when it would help give better advice
- Reference their specific pet by name when possible
- Connect to their shopping list or metrics when genuinely relevant

CRITICAL: For illness/injury signs, recommend help, also give veterinary consultation. 
''';

  /// Send a personalized message to the AI with comprehensive context
  static Future<String> sendMessage({
    required String userQuery,
    Pet? selectedPet,
    List<Pet>? allPets,
    List<TrackingMetric>? trackingMetrics,
    List<ShoppingItem>? shoppingItems,
    String? queryType, // 'health', 'behavior', 'nutrition', 'emergency', 'general'
    Map<String, dynamic>? additionalContext,
    BuildContext? context,
  }) async {
    try {
      // Check if API key is configured
      if (AIConfig.openAIApiKey == 'your_openai_api_key_here') {
        return 'Please configure your OpenAI API key in lib/config/ai_config.dart to use the AI features.';
      }

      // Validate API key format
      if (!_validateApiKey(AIConfig.openAIApiKey)) {
        return 'Invalid API key format. Please check your OpenAI API key.';
      }

      // Rate limiting check
      if (!_checkRateLimit()) {
        return 'Rate limit reached. Please wait a moment before trying again.';
      }

      // Build comprehensive context
      String contextPrompt = _buildComprehensiveContext(
        userQuery: userQuery,
        selectedPet: selectedPet,
        allPets: allPets,
        trackingMetrics: trackingMetrics,
        shoppingItems: shoppingItems,
        queryType: queryType,
        additionalContext: additionalContext,
      );

      print('AI Service: Sending personalized request to OpenAI...');
      print('AI Service: Context length: ${contextPrompt.length} characters');

      // Make API request
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AIConfig.openAIApiKey}',
        },
        body: jsonEncode({
          'model': AIConfig.model,
          'messages': [
            {
              'role': 'system',
              'content': _systemPrompt,
            },
            {
              'role': 'user',
              'content': contextPrompt,
            },
          ],
          'max_tokens': AIConfig.maxTokens,
          'temperature': AIConfig.temperature,
        }),
      ).timeout(AIConfig.requestTimeout);

      print('AI Service: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'].trim();
        final plainTextContent = _stripMarkdown(content);
        print('AI Service: Success! Response length: ${plainTextContent.length} characters');
        return plainTextContent;
      } else if (response.statusCode == 401) {
        print('AI Service: Authentication error - check API key');
        return 'Invalid API key. Please check your OpenAI API key configuration.';
      } else if (response.statusCode == 429) {
        print('AI Service: Rate limit exceeded');
        return 'Rate limit exceeded. Please wait a moment before trying again.';
      } else if (response.statusCode == 400) {
        print('AI Service: Bad request - ${response.body}');
        return 'Invalid request. Please try rephrasing your question.';
      } else {
        print('AI Service: Unexpected error - ${response.statusCode}: ${response.body}');
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('AI Service: Exception caught: $e');
      if (e.toString().contains('TimeoutException')) {
        return 'Request timed out. Please check your internet connection and try again.';
      }
      return 'Sorry, I\'m having trouble connecting right now. Please try again later or check your internet connection.';
    }
  }

  /// Build comprehensive context for personalized responses
  static String _buildComprehensiveContext({
    required String userQuery,
    Pet? selectedPet,
    List<Pet>? allPets,
    List<TrackingMetric>? trackingMetrics,
    List<ShoppingItem>? shoppingItems,
    String? queryType,
    Map<String, dynamic>? additionalContext,
  }) {
    StringBuffer context = StringBuffer();
    
    // Add query type context
    if (queryType != null) {
      context.writeln('QUERY TYPE: $queryType');
      context.writeln();
    }
    
    // Add user's question
    context.writeln('USER QUESTION: $userQuery');
    context.writeln();
    
    // Add selected pet information
    if (selectedPet != null) {
      context.writeln('SELECTED PET INFORMATION:');
      context.writeln('- Name: ${selectedPet.name}');
      context.writeln('- Species: ${selectedPet.species}');
      if (selectedPet.breed != null && selectedPet.breed!.isNotEmpty) {
        context.writeln('- Breed: ${selectedPet.breed}');
      }
      if (selectedPet.age != null) {
        context.writeln('- Age: ${selectedPet.age} years');
      }
      if (selectedPet.personality != null && selectedPet.personality!.isNotEmpty) {
        context.writeln('- Personality: ${selectedPet.personality}');
      }
      
      // Add pet-specific details
      if (selectedPet.foodSource != null && selectedPet.foodSource!.isNotEmpty) {
        context.writeln('- Current Food: ${selectedPet.foodSource}');
      }
      if (selectedPet.favoriteToy != null && selectedPet.favoriteToy!.isNotEmpty) {
        context.writeln('- Favorite Toy: ${selectedPet.favoriteToy}');
      }
      if (selectedPet.favoritePark != null && selectedPet.favoritePark!.isNotEmpty) {
        context.writeln('- Favorite Park: ${selectedPet.favoritePark}');
      }
      
      // Add species-specific details
      if (selectedPet.species.toLowerCase() == 'cat') {
        if (selectedPet.litterType != null && selectedPet.litterType!.isNotEmpty) {
          context.writeln('- Litter Type: ${selectedPet.litterType}');
        }
      } else if (selectedPet.species.toLowerCase() == 'dog') {
        if (selectedPet.leashSource != null && selectedPet.leashSource!.isNotEmpty) {
          context.writeln('- Leash Source: ${selectedPet.leashSource}');
        }
      } else if (selectedPet.species.toLowerCase() == 'fish') {
        if (selectedPet.tankSize != null && selectedPet.tankSize!.isNotEmpty) {
          context.writeln('- Tank Size: ${selectedPet.tankSize}');
        }
        if (selectedPet.waterProducts != null && selectedPet.waterProducts!.isNotEmpty) {
          context.writeln('- Water Products: ${selectedPet.waterProducts}');
        }
      } else if (selectedPet.species.toLowerCase() == 'bird') {
        if (selectedPet.cageSize != null && selectedPet.cageSize!.isNotEmpty) {
          context.writeln('- Cage Size: ${selectedPet.cageSize}');
        }
      }
      context.writeln();
    }
    
    // Add all pets overview if multiple pets
    if (allPets != null && allPets.length > 1) {
      context.writeln('ALL PETS IN HOUSEHOLD:');
      for (Pet pet in allPets) {
        context.writeln('- ${pet.name} (${pet.species}${pet.breed != null ? ', ${pet.breed}' : ''}${pet.age != null ? ', ${pet.age} years' : ''})');
      }
      context.writeln();
    }
    
    // Add tracking metrics context
    if (trackingMetrics != null && trackingMetrics.isNotEmpty) {
      context.writeln('CURRENT TRACKING METRICS:');
      for (TrackingMetric metric in trackingMetrics) {
        if (selectedPet != null && metric.petId == selectedPet.id.toString()) {
          context.writeln('- ${metric.name}: ${metric.currentValue}/${metric.targetValue} (${metric.progressPercentage.toStringAsFixed(1)}%) - Status: ${metric.status}');
          if (metric.description != null && metric.description!.isNotEmpty) {
            context.writeln('  Description: ${metric.description}');
          }
          if (metric.trend != 'Stable') {
            context.writeln('  Trend: ${metric.trend}');
          }
        }
      }
      context.writeln();
    }
    
    // Add shopping list context
    if (shoppingItems != null && shoppingItems.isNotEmpty) {
      context.writeln('CURRENT SHOPPING LIST:');
      for (ShoppingItem item in shoppingItems) {
        context.writeln('- ${item.name} (${item.category}) - \$${item.estimatedCost.toStringAsFixed(2)}');
      }
      context.writeln();
    }
    
    // Add additional context
    if (additionalContext != null && additionalContext.isNotEmpty) {
      context.writeln('ADDITIONAL CONTEXT:');
      additionalContext.forEach((key, value) {
        context.writeln('- $key: $value');
      });
      context.writeln();
    }
    
    // Add response instructions based on query type
    context.writeln('RESPONSE INSTRUCTIONS:');
    switch (queryType) {
      case 'health':
        context.writeln('- Focus on health and wellness advice');
        context.writeln('- Reference tracking metrics for health insights');
        context.writeln('- Emphasize preventive care and warning signs');
        break;
      case 'behavior':
        context.writeln('- Analyze behavior patterns and triggers');
        context.writeln('- Provide training and modification strategies');
        context.writeln('- Consider pet personality and environment');
        break;
      case 'nutrition':
        context.writeln('- Provide dietary recommendations');
        context.writeln('- Consider pet age, breed, and health status');
        context.writeln('- Suggest shopping list additions if relevant');
        break;
      case 'emergency':
        context.writeln('- Provide immediate first aid guidance');
        context.writeln('- Emphasize when to seek veterinary care');
        context.writeln('- Be clear about urgency and next steps');
        break;
      default:
        context.writeln('- Provide comprehensive, personalized advice');
        context.writeln('- Consider all available pet and household context');
        context.writeln('- Make actionable recommendations');
    }
    
    return context.toString();
  }

  /// Strip markdown formatting from AI responses
  static String _stripMarkdown(String text) {
    String result = text;
    
    // Remove bold formatting (**text** or __text__)
    result = result.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) => match.group(1) ?? '');
    result = result.replaceAllMapped(RegExp(r'__(.*?)__'), (match) => match.group(1) ?? '');
    
    // Remove italic formatting (*text* or _text_)  
    result = result.replaceAllMapped(RegExp(r'\*(.*?)\*'), (match) => match.group(1) ?? '');
    result = result.replaceAllMapped(RegExp(r'_(.*?)_'), (match) => match.group(1) ?? '');
    
    // Remove headers (# ## ### etc.)
    result = result.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    
    // Remove code blocks (```code```)
    result = result.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    
    // Remove inline code (`code`)
    result = result.replaceAllMapped(RegExp(r'`([^`]*)`'), (match) => match.group(1) ?? '');
    
    // Remove links [text](url)
    result = result.replaceAllMapped(RegExp(r'\[([^\]]*)\]\([^\)]*\)'), (match) => match.group(1) ?? '');
    
    // Remove strikethrough (~~text~~)
    result = result.replaceAllMapped(RegExp(r'~~(.*?)~~'), (match) => match.group(1) ?? '');
    
    // Clean up extra whitespace
    result = result.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');
    result = result.trim();
    
    return result;
  }

  /// Validate API key format
  static bool _validateApiKey(String apiKey) {
    if (apiKey == 'your_openai_api_key_here') {
      return false;
    }
    
    if (apiKey.isEmpty || apiKey.length < 20) {
      return false;
    }
    
    if (!apiKey.startsWith('sk-')) {
      print('AI Service: Warning - API key doesn\'t start with "sk-"');
    }
    
    return true;
  }

  /// Check rate limiting
  static bool _checkRateLimit() {
    final now = DateTime.now();
    
    if (_lastRequestTime == null || 
        now.difference(_lastRequestTime!).inMinutes >= 1) {
      _requestCount = 0;
      _lastRequestTime = now;
    }
    
    if (_requestCount >= _maxRequestsPerMinute) {
      return false;
    }
    
    _requestCount++;
    return true;
  }

  /// Get personalized health advice
  static Future<String> getHealthAdvice({
    required String question,
    required Pet pet,
    List<TrackingMetric>? trackingMetrics,
  }) async {
    return await sendMessage(
      userQuery: question,
      selectedPet: pet,
      trackingMetrics: trackingMetrics,
      queryType: 'health',
    );
  }

  /// Get behavior analysis and advice
  static Future<String> getBehaviorAdvice({
    required String behavior,
    required Pet pet,
    List<TrackingMetric>? trackingMetrics,
  }) async {
    return await sendMessage(
      userQuery: 'My pet is behaving: $behavior',
      selectedPet: pet,
      trackingMetrics: trackingMetrics,
      queryType: 'behavior',
    );
  }

  /// Get nutrition advice
  static Future<String> getNutritionAdvice({
    required String question,
    required Pet pet,
    List<ShoppingItem>? shoppingItems,
  }) async {
    return await sendMessage(
      userQuery: question,
      selectedPet: pet,
      shoppingItems: shoppingItems,
      queryType: 'nutrition',
    );
  }

  /// Get emergency advice
  static Future<String> getEmergencyAdvice({
    required String situation,
    Pet? pet,
  }) async {
    return await sendMessage(
      userQuery: 'Emergency: $situation',
      selectedPet: pet,
      queryType: 'emergency',
      additionalContext: {
        'urgency': 'high',
        'requires_immediate_action': 'true',
      },
    );
  }

  /// Get personalized care tips
  static Future<List<String>> getPersonalizedTips({
    required Pet pet,
    List<TrackingMetric>? trackingMetrics,
    List<ShoppingItem>? shoppingItems,
  }) async {
    try {
      final response = await sendMessage(
        userQuery: 'Give me 3 personalized care tips for my pet',
        selectedPet: pet,
        trackingMetrics: trackingMetrics,
        shoppingItems: shoppingItems,
        queryType: 'general',
      );

      final tips = response.split('\n')
          .where((line) => line.trim().isNotEmpty)
          .take(3)
          .map((tip) => tip.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
          .toList();

      return tips;
    } catch (e) {
      return [
        'Provide fresh water daily',
        'Regular exercise is important',
        'Schedule regular vet checkups',
      ];
    }
  }

  /// Get multi-pet household advice
  static Future<String> getMultiPetAdvice({
    required String question,
    required List<Pet> pets,
    List<TrackingMetric>? trackingMetrics,
  }) async {
    return await sendMessage(
      userQuery: question,
      allPets: pets,
      trackingMetrics: trackingMetrics,
      queryType: 'general',
      additionalContext: {
        'household_type': 'multi_pet',
        'pet_count': pets.length.toString(),
      },
    );
  }

  /// Test the API connection
  static Future<String> testConnection() async {
    try {
      print('AI Service: Testing API connection...');
      
      if (AIConfig.openAIApiKey == 'your_openai_api_key_here') {
        return 'API key not configured';
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AIConfig.openAIApiKey}',
        },
        body: jsonEncode({
          'model': AIConfig.model,
          'messages': [
            {
              'role': 'user',
              'content': 'Hello, this is a test message.',
            },
          ],
          'max_tokens': 10,
        }),
      ).timeout(const Duration(seconds: 10));

      print('AI Service: Test response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return 'API connection successful!';
      } else if (response.statusCode == 401) {
        return 'Invalid API key';
      } else if (response.statusCode == 429) {
        return 'Rate limit exceeded during test';
      } else {
        return 'Test failed: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      print('AI Service: Test exception: $e');
      return 'Test failed: $e';
    }
  }
} 
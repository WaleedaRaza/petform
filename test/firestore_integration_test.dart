import 'package:flutter_test/flutter_test.dart';
import 'package:petform/services/firestore_verification_service.dart';
import 'package:petform/providers/user_provider.dart';
import 'package:petform/providers/pet_provider.dart';
import 'package:petform/providers/post_provider.dart';
import 'package:petform/providers/shopping_provider.dart';
import 'package:petform/providers/tracking_provider.dart';

void main() {
  group('Firestore Integration Tests', () {
    late FirestoreVerificationService verificationService;
    late UserProvider userProvider;
    late PetProvider petProvider;
    late PostProvider postProvider;
    late ShoppingProvider shoppingProvider;
    late TrackingProvider trackingProvider;

    setUp(() {
      verificationService = FirestoreVerificationService();
      userProvider = UserProvider();
      petProvider = PetProvider();
      postProvider = PostProvider();
      shoppingProvider = ShoppingProvider();
      trackingProvider = TrackingProvider();
    });

    test('UserProvider should have isLoggedIn getter', () {
      expect(userProvider.isLoggedIn, isA<bool>());
    });

    test('UserProvider should have username management methods', () {
      expect(userProvider.isUsernameUnique, isA<Function>());
      expect(userProvider.reserveUsername, isA<Function>());
      expect(userProvider.releaseUsername, isA<Function>());
      expect(userProvider.updateUsername, isA<Function>());
    });

    test('PetProvider should have CRUD operations', () {
      expect(petProvider.pets, isA<Stream>());
      expect(petProvider.addPet, isA<Function>());
      expect(petProvider.updatePet, isA<Function>());
      expect(petProvider.deletePet, isA<Function>());
    });

    test('PostProvider should have CRUD operations', () {
      expect(postProvider.posts, isA<Stream>());
      expect(postProvider.addPost, isA<Function>());
      expect(postProvider.updatePost, isA<Function>());
      expect(postProvider.deletePost, isA<Function>());
    });

    test('ShoppingProvider should have CRUD operations', () {
      expect(shoppingProvider.shoppingItems, isA<Stream>());
      expect(shoppingProvider.addShoppingItem, isA<Function>());
      expect(shoppingProvider.updateShoppingItem, isA<Function>());
      expect(shoppingProvider.deleteShoppingItem, isA<Function>());
    });

    test('TrackingProvider should have CRUD operations', () {
      expect(trackingProvider.metrics, isA<Stream>());
      expect(trackingProvider.addMetric, isA<Function>());
      expect(trackingProvider.updateMetric, isA<Function>());
      expect(trackingProvider.deleteMetric, isA<Function>());
    });

    test('FirestoreVerificationService should have test methods', () {
      expect(verificationService.testFirestoreIntegration, isA<Function>());
      expect(verificationService.getAllUserData, isA<Function>());
      expect(verificationService.cleanupTestData, isA<Function>());
    });
  });
} 
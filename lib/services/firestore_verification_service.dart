import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';

class FirestoreVerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Test data creation and verification
  Future<Map<String, dynamic>> testFirestoreIntegration() async {
    final results = <String, dynamic>{};
    
    try {
      // Test 1: Check if user is authenticated
      final user = _auth.currentUser;
      results['user_authenticated'] = user != null;
      results['user_id'] = user?.uid;
      results['user_email'] = user?.email;

      if (user == null) {
        results['error'] = 'No authenticated user found';
        return results;
      }

      // Test 2: Test user profile creation
      await _testUserProfile(user.uid, user.email ?? 'test@example.com', results);

      // Test 3: Test pet creation
      await _testPetCreation(user.uid, results);

      // Test 4: Test post creation
      await _testPostCreation(user.uid, results);

      // Test 5: Test shopping item creation
      await _testShoppingItemCreation(user.uid, results);

      // Test 6: Test tracking metric creation
      await _testTrackingMetricCreation(user.uid, results);

      // Test 7: Test username reservation
      await _testUsernameReservation(user.uid, results);

      results['success'] = true;
      results['message'] = 'All Firestore tests passed!';

    } catch (e) {
      results['success'] = false;
      results['error'] = 'Firestore test failed: $e';
      if (kDebugMode) {
        print('FirestoreVerificationService: Error during testing: $e');
      }
    }

    return results;
  }

  Future<void> _testUserProfile(String userId, String email, Map<String, dynamic> results) async {
    try {
      final userData = {
        'email': email,
        'username': 'testuser_${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userId).set(userData);
      
      final doc = await _firestore.collection('users').doc(userId).get();
      results['user_profile_created'] = doc.exists;
      results['user_profile_data'] = doc.data();
    } catch (e) {
      results['user_profile_error'] = e.toString();
    }
  }

  Future<void> _testPetCreation(String userId, Map<String, dynamic> results) async {
    try {
      final petData = {
        'name': 'Test Pet',
        'type': 'Dog',
        'breed': 'Golden Retriever',
        'age': 3,
        'weight': 25.5,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .add(petData);

      final doc = await docRef.get();
      results['pet_created'] = doc.exists;
      results['pet_id'] = docRef.id;
      results['pet_data'] = doc.data();
    } catch (e) {
      results['pet_creation_error'] = e.toString();
    }
  }

  Future<void> _testPostCreation(String userId, Map<String, dynamic> results) async {
    try {
      final postData = {
        'title': 'Test Post',
        'content': 'This is a test post to verify Firestore integration.',
        'imageUrl': null,
        'likes': 0,
        'isSaved': false,
        'createdAt': FieldValue.serverTimestamp(),
        'userEmail': _auth.currentUser?.email ?? 'test@example.com',
      };

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('posts')
          .add(postData);

      final doc = await docRef.get();
      results['post_created'] = doc.exists;
      results['post_id'] = docRef.id;
      results['post_data'] = doc.data();
    } catch (e) {
      results['post_creation_error'] = e.toString();
    }
  }

  Future<void> _testShoppingItemCreation(String userId, Map<String, dynamic> results) async {
    try {
      final itemData = {
        'name': 'Test Food',
        'category': 'Food',
        'price': 15.99,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('shopping_items')
          .add(itemData);

      final doc = await docRef.get();
      results['shopping_item_created'] = doc.exists;
      results['shopping_item_id'] = docRef.id;
      results['shopping_item_data'] = doc.data();
    } catch (e) {
      results['shopping_item_creation_error'] = e.toString();
    }
  }

  Future<void> _testTrackingMetricCreation(String userId, Map<String, dynamic> results) async {
    try {
      final metricData = {
        'name': 'Weight Check',
        'value': 25.5,
        'unit': 'kg',
        'date': FieldValue.serverTimestamp(),
        'notes': 'Test tracking metric',
        'petId': 'test_pet_id',
      };

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tracking_metrics')
          .add(metricData);

      final doc = await docRef.get();
      results['tracking_metric_created'] = doc.exists;
      results['tracking_metric_id'] = docRef.id;
      results['tracking_metric_data'] = doc.data();
    } catch (e) {
      results['tracking_metric_creation_error'] = e.toString();
    }
  }

  Future<void> _testUsernameReservation(String userId, Map<String, dynamic> results) async {
    try {
      final username = 'testuser_${DateTime.now().millisecondsSinceEpoch}';
      final reservationData = {
        'username': username,
        'userId': userId,
        'email': _auth.currentUser?.email ?? 'test@example.com',
        'reservedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('username_reservations')
          .doc(username)
          .set(reservationData);

      final doc = await _firestore
          .collection('username_reservations')
          .doc(username)
          .get();

      results['username_reserved'] = doc.exists;
      results['username_reservation_data'] = doc.data();
    } catch (e) {
      results['username_reservation_error'] = e.toString();
    }
  }

  // Get all data for a user
  Future<Map<String, dynamic>> getAllUserData() async {
    final user = _auth.currentUser;
    if (user == null) return {'error': 'No authenticated user'};

    final data = <String, dynamic>{};
    
    try {
      // Get user profile
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      data['user_profile'] = userDoc.data();

      // Get pets
      final petsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .get();
      data['pets'] = petsSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

      // Get posts
      final postsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('posts')
          .get();
      data['posts'] = postsSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

      // Get shopping items
      final shoppingSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('shopping_items')
          .get();
      data['shopping_items'] = shoppingSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

      // Get tracking metrics
      final trackingSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tracking_metrics')
          .get();
      data['tracking_metrics'] = trackingSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

      // Get username reservations
      final usernameSnapshot = await _firestore
          .collection('username_reservations')
          .where('userId', isEqualTo: user.uid)
          .get();
      data['username_reservations'] = usernameSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

    } catch (e) {
      data['error'] = 'Failed to fetch data: $e';
    }

    return data;
  }

  // Clean up test data
  Future<void> cleanupTestData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Delete test pets
      final petsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .where('name', isEqualTo: 'Test Pet')
          .get();
      
      for (final doc in petsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete test posts
      final postsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('posts')
          .where('title', isEqualTo: 'Test Post')
          .get();
      
      for (final doc in postsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete test shopping items
      final shoppingSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('shopping_items')
          .where('name', isEqualTo: 'Test Food')
          .get();
      
      for (final doc in shoppingSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete test tracking metrics
      final trackingSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tracking_metrics')
          .where('name', isEqualTo: 'Weight Check')
          .get();
      
      for (final doc in trackingSnapshot.docs) {
        await doc.reference.delete();
      }

      if (kDebugMode) {
        print('FirestoreVerificationService: Test data cleaned up successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreVerificationService: Error cleaning up test data: $e');
      }
    }
  }
} 
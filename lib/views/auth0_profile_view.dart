import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class Auth0ProfileView extends StatefulWidget {
  final UserProfile user;

  const Auth0ProfileView({Key? key, required this.user}) : super(key: key);

  @override
  State<Auth0ProfileView> createState() => _Auth0ProfileViewState();
}

class _Auth0ProfileViewState extends State<Auth0ProfileView> {
  bool _isRedirecting = false;

  @override
  void initState() {
    super.initState();
    // Auto-redirect after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isRedirecting) {
        setState(() {
          _isRedirecting = true;
        });
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Welcome!'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Prevent back button
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile picture
                                if (widget.user.pictureUrl != null)
                CircleAvatar(
                  radius: 50,
                                        backgroundImage: NetworkImage(widget.user.pictureUrl.toString()),
                )
              else
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: Text(
                    (widget.user.name?.substring(0, 1) ?? widget.user.email?.substring(0, 1) ?? 'U').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              
              // Welcome message
              Text(
                'Welcome to Petform!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              
              // User name
              if (widget.user.name != null)
                Text(
                  widget.user.name!,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              
              // User email
              if (widget.user.email != null)
                Text(
                  widget.user.email!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white60,
                  ),
                  textAlign: TextAlign.center,
                ),
              
              const SizedBox(height: 10),
              
              // Email verification status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (widget.user.isEmailVerified ?? false)
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (widget.user.isEmailVerified ?? false) ? Colors.green : Colors.orange,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      (widget.user.isEmailVerified ?? false) ? Icons.verified : Icons.warning,
                      color: (widget.user.isEmailVerified ?? false) ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (widget.user.isEmailVerified ?? false) ? 'Email Verified' : 'Email Not Verified',
                      style: TextStyle(
                        color: (widget.user.isEmailVerified ?? false) ? Colors.green : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Success message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Authentication successful! Redirecting to app...',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              
              const SizedBox(height: 20),
              
              // Manual continue button
              ElevatedButton(
                onPressed: _isRedirecting ? null : () {
                  setState(() {
                    _isRedirecting = true;
                  });
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(_isRedirecting ? 'Redirecting...' : 'Continue to App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
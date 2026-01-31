import 'package:drms/model/User.dart';
import 'package:drms/screens/home_screen.dart';
import 'package:drms/services/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dbcrypt/dbcrypt.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // API endpoints
  // final String baseUrl = 'http://10.179.2.219:8083/drms/v-1/app/api';
  final String baseUrl = 'https://relief.megrevenuedm.gov.in/stagingapi/drms/v-1/app/api';

  @override
  void initState() {
    super.initState();

    checkSession();
  }

  checkSession() async {
    bool loggedIn = await Session.instance.isLoggedIn();
    if (loggedIn) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Step 1: Get Public Key
  Future<String?> getPublicKey() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getPublickey'));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to get public key');
      }
    } catch (e) {
      print('Error getting public key: $e');
      return null;
    }
  }

  // Step 2-4: Hash password according to the mechanism
  String hashPassword(String password, String publicKey) {
    // Step 2: SHA256 of password
    var bytes = utf8.encode(password);
    var firstHash = sha256.convert(bytes);

    // Step 3: Concatenate first hash + publicKey, then SHA256 again
    var combined = firstHash.toString() + publicKey;
    var combinedBytes = utf8.encode(combined);
    var secondHash = sha256.convert(combinedBytes);

    // Step 4: BCrypt hash
    var bcrypt = DBCrypt();
    var hashedPassword = bcrypt.hashpw(secondHash.toString(), bcrypt.gensalt());

    return hashedPassword;
  }

  // Login API call
  Future<void> performLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter both username and password')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Step 1: Get public key
      String? publicKey = await getPublicKey();

      if (publicKey == null) {
        throw Exception('Could not retrieve public key');
      }

      // Step 2-4: Hash the password
      String hashedPassword = hashPassword(passwordController.text, publicKey);

      // Prepare login request
      final loginData = {'username': emailController.text, 'password': hashedPassword, 'publicKey': publicKey, 'captcha': ''};

      // Make login request
      final response = await http.post(Uri.parse('$baseUrl/signin'), headers: {'Content-Type': 'application/json'}, body: json.encode(loginData));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if login was successful (token exists)
        if (data['token'] != null && data['token'].toString().isNotEmpty) {
          // Save login data to shared preferences
          User user = User.fromJson(data);
          if (await Session.instance.saveSession(user)) {
            await Session.instance.putToken(data['token']);

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          }
        } else {
          throw Exception(data['message'] ?? 'Login failed - no token received');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid credentials');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo or illustration
                  Container(height: 120, child: SvgPicture.asset('assets/disaster_relief.svg', height: 120)),
                  SizedBox(height: 24),
                  Text("Disaster Relief", style: textTheme.titleLarge),
                  SizedBox(height: 10),
                  Text(
                    "Helping hands when you need it most.",
                    style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  // Username Field
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.text,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      prefixIcon: Icon(Icons.person, color: colorScheme.primary),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Password Field
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                    ),
                  ),
                  SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading ? null : () {},
                      child: Text('Forgot Password?', style: textTheme.labelLarge),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : performLogin,
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                            )
                          : Text("Log In"),
                    ),
                  ),
                  SizedBox(height: 18),
                  Text("New to Disaster Relief?", style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                  TextButton(
                    onPressed: isLoading ? null : () {},
                    child: Text('Create Account', style: textTheme.labelLarge),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

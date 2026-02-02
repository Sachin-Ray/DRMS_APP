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

  // ✅ Password toggle variable
  bool isPasswordVisible = false;
  final String baseUrl =
      'https://relief.megrevenuedm.gov.in/stagingapi/drms/v-1/app/api';

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  checkSession() async {
    bool loggedIn = await Session.instance.isLoggedIn();
    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
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
      debugPrint('Error getting public key: $e');
      return null;
    }
  }

  // Step 2-4: Hash password according to the mechanism
  String hashPassword(String password, String publicKey) {
    var bytes = utf8.encode(password);
    var firstHash = sha256.convert(bytes);

    var combined = firstHash.toString() + publicKey;
    var combinedBytes = utf8.encode(combined);
    var secondHash = sha256.convert(combinedBytes);

    var bcrypt = DBCrypt();
    var hashedPassword = bcrypt.hashpw(secondHash.toString(), bcrypt.gensalt());

    return hashedPassword;
  }

  // Login API call
  Future<void> performLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both username and password'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String? publicKey = await getPublicKey();

      if (publicKey == null) {
        throw Exception('Could not retrieve public key');
      }

      String hashedPassword = hashPassword(passwordController.text, publicKey);

      final loginData = {
        'username': emailController.text,
        'password': hashedPassword,
        'publicKey': publicKey,
        'captcha': '',
      };

      debugPrint("loginData: $loginData");

      final response = await http.post(
        Uri.parse('$baseUrl/signin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['token'] != null && data['token'].toString().isNotEmpty) {
          User user = User.fromJson(data);

          if (await Session.instance.saveSession(user)) {
            await Session.instance.putToken(data['token']);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        } else {
          throw Exception(
            data['message'] ?? 'Login failed - no token received',
          );
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid credentials');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= UI ==================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        height: 95,
                        width: 95,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          "assets/logo/meghalaya_logo.png",
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 14),

                      SvgPicture.asset(
                        "assets/disaster_relief.svg",
                        height: 90,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    "Disaster And Relief\nMonitoring System",
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2A428C),
                    ),
                  ),

                  const SizedBox(height: 11),

                  // Subtitle
                  Text(
                    "Helping hands when you need it most.",
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Username Field
                  TextField(
                    controller: emailController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: "Username",
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Color(0xFF2A428C),
                      ),
                      filled: true,
                      fillColor: const Color(0xffF5F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ✅ Password Field with Eye Icon
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color(0xFF2A428C),
                      ),

                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey[700],
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),

                      filled: true,
                      fillColor: const Color(0xffF5F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A428C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isLoading ? null : performLogin,
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Support Text
                  Text(
                    "Connecting help to hope through disaster relief services.",
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    "© Disaster And Relief Monitoring System",
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
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

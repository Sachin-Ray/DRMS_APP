import 'package:drms/screens/login_screen.dart';
import 'package:drms/services/session.dart';
import 'package:flutter/material.dart';
import 'package:drms/components/app_drawer.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final String currentRoute;
  final Widget body;
  final FloatingActionButton? floatingActionButton;

  AppScaffold({Key? key, required this.title, required this.currentRoute, required this.body, this.floatingActionButton}) : super(key: key);

  void _onLogoutPressed(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(child: Text("Cancel"), onPressed: () => Navigator.of(context).pop(false)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Color(0xff6C63FF)),
            child: Text("Logout"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (shouldLogout == true) {
      await Session.instance.logoutUserSession();
      // Redirect to login or splash screen
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAFAFC),
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Color(0xff6C63FF)),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app_rounded, color: Color(0xff6C63FF)),
            tooltip: 'Logout',
            onPressed: () => _onLogoutPressed(context),
          ),
          SizedBox(width: 6),
        ],
      ),
      drawer: AppDrawer(currentRoute: currentRoute),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

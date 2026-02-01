import 'package:drms/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DisasterRelief',
      theme: ThemeData(
        primaryColor: Color(0xff6C63FF),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xff2D3142),
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xff2D3142),
            letterSpacing: 0.3,
          ),
          iconTheme: IconThemeData(color: Color(0xff2D3142)),
        ),

        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xff6C63FF),
          primary: Color(0xff6C63FF),
          secondary: Color(0xff5A54D1),
          tertiary: Color(0xffF4A261),
          background: Color(0xffFAFAFC),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Color(0xff2D3142),
          onSurface: Color(0xff2D3142),
          error: Color(0xffE76F51),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff6C63FF),
            foregroundColor: Colors.white,
            textStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: Size(100, 52),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            elevation: 0,
            shadowColor: Color(0xff6C63FF).withOpacity(0.3),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(0xff6C63FF),
            side: BorderSide(color: Color(0xff6C63FF), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: Size(100, 52),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xff6C63FF),
            textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xffF5F5F7),
          hintStyle: TextStyle(
            color: Color(0xff9CA3AF),
            fontWeight: FontWeight.w400,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xffE5E7EB), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xff6C63FF), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xffE76F51), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xffE76F51), width: 2),
          ),
          prefixIconColor: Color(0xff6C63FF),
          suffixIconColor: Color(0xff9CA3AF),
        ),

        // Card theme
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          shadowColor: Color(
            0x0A000000,
          ), // Equivalent to black.withOpacity(0.04)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),

        // Text styling
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xff2D3142),
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xff2D3142),
            letterSpacing: -0.3,
          ),
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xff2D3142),
            letterSpacing: 0.2,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xff2D3142),
            letterSpacing: 0.2,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xff4B5563),
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xff6B7280),
            height: 1.5,
          ),
          bodySmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xff9CA3AF),
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff6C63FF),
            letterSpacing: 0.5,
          ),
        ),

        // Divider theme
        dividerTheme: DividerThemeData(
          color: Color(0xffE5E7EB),
          thickness: 1,
          space: 24,
        ),

        // Icon theme
        iconTheme: IconThemeData(color: Color(0xff6C63FF), size: 24),

        // Scaffold and background color
        scaffoldBackgroundColor: Color(0xffFAFAFC),

        // Use Material 3
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}

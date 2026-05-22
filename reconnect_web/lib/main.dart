import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/auth/auth_provider.dart';
import 'theme/app_colors.dart';
import 'screens/auth/therapist_login_screen.dart';

void main() {
  runApp(const ReConnectWeb());
}

class ReConnectWeb extends StatelessWidget {
  const ReConnectWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Re-Connect Therapist Portal',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme().copyWith(
          textTheme: GoogleFonts.interTextTheme(
            buildAppTheme().textTheme,
          ),
        ),
        home: const TherapistLoginScreen(),
      ),
    );
  }
}

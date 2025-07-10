import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'services/gemini_service.dart';
import 'models/esim_recommender_model.dart';
import 'presentation/app.dart';
import 'presentation/services/country_service.dart';
import 'presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file
  await dotenv.load(fileName: ".env");
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
    
    // Initialize Gemini service
    GeminiService.initialize();
    print('Vertex AI/Gemini initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase/Vertex AI: $e');
  }
  
  // Initialize CountryService
  final countryService = CountryService();
  countryService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ESIMRecommenderModel()),
        ChangeNotifierProvider.value(value: countryService),
      ],
      child: const MyAppWithSplash(),
    ),
  );
}

class MyAppWithSplash extends StatelessWidget {
  const MyAppWithSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eSIM Recommender',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D69E3),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

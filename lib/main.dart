import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(apiKey: "AIzaSyC98t3s2itcyGLZW1CaZhl_HhblEwwOZBk", appId: "1:633262239415:web:6d1f9c6e12de881123e732", messagingSenderId: "633262239415",  projectId: "share-voice-77cc4",authDomain: "share-voice-77cc4.firebaseapp.com",
  
  storageBucket: "share-voice-77cc4.firebasestorage.app",
  
  measurementId: "G-0N5GW9EENZ"),
  );
  runApp(const ProviderScope(child: ActPodAdminApp()));
}

class ActPodAdminApp extends ConsumerWidget {
  const ActPodAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'ActPod Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}

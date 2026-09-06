import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    // Wrap in MultiBlocProvider (flutter_bloc) if you use Bloc/Cubit
    return MaterialApp(
      useInheritedMediaQuery: true,
      debugShowCheckedModeBanner: false,

      // Add your screen here
    );
  }
}

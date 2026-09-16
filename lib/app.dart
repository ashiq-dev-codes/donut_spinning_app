import 'package:flutter/material.dart';
import 'package:donut_spinning_app/feature/donut/presentation/page/donut_page.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Figtree',
        scaffoldBackgroundColor: Colors.black,
        brightness: Brightness.dark,
      ),
      home: const DonutScreen(),
    );
  }
}

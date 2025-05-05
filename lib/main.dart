import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/speedometer_viewmodel.dart';
import 'views/speedometer_view.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => SpeedometerViewModel()..startTracking(),
    child: const MyApp(),
  ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocímetro & Hodômetro',
      home: const SpeedometerView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

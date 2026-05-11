import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/creatures.dart';
import 'game/types.dart';
import 'screens/login_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Creature Roguelike',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/menu': (_) => const MainMenuScreen(),
        '/game': (_) => GameScreen(
              selectedCreature: Creature(
                id: 'dummy',
                name: 'Dummy',
                type: CreatureType.fire,
                rarity: Rarity.common,
                stats: Stats(hp: 100, attack: 10, defence: 10, speed: 10, spirit: 10),
                passive: const PassiveAbility(name: 'Dummy', description: 'Dummy'),
                moves: [],
              ),
            ),
      },
    );
  }
}
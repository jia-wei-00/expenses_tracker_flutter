import 'package:expenses_tracker/components/app_bar.dart';
import 'package:expenses_tracker/components/navigationbar.dart';
import 'package:expenses_tracker/constant/page_constant.dart';
import 'package:expenses_tracker/cubit/auth/auth_cubit.dart';
import 'package:expenses_tracker/cubit/route/route_cubit.dart';
import 'package:expenses_tracker/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => RouteCubit()),
        BlocProvider(create: (context) => AuthCubit()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RouteCubit, RouteState>(
      listener: (context, state) {
        if (state is RoutePush) {
          _currentIndex = state.index;
        }
      },
      builder: (context, state) {
        return MaterialApp(
          home: Scaffold(
            appBar: appBar(_currentIndex),
            body: pages[_currentIndex].page,
            bottomNavigationBar:
                navigationBar(_currentIndex, context.read<RouteCubit>()),
          ),
          theme: buildTheme(Brightness.dark),
        );
      },
    );
  }
}

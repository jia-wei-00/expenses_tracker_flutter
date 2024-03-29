import 'package:expenses_tracker/components/app_bar.dart';
import 'package:expenses_tracker/components/navigationbar.dart';
import 'package:expenses_tracker/components/snackbar.dart';
import 'package:expenses_tracker/constant/page_constant.dart';
import 'package:expenses_tracker/cubit/auth/auth_cubit.dart';
import 'package:expenses_tracker/cubit/firestore/firestore_cubit.dart';
import 'package:expenses_tracker/cubit/loan/loan_cubit.dart';
import 'package:expenses_tracker/cubit/route/route_cubit.dart';
import 'package:expenses_tracker/cubit/todo/todo_cubit.dart';
import 'package:expenses_tracker/pages/login_page.dart';
import 'package:expenses_tracker/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import './custom_animation.dart';

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
        BlocProvider(create: (context) => LoanCubit()),
        BlocProvider(create: (context) => LoanBloc()),
        BlocProvider(create: (context) => LoanCubit()),
        BlocProvider(create: (context) => FirestoreCubit()),
        BlocProvider(create: (context) => ExpensesBloc()),
        BlocProvider(create: (context) => ExpensesHistoryBloc()),
        BlocProvider(create: (context) => RunOnce()),
        BlocProvider(create: (context) => TodoCubit()),
        BlocProvider(create: (context) => TodoBloc()),
        BlocProvider(create: (context) => RunOnceTodo()),
      ],
      child: const MainApp(),
    ),
  );
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..maskType = EasyLoadingMaskType.black
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.pulse
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false
    ..customAnimation = CustomAnimation();
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    AuthCubit().checkSignin();
  }

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
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
          home: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                snackBar("Welcome ${state.user.email!.substring(0, 10)}...",
                    Colors.green, Colors.white, context);
              }

              if (state is AuthLogout) {
                snackBar(
                    "Successfully logout", Colors.green, Colors.white, context);
              }
            },
            builder: (context, state) {
              return state is AuthSuccess
                  ? Scaffold(
                      appBar: appBar(_currentIndex, context, state.user.email!),
                      body: pages[_currentIndex].page,
                      bottomNavigationBar: navigationBar(
                          _currentIndex, context.read<RouteCubit>()),
                    )
                  : const Scaffold(
                      body: Center(child: LoginPage()),
                    );
            },
          ),
          theme: buildTheme(Brightness.dark),
          builder: EasyLoading.init(),
        );
      },
    );
  }
}

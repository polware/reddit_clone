import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_message.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/controller/auth_controller.dart';
import 'package:reddit_clone/models/user_model.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';
import 'app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Paquetes para Dart y Flutter: https://pub.dev/
/// Nota: UI conecta con Controllers, y Controllers conectan con Repositories

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(child: MyApp())
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;

  void getData(WidgetRef ref, User data) async {
    userModel = await ref.watch(authControllerProvider.notifier).getUserData(data.uid).first;
    ref.read(userProvider.notifier).update((state) => userModel);
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    //Navigator.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateChangeProvider).when(
      data: (data) =>
          MaterialApp.router(
            debugShowCheckedModeBanner: false, // Quitar de pantalla el baner superior "Debug"
            title: 'Reddit Demo',
            theme: ref.watch(themeNotifierProvider),
            routerDelegate: RoutemasterDelegate( // Instalar "flutter pub add routemaster" (pub.dev)
              routesBuilder: (context) {
                if(data != null) {
                  getData(ref, data);
                  if(userModel != null) {
                    return loggedInRoute;
                  }
                }
                return loggedOutRoute;
              },
            ),
            routeInformationParser: const RoutemasterParser(),
          ),
      error: (error, stackTrace) => ErrorMessage(error: error.toString()),
      loading: () => const Loader(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/features/controller/auth_controller.dart';
import '../../core/common/sign_in_button.dart';
import '../../core/utils.dart';

class Login extends ConsumerWidget {
  const Login({super.key});

  void signInAsGuest(WidgetRef ref, BuildContext context) { /** Agregar acceso Anónimo en Firebase Authentication */
    ref.read(authControllerProvider.notifier).signInAsGuest(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);
    final authError = ref.watch(authErrorProvider);

    // Mostrar el SnackBar en caso de error
    if (authError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBar(context, authError);
        ref.read(authErrorProvider.notifier).state = null;  // Limpiar error después de mostrarlo
      });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Center(
          child: Image.asset(
            Constants.logoPath,
            height: 40,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => signInAsGuest(ref, context),
            child: const Text(
              'Continue as Guest',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: isLoading
          ? const Loader()
          : Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            'Dive into anything',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              Constants.loginEmotePath,
              height: 400,
            ),
          ),
          const SizedBox(height: 20),
          const SignInButton(),
        ],
      ),
    );
  }
}

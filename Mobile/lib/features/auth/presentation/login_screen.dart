import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../../../core/l10n/generated/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _onLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isNotEmpty && password.isNotEmpty) {
      ref.read(loginProvider.notifier).login(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final l10n = AppLocalizations.of(context)!;

    // Listen to state changes to handle errors
    ref.listen<AsyncValue<void>>(loginProvider, (prev, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error.toString())),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginButton)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(hintText: l10n.emailHint),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(hintText: l10n.passwordHint),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (loginState.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _onLogin,
                child: Text(l10n.loginButton),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/register'),
              child: Text(l10n.registerButton),
            ),
          ],
        ),
      ),
    );
  }
}

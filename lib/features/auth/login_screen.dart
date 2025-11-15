import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/controllers/app_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  double _strength = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggle() => setState(() => _obscure = !_obscure);

  void _onPasswordChanged(String value) {
    final length = value.length;
    setState(() {
      _strength = (length / 16).clamp(0, 1).toDouble();
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      await widget.controller.updateLoginState(true);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  Future<void> _loginAsGuest() => widget.controller.updateLoginState(true).then((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      Text(loc.translate('login'), style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: loc.translate('email')),
                        validator: (value) => value != null && value.contains('@') ? null : 'Invalid email',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: loc.translate('password'),
                          suffixIcon: IconButton(onPressed: _toggle, icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off)),
                        ),
                        obscureText: _obscure,
                        onChanged: _onPasswordChanged,
                        validator: (value) => value != null && value.length >= 6 ? null : 'Too short',
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: _strength == 0 ? null : _strength),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                          child: Text(loc.translate('forgot_password')),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _submit, child: Text(loc.translate('login'))),
                      const SizedBox(height: 8),
                      TextButton(onPressed: _loginAsGuest, child: Text(loc.translate('login_guest'))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                  child: Text(loc.translate('register')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

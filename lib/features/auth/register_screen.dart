import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/controllers/app_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  double _strength = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _toggle() => setState(() => _obscure = !_obscure);

  void _onPasswordChanged(String value) {
    setState(() {
      _strength = (value.length / 16).clamp(0, 1).toDouble();
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      await widget.controller.updateLoginState(true);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('register'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (value) => value != null && value.isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                decoration: const InputDecoration(labelText: 'Confirm password'),
                obscureText: _obscure,
                validator: (value) => value == _passwordController.text ? null : 'Password mismatch',
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _submit, child: Text(loc.translate('register'))),
            ],
          ),
        ),
      ),
    );
  }
}

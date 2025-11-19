import 'package:flutter/material.dart';
import 'package:smartmushroom_app/core/auth/auth_repository.dart';
import 'package:smartmushroom_app/core/network/api_exception.dart';
import 'package:smartmushroom_app/core/theme/app_colors.dart';
import 'package:smartmushroom_app/screen/forgot_password_screen.dart';
import 'package:smartmushroom_app/screen/home_page.dart';
import 'package:smartmushroom_app/screen/ip_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _autoValidate = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe um e-mail';
    }

    final emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Formato de e-mail inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe a senha';
    }
    if (value.trim().length < 6) {
      return 'A senha deve conter pelo menos 6 caracteres';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    final formState = _formKey.currentState;
    if (formState == null) return;

    if (!formState.validate()) {
      setState(() => _autoValidate = true);
      return;
    }

    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final senha = _passwordController.text.trim();

    try {
      final session = await _authRepository.login(email: email, senha: senha);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final userName = session.user?.nome ?? email;
      _showMessage('Bem-vindo, $userName');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on ApiException catch (err) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showMessage(err.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showMessage('Erro inesperado ao entrar. Tente novamente.', isError: true);
    }
  }

  void _openForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  Future<void> _openConfigIp() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ConfigIPPage()),
    );
    if (!mounted) return;
    if (result != null && result.isNotEmpty) {
      _showMessage('IP do servidor atualizado para $result');
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _openConfigIp,
                  icon: const Icon(Icons.route_outlined),
                  label: const Text('Configurar IP do servidor'),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    side: const BorderSide(color: AppColors.accent, width: 1.2),
                    foregroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bem-vindo de volta',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Acesse sua conta para acompanhar seus cultivos.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode:
                      _autoValidate ? AutovalidateMode.onUserInteraction : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        validator: _validatePassword,
                        onFieldSubmitted: (_) => _handleLogin(),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isSubmitting ? null : _openForgotPassword,
                          child: const Text('Esqueci minha senha'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Entrar'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      size: 54,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'SmartMushroom',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

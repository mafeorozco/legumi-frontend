import 'package:flutter/material.dart';
import 'package:legumi/core/services/auth_service.dart';
import 'package:legumi/core/services/api_client.dart';
import 'package:legumi/core/theme/app_theme.dart';
import 'package:legumi/features/home/presentation/screens/inicio_screen.dart';
import 'package:legumi/features/auth/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService        = AuthService();
  bool _obscure = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Configurar callback de sesión expirada
    ApiClient().onSessionExpired = () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
      }
    };
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    setState(() => _loading = true);

    final ok = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InicioScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        // Panel izquierdo — verde decorativo (sin cambios)
        Expanded(
          child: Container(
            color: AppColors.green800,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.green600,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.eco_rounded,
                    color: Colors.white, size: 48),
                ),
                const SizedBox(height: 24),
                const Text('Legumi',
                  style: TextStyle(color: Colors.white, fontSize: 40,
                    fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                const Text('Control inteligente de plagas',
                  style: TextStyle(color: AppColors.green100, fontSize: 16)),
                const SizedBox(height: 48),
                Container(
                  width: 280,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.green600.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(children: [
                    _FeatureRow(icon: Icons.camera_alt_outlined,
                      text: 'Detecta plagas con IA'),
                    SizedBox(height: 12),
                    _FeatureRow(icon: Icons.home_work_outlined,
                      text: 'Gestiona tus invernaderos'),
                    SizedBox(height: 12),
                    _FeatureRow(icon: Icons.bar_chart_outlined,
                      text: 'Historial de análisis'),
                  ]),
                ),
              ],
            ),
          ),
        ),

        // Panel derecho — formulario (sin cambios visuales)
        SizedBox(
          width: 480,
          child: Container(
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bienvenido de nuevo',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    const Text('Ingresa tus credenciales para continuar',
                      style: TextStyle(fontSize: 14,
                        color: AppColors.textSecondary)),
                    const SizedBox(height: 36),

                    const Text('Correo electrónico',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.mail_outline, size: 18,
                          color: AppColors.textSecondary),
                        hintText: 'correo@ejemplo.com',
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('Contraseña',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, size: 18,
                          color: AppColors.textSecondary),
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                            size: 18, color: AppColors.textSecondary),
                          onPressed: () =>
                            setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                          ? const SizedBox(height: 18, width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                          : const Text('Ingresar'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(children: const [
                      Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('o', style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13))),
                      Expanded(child: Divider(color: AppColors.border)),
                    ]),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(context,
                          MaterialPageRoute(
                            builder: (_) => const SingUpPage())),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.green600,
                          side: const BorderSide(color: AppColors.green600),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Crear cuenta',
                          style: TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: AppColors.green100, size: 18),
      const SizedBox(width: 12),
      Text(text,
        style: const TextStyle(color: Colors.white, fontSize: 14)),
    ]);
  }
}
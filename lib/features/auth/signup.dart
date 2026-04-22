import 'package:flutter/material.dart';
import 'package:legumi/core/services/auth_service.dart';
import 'package:legumi/features/auth/login.dart';

class SingUpPage extends StatefulWidget {
  const SingUpPage({super.key});

  @override
  State<SingUpPage> createState() => _SingUpPageState();
}

class _SingUpPageState extends State<SingUpPage> {
  final _nameController            = TextEditingController();
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService               = AuthService();
  bool _obscure  = true;
  bool _loading  = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name            = _nameController.text.trim();
    final email           = _emailController.text.trim();
    final password        = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty ||
        password.isEmpty || confirmPassword.isEmpty) {
      _showSnack('Por favor completa todos los campos');
      return;
    }

    if (password != confirmPassword) {
      _showSnack('Las contraseñas no coinciden');
      return;
    }

    if (password.length < 8) {
      _showSnack('La contraseña debe tener al menos 8 caracteres');
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.register(
        name    : name,
        email   : email,
        password: password,
      );

      if (!mounted) return;
      _showSnack('Cuenta creada. Inicia sesión');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 30, vertical: 50),
            child: Column(children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green.shade100,
                child: const Icon(Icons.eco, size: 50, color: Colors.green),
              ),
              const SizedBox(height: 20),
              const Text('Regístrate en Legumi',
                style: TextStyle(color: Colors.black87, fontSize: 26,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [BoxShadow(
                    color: Colors.black12, blurRadius: 10,
                    offset: Offset(0, 4))],
                ),
                child: Column(children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                          ? Icons.visibility
                          : Icons.visibility_off),
                        onPressed: () =>
                          setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Confirmar contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                          ? Icons.visibility
                          : Icons.visibility_off),
                        onPressed: () =>
                          setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: _loading ? null : _submit,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(colors: [
                          Colors.green.shade700,
                          Colors.green.shade500,
                        ]),
                      ),
                      child: Center(child: _loading
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                        : const Text('Registrarse',
                            style: TextStyle(color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold))),
                    ),
                  ),
                  const SizedBox(height: 15),

                  GestureDetector(
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPage())),
                    child: const Text('¿Ya tienes cuenta? Inicia sesión',
                      style: TextStyle(color: Colors.green,
                        decoration: TextDecoration.underline)),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
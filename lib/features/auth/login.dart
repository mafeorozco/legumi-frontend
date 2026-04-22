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
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _auth = AuthService();

  bool _obscure = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Si el token expira, regresar al login
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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Envía las credenciales al servidor
  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Completa todos los campos');
      return;
    }

    setState(() => _loading = true);
    final ok = await _auth.login(email, password);
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InicioScreen()),
      );
    } else {
      _showSnack('Usuario o contraseña incorrectos');
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isMobile ? _buildMobile() : _buildDesktop(),
    );
  }

  //  Vista móvil: cabecera + formulario en columna 
  Widget _buildMobile() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera verde con logo y nombre de la app
            Container(
              color: AppColors.green800,
              padding: const EdgeInsets.fromLTRB(24, 52, 24, 40),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.green600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Legumi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Control inteligente de plagas',
                    style: TextStyle(color: AppColors.green100, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Formulario de login
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Bienvenido de nuevo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ingresa tus credenciales para continuar',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildFields(),
                  const SizedBox(height: 28),
                  _buildPrimaryButton(),
                  const SizedBox(height: 16),
                  _buildOrDivider(),
                  const SizedBox(height: 16),
                  _buildSecondaryButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  Vista escritorio: panel verde | panel formulario 
  Widget _buildDesktop() {
    return Row(
      children: [
        // Panel izquierdo — decorativo con beneficios
        Expanded(
          child: Container(
            color: AppColors.green800,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.green600,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Legumi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Control inteligente de plagas',
                  style: TextStyle(color: AppColors.green100, fontSize: 16),
                ),
                const SizedBox(height: 52),
                // Tarjeta con los 3 beneficios principales
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.green600.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Column(
                    children: [
                      _FeatureRow(
                        icon: Icons.camera_alt_outlined,
                        text: 'Detecta plagas con IA',
                      ),
                      SizedBox(height: 14),
                      _FeatureRow(
                        icon: Icons.home_work_outlined,
                        text: 'Gestiona tus invernaderos',
                      ),
                      SizedBox(height: 14),
                      _FeatureRow(
                        icon: Icons.bar_chart_outlined,
                        text: 'Historial de análisis',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Panel derecho — formulario centrado
        SizedBox(
          width: 460,
          child: Container(
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 52),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Bienvenido de nuevo',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ingresa tus credenciales para continuar',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 36),
                    _buildFields(),
                    const SizedBox(height: 32),
                    _buildPrimaryButton(),
                    const SizedBox(height: 16),
                    _buildOrDivider(),
                    const SizedBox(height: 16),
                    _buildSecondaryButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  //  Campos email y contraseña 
  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Correo electrónico'),
        const SizedBox(height: 8),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            prefixIcon: Icon(
              Icons.mail_outline,
              size: 18,
              color: AppColors.textSecondary,
            ),
            hintText: 'correo@ejemplo.com',
          ),
        ),
        const SizedBox(height: 18),
        const _Label('Contraseña'),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscure,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _login(),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.lock_outline,
              size: 18,
              color: AppColors.textSecondary,
            ),
            hintText: '••••••••',
            suffixIcon: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
      ],
    );
  }

  //  Botón principal: Ingresar 
  Widget _buildPrimaryButton() => SizedBox(
    height: 50,
    child: ElevatedButton(
      onPressed: _loading ? null : _login,
      child: _loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Ingresar',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
    ),
  );

  //  Separador con "o" 
  Widget _buildOrDivider() => const Row(
    children: [
      Expanded(child: Divider(color: AppColors.border)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Text(
          'o',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
      Expanded(child: Divider(color: AppColors.border)),
    ],
  );

  //  Botón secundario: Crear cuenta 
  Widget _buildSecondaryButton() => SizedBox(
    height: 50,
    child: OutlinedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SingUpPage()),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.green600,
        side: const BorderSide(color: AppColors.green600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'Crear cuenta',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

//  Etiqueta pequeña sobre un campo 
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    ),
  );
}

//  Fila de beneficio en el panel verde 
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.green100, size: 17),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

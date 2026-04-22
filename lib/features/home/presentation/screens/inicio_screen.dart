import 'package:flutter/material.dart';
import 'package:legumi/core/services/auth_service.dart';
import 'package:legumi/core/services/greenhouses_services.dart';
import 'package:legumi/core/theme/app_theme.dart';
import 'package:legumi/features/analyses/AnalysePest.dart';
import 'package:legumi/features/auth/login.dart';
import 'package:legumi/features/greenhouses/greenhouses.dart';
import 'package:legumi/shared/widgets/menu_inferior.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _authService        = AuthService();
  final _greenhousesService = GreenhousesService();

  String _userName         = 'Usuario';
  int    _totalGreenhouses = 0;
  bool   _loadingStats     = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Cargar nombre desde secure storage
    final name = await _authService.getUserName();
    if (mounted) setState(() => _userName = name ?? 'Usuario');

    // Cargar stats de invernaderos
    try {
      final greenhouses = await _greenhousesService.fetchMyGreenhouses();
      if (mounted) {
        setState(() {
          _totalGreenhouses = greenhouses.length;
          _loadingStats     = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout(); // revoca token en backend + limpia storage
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        // TopBar
        Container(
          height: 64,
          color: AppColors.green800,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.green600,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.eco_rounded,
                color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Legumi',
              style: TextStyle(color: Colors.white, fontSize: 18,
                fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('¡Hola, $_userName!',
              style: const TextStyle(
                color: AppColors.green100, fontSize: 14)),
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.green600,
              child: Text(
                _userName.isNotEmpty
                  ? _userName[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white,
                  fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),

        Expanded(
          child: Row(children: [
            // Sidebar
            Container(
              width: 220,
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(
                vertical: 24, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MENÚ',
                    style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  _SidebarItem(
                    icon: Icons.home_outlined,
                    label: 'Inicio',
                    active: true,
                    onTap: () {},
                  ),
                  _SidebarItem(
                    icon: Icons.camera_alt_outlined,
                    label: 'Escanear planta',
                    onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AnalysePestScreen())),
                  ),
                  _SidebarItem(
                    icon: Icons.home_work_outlined,
                    label: 'Invernaderos',
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                        builder: (_) => const GreenhousesPage())),
                  ),
                  _SidebarItem(
                    icon: Icons.history_outlined,
                    label: 'Historial',
                    onTap: () {},
                  ),
                  const Spacer(),
                  const Divider(color: AppColors.border),
                  _SidebarItem(
                    icon: Icons.logout_outlined,
                    label: 'Cerrar sesión',
                    onTap: _logout,
                  ),
                ],
              ),
            ),

            Container(width: 0.5, color: AppColors.border),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.green800,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('¡Bienvenido, $_userName!',
                                style: const TextStyle(
                                  color: AppColors.green100,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              const Text(
                                'Realiza control de\nlas plagas de tus plantas',
                                style: TextStyle(color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2)),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.camera_alt_outlined, size: 18),
                                label: const Text('Escanear ahora'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.green800,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12)),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          'assets/images/welcome_image.png',
                          height: 160,
                          errorBuilder: (_, __, ___) => Container(
                            width: 160, height: 160,
                            decoration: BoxDecoration(
                              color: AppColors.green600.withOpacity(0.3),
                              shape: BoxShape.circle),
                            child: const Icon(Icons.eco_rounded,
                              color: Colors.white, size: 80)),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 28),

                    // Stats
                    Row(children: [
                      Expanded(child: _StatCard(
                        label: 'Invernaderos',
                        value: _loadingStats
                          ? '...' : '$_totalGreenhouses',
                        icon : Icons.home_work_outlined,
                        color: AppColors.green50,
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _StatCard(
                        label: 'Análisis realizados',
                        value: '—',
                        icon : Icons.science_outlined,
                        color: const Color(0xFFFFF3E0),
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _StatCard(
                        label: 'Plagas detectadas',
                        value: '—',
                        icon : Icons.bug_report_outlined,
                        color: const Color(0xFFFCEBEB),
                      )),
                    ]),

                    const SizedBox(height: 28),

                    // Acciones rápidas
                    const Text('Acciones rápidas',
                      style: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                    const SizedBox(height: 16),

                    Row(children: [
                      Expanded(child: _ActionCard(
                        icon    : Icons.camera_alt_outlined,
                        iconBg  : AppColors.green50,
                        title   : 'Escanear planta',
                        subtitle: 'Detecta plagas con IA',
                        onTap   : () {},
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _ActionCard(
                        icon    : Icons.home_work_outlined,
                        iconBg  : const Color(0xFFFFF3E0),
                        title   : 'Mis invernaderos',
                        subtitle: 'Administra tus espacios',
                        onTap   : () => Navigator.push(context,
                          MaterialPageRoute(
                            builder: (_) => const GreenhousesPage())),
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _ActionCard(
                        icon    : Icons.history_outlined,
                        iconBg  : const Color(0xFFF3E5F5),
                        title   : 'Historial',
                        subtitle: 'Ver análisis anteriores',
                        onTap   : () {},
                      )),
                    ]),
                  ],
                ),
              ),
            ),
          ]),
        ),

        const MenuInferior(),
      ]),
    );
  }
}

// ──────────────────────────────────────────────────────────
// WIDGETS LOCALES (sin cambios)
// ──────────────────────────────────────────────────────────

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.green50 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Icon(icon, size: 18,
            color: active
              ? AppColors.green600 : AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(
            fontSize: 14,
            fontWeight: active
              ? FontWeight.w600 : FontWeight.w400,
            color: active
              ? AppColors.green600 : AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label, required this.value,
    required this.icon,  required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.green800, size: 22),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(fontSize: 24,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(label, style: const TextStyle(fontSize: 12,
            color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title, subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,    required this.iconBg,
    required this.title,   required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.green800, size: 22),
            ),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 15,
              fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 13,
              color: AppColors.textSecondary)),
          ]),
      ),
    );
  }
}
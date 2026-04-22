import 'package:flutter/material.dart';
import 'package:legumi/core/services/auth_service.dart';
import 'package:legumi/core/services/greenhouses_services.dart';
import 'package:legumi/core/theme/app_theme.dart';
import 'package:legumi/features/auth/login.dart';
import 'package:legumi/features/greenhouses/greenhouses.dart';
import 'package:legumi/shared/widgets/menu_inferior.dart';
import 'package:legumi/features/profile/profile_page.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _auth = AuthService();
  final _ghService = GreenhousesService();

  String _userName = 'Usuario';
  int _totalGreenhouses = 0;
  bool _loadingStats = true;

  // Sección activa: 0=Inicio 1=Escanear 2=Invernaderos 3=Historial 4=Reportes
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final name = await _auth.getUserName();
    if (mounted) setState(() => _userName = name ?? 'Usuario');
    try {
      final list = await _ghService.fetchMyGreenhouses();
      if (mounted)
        setState(() {
          _totalGreenhouses = list.length;
          _loadingStats = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  // Maneja la navegación — invernaderos abre nueva pantalla
  void _navigate(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GreenhousesPage()),
      );
      return;
    }
    setState(() => _activeIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      // MenuInferior se oculta solo en escritorio — lógica interna del widget
      bottomNavigationBar: MenuInferior(
        currentIndex: _activeIndex,
        onTap: _navigate,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(userName: _userName, isMobile: isMobile, onLogout: _logout),
            Expanded(
              child: isMobile
                  ? _MobileBody(
                      userName: _userName,
                      total: _totalGreenhouses,
                      loading: _loadingStats,
                      onNav: _navigate,
                    )
                  : _DesktopBody(
                      userName: _userName,
                      total: _totalGreenhouses,
                      loading: _loadingStats,
                      activeIndex: _activeIndex,
                      onNav: _navigate,
                      onLogout: _logout,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// BARRA SUPERIOR
class _TopBar extends StatelessWidget {
  final String userName;
  final bool isMobile;
  final VoidCallback onLogout;
  const _TopBar({
    required this.userName,
    required this.isMobile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      color: AppColors.green800,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.green600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          const Text(
            'Legumi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (!isMobile) ...[
            Text(
              'Hola, $userName',
              style: const TextStyle(color: AppColors.green100, fontSize: 13),
            ),
            const SizedBox(width: 12),
          ],
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.green600,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (isMobile) ...[
            const SizedBox(width: 2),
            IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.logout_outlined,
                color: Colors.white70,
                size: 19,
              ),
              onPressed: onLogout,
            ),
          ],
        ],
      ),
    );
  }
}

// CONTENIDO MÓVIL
class _MobileBody extends StatelessWidget {
  final String userName;
  final int total;
  final bool loading;
  final ValueChanged<int> onNav;
  const _MobileBody({
    required this.userName,
    required this.total,
    required this.loading,
    required this.onNav,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner compacto de bienvenida
          _Banner(userName: userName, compact: true),
          const SizedBox(height: 14),

          // Tarjetas de números — fila de 3
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Invernaderos',
                  value: loading ? '…' : '$total',
                  icon: Icons.home_work_outlined,
                  bgColor: AppColors.green50,
                  iconColor: AppColors.green600,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _StatCard(
                  label: 'Análisis',
                  value: '—',
                  icon: Icons.science_outlined,
                  bgColor: Color(0xFFFFF3E0),
                  iconColor: Color(0xFF8B6200),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _StatCard(
                  label: 'Plagas',
                  value: '—',
                  icon: Icons.bug_report_outlined,
                  bgColor: Color(0xFFFCEBEB),
                  iconColor: Color(0xFF8B1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Sección acciones rápidas
          const Text(
            'Acciones rápidas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // Dos filas de dos tarjetas compactas con icono + texto en horizontal
          Row(
            children: [
              Expanded(
                child: _CompactAction(
                  icon: Icons.camera_alt_outlined,
                  bg: AppColors.green50,
                  label: 'Escanear',
                  onTap: () => onNav(1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CompactAction(
                  icon: Icons.home_work_outlined,
                  bg: const Color(0xFFFFF3E0),
                  label: 'Invernaderos',
                  onTap: () => onNav(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _CompactAction(
                  icon: Icons.history_outlined,
                  bg: const Color(0xFFF3E5F5),
                  label: 'Historial',
                  onTap: () => onNav(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CompactAction(
                  icon: Icons.bar_chart_outlined,
                  bg: AppColors.green50,
                  label: 'Reportes',
                  onTap: () => onNav(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Actividad reciente
          const Text(
            'Actividad reciente',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const _EmptyActivity(),
        ],
      ),
    );
  }
}

// CONTENIDO ESCRITORIO
class _DesktopBody extends StatelessWidget {
  final String userName;
  final int total;
  final bool loading;
  final int activeIndex;
  final ValueChanged<int> onNav;
  final VoidCallback onLogout;
  const _DesktopBody({
    required this.userName,
    required this.total,
    required this.loading,
    required this.activeIndex,
    required this.onNav,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sidebar con resaltado dinámico según sección activa
        _Sidebar(activeIndex: activeIndex, onNav: onNav, onLogout: onLogout),
        Container(width: 0.5, color: AppColors.border),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Banner(userName: userName, compact: false),
                const SizedBox(height: 20),

                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Invernaderos',
                        value: loading ? '…' : '$total',
                        icon: Icons.home_work_outlined,
                        bgColor: AppColors.green50,
                        iconColor: AppColors.green600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: _StatCard(
                        label: 'Análisis realizados',
                        value: '—',
                        icon: Icons.science_outlined,
                        bgColor: Color(0xFFFFF3E0),
                        iconColor: Color(0xFF8B6200),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: _StatCard(
                        label: 'Plagas detectadas',
                        value: '—',
                        icon: Icons.bug_report_outlined,
                        bgColor: Color(0xFFFCEBEB),
                        iconColor: Color(0xFF8B1A1A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Acciones + Actividad lado a lado
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Acciones en lista vertical — más limpio que grid
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Acciones rápidas',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _ListAction(
                            icon: Icons.camera_alt_outlined,
                            bg: AppColors.green50,
                            title: 'Escanear planta',
                            subtitle:
                                'Detecta plagas con inteligencia artificial',
                            onTap: () => onNav(1),
                          ),
                          const SizedBox(height: 8),
                          _ListAction(
                            icon: Icons.home_work_outlined,
                            bg: const Color(0xFFFFF3E0),
                            title: 'Mis invernaderos',
                            subtitle: 'Administra y visualiza tus espacios',
                            onTap: () => onNav(2),
                          ),
                          const SizedBox(height: 8),
                          _ListAction(
                            icon: Icons.history_outlined,
                            bg: const Color(0xFFF3E5F5),
                            title: 'Historial',
                            subtitle: 'Revisa análisis anteriores',
                            onTap: () => onNav(3),
                          ),
                          const SizedBox(height: 8),
                          _ListAction(
                            icon: Icons.bar_chart_outlined,
                            bg: AppColors.green50,
                            title: 'Reportes',
                            subtitle: 'Estadísticas y tendencias detalladas',
                            onTap: () => onNav(4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Actividad reciente al lado derecho
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Actividad reciente',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 12),
                          _EmptyActivity(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// SIDEBAR — resalta el ítem activo con verde
class _Sidebar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onNav;
  final VoidCallback onLogout;
  const _Sidebar({
    required this.activeIndex,
    required this.onNav,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // Definición de todos los ítems del menú
    const items = [
      (0, Icons.home_outlined, Icons.home, 'Inicio'),
      (1, Icons.camera_alt_outlined, Icons.camera_alt, 'Escanear planta'),
      (2, Icons.home_work_outlined, Icons.home_work, 'Invernaderos'),
      (3, Icons.history_outlined, Icons.history, 'Historial'),
      (4, Icons.bar_chart_outlined, Icons.bar_chart, 'Reportes'),
    ];

    return Container(
      width: 210,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: Text(
              'MENÚ',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Ítems con fondo verde si están activos
          for (final item in items)
            _NavItem(
              icon: activeIndex == item.$1 ? item.$3 : item.$2,
              label: item.$4,
              active: activeIndex == item.$1,
              onTap: () => onNav(item.$1),
            ),

          const Spacer(),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),
          _NavItem(
            icon: Icons.logout_outlined,
            label: 'Cerrar sesión',
            active: false,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

// BANNER DE BIENVENIDA
class _Banner extends StatelessWidget {
  final String userName;
  final bool compact;
  const _Banner({required this.userName, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.green900, AppColors.green700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(compact ? 14 : 18),
      ),
      padding: EdgeInsets.all(compact ? 18 : 26),
      child: compact ? _mobileBanner() : _desktopBanner(),
    );
  }

  Widget _mobileBanner() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '¡Hola, $userName! 👋',
        style: const TextStyle(
          color: AppColors.green100,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 5),
      const Text(
        '¿Listo para revisar\ntus plantas hoy?',
        style: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          height: 1.25,
          letterSpacing: -0.3,
        ),
      ),
      const SizedBox(height: 14),
      ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.camera_alt_outlined, size: 14),
        label: const Text('Escanear ahora'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.green800,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
      ),
    ],
  );

  Widget _desktopBanner() => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenido, $userName! 👋',
              style: const TextStyle(
                color: AppColors.green100,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Controla las plagas\nde tus plantas con IA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Detecta problemas antes de que sea tarde.',
              style: TextStyle(color: AppColors.green100, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt_outlined, size: 16),
              label: const Text('Escanear ahora'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.green800,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 16),
      // Decoración circular del banner
      Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.green600.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 40),
          ),
        ),
      ),
    ],
  );
}

// TARJETA DE ESTADÍSTICA
class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color bgColor, iconColor;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      // Horizontal: ícono a la izquierda, número y etiqueta a la derecha
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// TARJETA COMPACTA — móvil: ícono + texto en fila
class _CompactAction extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final String label;
  final VoidCallback onTap;
  const _CompactAction({
    required this.icon,
    required this.bg,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.green800, size: 15),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ACCIÓN EN LISTA — escritorio: ícono + título + subtítulo + flecha
class _ListAction extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final String title, subtitle;
  final VoidCallback onTap;
  const _ListAction({
    required this.icon,
    required this.bg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: AppColors.green800, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 11,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ACTIVIDAD VACÍA
class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.history_outlined,
              color: AppColors.green400,
              size: 20,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sin actividad aún',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Los análisis aparecerán aquí',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ÍTEM DEL SIDEBAR — verde si está activo, gris si no
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.green50 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 17,
              color: active ? AppColors.green600 : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? AppColors.green600 : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

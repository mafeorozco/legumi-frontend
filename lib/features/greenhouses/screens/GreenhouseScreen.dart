import 'package:flutter/material.dart';
import 'package:legumi/core/theme/app_theme.dart';
import 'package:legumi/features/analyses/AnalysePest.dart';
import 'package:legumi/features/auth/login.dart';
import 'package:legumi/features/greenhouses/components/AddGreenhouseCard.dart';
import 'package:legumi/features/greenhouses/components/GreenhouseCard.dart';
import 'package:legumi/features/historyAnalyses/screens/HistoryAnalysesScreen.dart';
import 'package:legumi/features/home/presentation/screens/inicio_screen.dart';
import 'package:legumi/features/profile/profile_page.dart';
import 'package:legumi/shared/widgets/menu_inferior.dart';

class GreenhousesScreen extends StatefulWidget {
  const GreenhousesScreen({super.key});

  @override
  State<GreenhousesScreen> createState() => _GreenhousesScreenState();
}

class _GreenhousesScreenState extends State<GreenhousesScreen> {
  int _activeIndex = 2; // ← 2 porque esta es la pantalla de Invernaderos

  Future<void> _logout() async {
    // tu lógica
  }

  void _navigate(int index) {
    if (index == _activeIndex) return; // ya estás aquí, no hagas nada

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InicioScreen()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AnalysePestScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GreenhousesScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HistoryAnalysesScreen()),
      );
    }

    setState(() => _activeIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: MenuInferior(
        currentIndex: _activeIndex,
        onTap: _navigate,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56 + kToolbarHeight - 56),
        child: SafeArea(
          child: _TopBar(userName: 'Maria', isMobile: true, onLogout: _logout),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 20, 18, 12),
            child: Row(
              children: [
                Icon(Icons.arrow_back, size: 22, color: Colors.black87),
                SizedBox(width: 6),
                Text(
                  'Mis invernaderos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const AddGreenhouseCard(),
                const SizedBox(height: 14),
                GreenhouseCard(name: 'Invernadero 1', rows: 6, columns: 8),
                const SizedBox(height: 14),
                GreenhouseCard(name: 'Invernadero 2', rows: 3, columns: 4),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
      color: Color(0xFF16372C),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Color(0xFFADD1A5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4), // ← aumenta este valor para hacerla más pequeña
              child: Image.asset(
                'assets/images/logo_legumi.png',
                fit: BoxFit.contain,
              ),
            ),
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
              backgroundColor: Color(0xFFADD1A5),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Color(0xFF16372C),
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
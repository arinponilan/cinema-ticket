import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String get _apiBaseUrl {
  const configuredUrl = String.fromEnvironment('API_BASE_URL');
  if (configuredUrl.isNotEmpty) {
    return configuredUrl;
  }

  return defaultTargetPlatform == TargetPlatform.android
      ? 'http://10.0.2.2:8081'
      : 'http://localhost:8081';
}

void main() {
  runApp(const CinemaApp());
}

class CinemaApp extends StatelessWidget {
  const CinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cinema Ticket',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFFC107),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC107),
          brightness: Brightness.dark,
          primary: const Color(0xFFFFC107),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

// --- REGISTER PAGE ---
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAdmin = false;
  bool _isLoading = false;

  Future<void> _register() async {
    final email = _emailController.text;
    if (!email.endsWith('@gmail.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email harus menggunakan @gmail.com!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'email': email,
          'password': _passwordController.text,
          'admin': _isAdmin,
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registrasi Gagal!')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const Text(
              "Create Account",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const Text(
              "Join the premiere cinema club",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 50),
            _buildTextField(_nameController, "Full Name", Icons.person),
            const SizedBox(height: 20),
            _buildTextField(_emailController, "Email", Icons.email),
            const SizedBox(height: 20),
            _buildTextField(
              _passwordController,
              "Password",
              Icons.lock,
              obscure: true,
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text(
                "Register as Admin?",
                style: TextStyle(color: Colors.white),
              ),
              value: _isAdmin,
              onChanged: (val) => setState(() => _isAdmin = val),
              activeThumbColor: Colors.amber,
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.amber)
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "REGISTER",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.amber),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// --- LOGIN PAGE ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final loginEmail = _emailController.text;
    if (!loginEmail.endsWith('@gmail.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email harus menggunakan @gmail.com!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': loginEmail,
          'password': _passwordController.text,
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        String role = userData['role'] ?? 'Customer';
        String name = userData['name'];
        String email = userData['email'] ?? loginEmail;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MainContainer(userName: name, email: email, role: role),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Gagal! Email/Password salah.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.movie_filter, size: 100, color: Colors.amber),
              const SizedBox(height: 20),
              const Text(
                "CINEMA TICKET",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                "PREMIERE ACCESS",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 50),
              _buildTextField(_emailController, "Email", Icons.email),
              const SizedBox(height: 20),
              _buildTextField(
                _passwordController,
                "Password",
                Icons.lock,
                obscure: true,
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.amber)
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "SIGN IN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                ),
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(color: Colors.amber),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.amber),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// --- MAIN CONTAINER ---
class MainContainer extends StatefulWidget {
  final String userName;
  final String email;
  final String role;
  const MainContainer({
    super.key,
    required this.userName,
    required this.email,
    required this.role,
  });

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(userName: widget.userName, role: widget.role),
      const PlaceholderPage(title: "Search Movies", icon: Icons.search),
      const PlaceholderPage(
        title: "My Bookings",
        icon: Icons.confirmation_number_outlined,
      ),
      ProfilePage(
        userName: widget.userName,
        email: widget.email,
        role: widget.role,
        onBack: () => setState(() => _selectedIndex = 0),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _ProfileBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class _ProfileBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _ProfileBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_outlined, label: "Home"),
      _NavItem(icon: Icons.search, label: "Search"),
      _NavItem(icon: Icons.confirmation_number_outlined, label: "Tickets"),
      _NavItem(icon: Icons.person_outline, label: "Profile"),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 86,
        padding: const EdgeInsets.fromLTRB(26, 12, 26, 12),
        decoration: const BoxDecoration(
          color: Color(0xFF3B3936),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = selectedIndex == index;

            return InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(22),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 72 : 56,
                height: 54,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF5F347A)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      color: selected ? ProfilePage._gold : Colors.white70,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      maxLines: 1,
                      style: TextStyle(
                        color: selected ? ProfilePage._gold : Colors.white70,
                        fontSize: 10,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

// --- PROFILE PAGE ---
class ProfilePage extends StatefulWidget {
  final String userName;
  final String email;
  final String role;
  final VoidCallback? onBack;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.email,
    required this.role,
    this.onBack,
  });

  static const _gold = Color(0xFFE5C64A);
  static const _page = Color(0xFF0D0D0D);
  static const _panel = Color(0xFF1D1B1C);
  static const _stat = Color(0xFF211B2B);
  static const _purple = Color(0xFF6F5392);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    final roleLabel = widget.role.toUpperCase();

    return Scaffold(
      backgroundColor: ProfilePage._page,
      appBar: _ProfileTopBar(
        title: "PROFILE",
        centerTitle: true,
        onBack: widget.onBack,
        action: IconButton(
          icon: const Icon(Icons.settings_outlined, color: ProfilePage._gold),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile Settings coming soon")),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF181613), ProfilePage._page, ProfilePage._page],
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 116,
                        height: 116,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ProfilePage._gold,
                            width: 3,
                          ),
                        ),
                        child: const ClipOval(child: _ProfileAvatarIcon()),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 10,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: ProfilePage._gold,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ProfilePage._page,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Color(0xFF171717),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.userName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFE7E4E4),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF8C8888),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ProfilePage._purple,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      roleLabel,
                      style: const TextStyle(
                        color: Color(0xFFE8DDF1),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                ),
                if (_statusMessage != null) ...[
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF182719),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF3F7D43)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF7DD87F),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _statusMessage!,
                            style: const TextStyle(
                              color: Color(0xFFDBF7DD),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 38),
                const _StatsSection(),
                const SizedBox(height: 38),
                const Text(
                  "ACCOUNT SETTINGS",
                  style: TextStyle(
                    color: Color(0xFF77706C),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: ProfilePage._panel,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.lock_outline,
                        title: "Change Password",
                        onTap: _openChangePassword,
                      ),
                      _SettingsTile(
                        icon: Icons.notifications_none,
                        title: "Notifications",
                        onTap: () =>
                            _openProfileMenu(const NotificationsPage()),
                      ),
                      _SettingsTile(
                        icon: Icons.payments_outlined,
                        title: "Transaction History",
                        onTap: () =>
                            _openProfileMenu(const TransactionHistoryPage()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text("LOGOUT"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE9B8AE),
                    side: const BorderSide(color: Color(0xFF441111)),
                    backgroundColor: const Color(0xFF21090B),
                    minimumSize: const Size(double.infinity, 62),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openChangePassword() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordPage(email: widget.email),
      ),
    );
    if (saved == true && mounted) {
      setState(() => _statusMessage = "Change password succeeded");
    }
  }

  void _openProfileMenu(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}

class _ProfileAvatarIcon extends StatelessWidget {
  const _ProfileAvatarIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2D1D3B),
      child: const Center(
        child: Icon(Icons.person, color: ProfilePage._gold, size: 72),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 104,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: ProfilePage._stat,
        borderRadius: BorderRadius.circular(12),
      ),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  color: ProfilePage._gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  color: Color(0xFFEAE7EA),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final cardWidth = (constraints.maxWidth - spacing) / 2;

        if (cardWidth < 170) {
          return const Column(
            children: [
              _StatCard(label: "MOVIES WATCHED", value: "42"),
              SizedBox(height: 14),
              _StatCard(label: "POINTS EARNED", value: "1,280"),
            ],
          );
        }

        return Row(
          children: const [
            Expanded(
              child: _StatCard(label: "MOVIES WATCHED", value: "42"),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _StatCard(label: "POINTS EARNED", value: "1,280"),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF30302E),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, color: ProfilePage._gold, size: 23),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFDCD9D9),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFDCD9D9), size: 28),
          ],
        ),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final VoidCallback? onBack;
  final Widget? action;

  const _ProfileTopBar({
    required this.title,
    this.centerTitle = false,
    this.onBack,
    this.action,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 72,
      backgroundColor: const Color(0xFF101010),
      elevation: 0,
      centerTitle: centerTitle,
      leadingWidth: 46,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: ProfilePage._gold, size: 22),
        onPressed: onBack ?? () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: ProfilePage._gold,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
      actions: action == null ? null : [action!],
    );
  }
}

class _ProfileDetailScaffold extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final Widget body;

  const _ProfileDetailScaffold({required this.appBar, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfilePage._page,
      appBar: appBar,
      body: body,
      bottomNavigationBar: _ProfileBottomNav(
        selectedIndex: 3,
        onTap: (_) => Navigator.pop(context),
      ),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  final String email;

  const ChangePasswordPage({super.key, required this.email});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileDetailScaffold(
      appBar: const _ProfileTopBar(title: "Change Password"),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF171512), ProfilePage._page],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 76, 28, 110),
          child: Container(
            constraints: const BoxConstraints(minHeight: 650),
            padding: const EdgeInsets.fromLTRB(34, 36, 34, 36),
            decoration: BoxDecoration(
              color: const Color(0xFF1C0D31),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Secure Your Account",
                  style: TextStyle(
                    color: Color(0xFFECE9F0),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Ensure your new password is at least 8\ncharacters long and includes a symbol.",
                  style: TextStyle(
                    color: Color(0xFFC5B9C8),
                    fontSize: 16,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 34),
                _PasswordField(
                  label: "CURRENT PASSWORD",
                  controller: _currentController,
                  visible: _showCurrent,
                  icon: Icons.lock_outline,
                  onToggle: () => setState(() => _showCurrent = !_showCurrent),
                ),
                const SizedBox(height: 28),
                _PasswordField(
                  label: "NEW PASSWORD",
                  controller: _newController,
                  visible: _showNew,
                  icon: Icons.lock_outline,
                  onToggle: () => setState(() => _showNew = !_showNew),
                ),
                const SizedBox(height: 28),
                _PasswordField(
                  label: "CONFIRM NEW PASSWORD",
                  controller: _confirmController,
                  visible: _showConfirm,
                  icon: Icons.lock_reset,
                  onToggle: () => setState(() => _showConfirm = !_showConfirm),
                ),
                const SizedBox(height: 52),
                ElevatedButton(
                  onPressed: _isSaving ? null : _savePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProfilePage._gold,
                    foregroundColor: const Color(0xFF2A230D),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF2A230D),
                          ),
                        )
                      : const Text("SAVE PASSWORD"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _savePassword() async {
    final newPassword = _newController.text;
    final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(newPassword);
    if (_currentController.text.isEmpty ||
        newPassword.length < 8 ||
        !hasSymbol ||
        newPassword != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password must match, use 8 characters, and include a symbol.",
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/auth/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'currentPassword': _currentController.text,
          'newPassword': newPassword,
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        final message = response.body.isNotEmpty
            ? response.body
            : 'Failed to change password.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool visible;
  final IconData icon;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.visible,
    required this.icon,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFC9B9C8),
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: TextField(
            controller: controller,
            obscureText: !visible,
            style: const TextStyle(
              color: Color(0xFFEFECEF),
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF211F1F),
              prefixIcon: Icon(icon, color: const Color(0xFFA8892C)),
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  visible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF887F7B),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _allRead = false;

  @override
  Widget build(BuildContext context) {
    final notifications = [
      _NotificationData(
        title: "Ticket Reminder",
        time: "5 HOURS AGO",
        message:
            "Don't forget your screening of Dune: Part Two tonight at 8:30 PM. Hall 4, Seat F12.",
      ),
      _NotificationData(
        title: "Upcoming Movie",
        time: "2 DAYS AGO",
        message:
            "Your ticket for Interstellar is ready. See you this Friday at 7:00 PM.",
      ),
    ];

    return _ProfileDetailScaffold(
      appBar: _ProfileTopBar(
        title: "Notifications",
        action: TextButton(
          onPressed: () => setState(() => _allRead = true),
          child: const Text(
            "Mark all as read",
            style: TextStyle(
              color: Color(0xFFCFC9C0),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 34, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "TICKET REMINDERS",
              style: TextStyle(
                color: Color(0xFF9E928A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 18),
            for (final item in notifications) ...[
              _NotificationCard(data: item, read: _allRead),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationData {
  final String title;
  final String time;
  final String message;

  const _NotificationData({
    required this.title,
    required this.time,
    required this.message,
  });
}

class _NotificationCard extends StatelessWidget {
  final _NotificationData data;
  final bool read;

  const _NotificationCard({required this.data, required this.read});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1D1C),
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 4,
              color: read ? Colors.transparent : ProfilePage._gold,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5B4A8E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.confirmation_number_outlined,
                        color: Color(0xFFD7D1EC),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  data.title,
                                  style: const TextStyle(
                                    color: Color(0xFFE9E5E2),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Text(
                                data.time,
                                style: const TextStyle(
                                  color: Color(0xFF8B817B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data.message,
                            style: const TextStyle(
                              color: Color(0xFFC3BAB3),
                              fontSize: 15,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  static const _transactions = [
    _TransactionData(
      title: "Interstellar",
      date: "Oct 24, 2023",
      seats: "B4, B5",
      payment: "E-WALLET",
      price: "\$28.00",
      imageUrl:
          "https://image.tmdb.org/t/p/w780/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
    ),
    _TransactionData(
      title: "Dune: Part Two",
      date: "Oct 20, 2023",
      seats: "G12",
      payment: "E-WALLET",
      price: "\$14.00",
      imageUrl:
          "https://image.tmdb.org/t/p/w780/xOMo8BRK7PfcJv9JCnx7s5hj0PX.jpg",
    ),
    _TransactionData(
      title: "Oppenheimer",
      date: "Oct 15, 2023",
      seats: "D1, D2, D3",
      payment: "E-WALLET",
      price: "\$42.00",
      imageUrl:
          "https://image.tmdb.org/t/p/w780/fm6KqXpk3M2HVveHwCrBSSBaO0V.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _ProfileDetailScaffold(
      appBar: const _ProfileTopBar(title: "Transaction History"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 124),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Transaction History",
              style: TextStyle(
                color: Color(0xFFEDE9E9),
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Review your cinematic journey and ticket details.",
              style: TextStyle(
                color: Color(0xFFB2AAA8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 26),
            for (final transaction in _transactions) ...[
              _TransactionCard(data: transaction),
              const SizedBox(height: 18),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1E1C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Statistics",
                    style: TextStyle(
                      color: Color(0xFFDCD8D6),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: const [
                      Expanded(
                        child: _HistoryStat(
                          label: "TOTAL BOOKINGS",
                          value: "12",
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _HistoryStat(
                          label: "LOYALTY POINTS",
                          value: "850",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionData {
  final String title;
  final String date;
  final String seats;
  final String payment;
  final String price;
  final String imageUrl;

  const _TransactionData({
    required this.title,
    required this.date,
    required this.seats,
    required this.payment,
    required this.price,
    required this.imageUrl,
  });
}

class _TransactionCard extends StatelessWidget {
  final _TransactionData data;

  const _TransactionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C0D31),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final imageHeight = constraints.maxWidth >= 720 ? 280.0 : 220.0;

              return Container(
                width: double.infinity,
                height: imageHeight,
                color: const Color(0xFF120F16),
                child: Image.network(
                  data.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Container(
                    height: imageHeight,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1C3636), Color(0xFF0D1717)],
                      ),
                    ),
                    child: const Icon(
                      Icons.movie,
                      color: ProfilePage._gold,
                      size: 52,
                    ),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.title,
                        style: const TextStyle(
                          color: ProfilePage._gold,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D2E3D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF705B42)),
                      ),
                      child: const Text(
                        "PAID",
                        style: TextStyle(
                          color: ProfilePage._gold,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: Color(0xFFC1B6B8),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.date,
                      style: const TextStyle(
                        color: Color(0xFFC1B6B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.event_seat_outlined,
                      color: Color(0xFFC1B6B8),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.seats,
                      style: const TextStyle(
                        color: Color(0xFFC1B6B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFF2B1A42), height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Color(0xFFC7BEC8),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      data.payment,
                      style: const TextStyle(
                        color: Color(0xFFC7BEC8),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      data.price,
                      style: const TextStyle(
                        color: ProfilePage._gold,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryStat extends StatelessWidget {
  final String label;
  final String value;

  const _HistoryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2830),
        borderRadius: BorderRadius.circular(5),
      ),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  color: Color(0xFF9F989D),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: const TextStyle(
                  color: ProfilePage._gold,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HOME PAGE ---
class HomePage extends StatelessWidget {
  final String userName;
  final String role;
  const HomePage({super.key, required this.userName, required this.role});

  @override
  Widget build(BuildContext context) {
    bool isAdmin = role.toLowerCase() == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAdmin ? "ADMIN DASHBOARD" : "CINEMA TICKET",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, $userName",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "Logged in as $role",
              style: const TextStyle(color: Colors.amber, fontSize: 12),
            ),
            const SizedBox(height: 30),

            if (isAdmin) ...[
              const Text(
                "Management Tools",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 15),
              _buildCard(
                context,
                Icons.movie,
                "Movie Management",
                "EDIT MOVIES",
              ),
              const SizedBox(height: 15),
              _buildCard(
                context,
                Icons.calendar_today,
                "Schedule Management",
                "MANAGE TIMES",
              ),
              const SizedBox(height: 15),
              _buildCard(
                context,
                Icons.analytics,
                "View Transactions",
                "REPORT",
              ),
            ] else ...[
              const Text(
                "Now Playing",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 15),
              // Dummy Movies
              _buildMovieCard(
                context,
                "AVENGERS: ENDGAME",
                "ACTION / SCI-FI",
                "4.9",
                "https://img.fruugo.com/product/7/41/145324147_max.jpg",
              ),
              const SizedBox(height: 15),
              _buildMovieCard(
                context,
                "JOKER",
                "DRAMA / CRIME",
                "4.8",
                "https://image.tmdb.org/t/p/original/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg",
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    IconData icon,
    String title,
    String action,
  ) {
    return InkWell(
      onTap: () => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Opening $title...'))),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.amber),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    action,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieCard(
    BuildContext context,
    String title,
    String genre,
    String rating,
    String imgUrl,
  ) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(20),
            ),
            child: Image.network(
              imgUrl,
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) =>
                  Container(width: 100, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    genre,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(
                        " $rating",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(100, 30),
                    ),
                    child: const Text(
                      "BOOK NOW",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- PLACEHOLDER PAGE ---
class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? extra;
  const PlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.amber.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (extra != null)
            Text(extra!, style: const TextStyle(color: Colors.amber)),
          const Text(
            "Feature coming soon",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

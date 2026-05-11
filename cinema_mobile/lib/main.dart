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
class ProfilePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final roleLabel = role.toUpperCase();

    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: const Color(0xFF101010),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _gold),
          onPressed: onBack,
        ),
        title: const Text(
          "PROFILE",
          style: TextStyle(
            color: _gold,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, color: _gold),
              onPressed: () => _openComingSoon(context, "Profile Settings"),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF181613), _page, _page],
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
                          border: Border.all(color: _gold, width: 3),
                        ),
                        child: const ClipOval(child: _ProfileAvatarIcon()),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        right: 12,
                        bottom: 12,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0x55F2C94C),
                                width: 8,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 10,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _gold,
                            shape: BoxShape.circle,
                            border: Border.all(color: _page, width: 3),
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
                  userName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFE7E4E4),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
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
                      color: _purple,
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
                    color: _panel,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.lock_outline,
                        title: "Change Password",
                        onTap: () =>
                            _openComingSoon(context, "Change Password"),
                      ),
                      _SettingsTile(
                        icon: Icons.notifications_none,
                        title: "Notifications",
                        onTap: () => _openComingSoon(context, "Notifications"),
                      ),
                      _SettingsTile(
                        icon: Icons.payments_outlined,
                        title: "Transaction History",
                        onTap: () =>
                            _openComingSoon(context, "Transaction History"),
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

  void _openComingSoon(BuildContext context, String menu) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ComingSoonPage(menu: menu)),
    );
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
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ProfilePage._gold,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                height: 1,
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

        if (cardWidth < 132) {
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

class ComingSoonPage extends StatelessWidget {
  final String menu;

  const ComingSoonPage({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101010),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ProfilePage._gold),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          menu.toUpperCase(),
          style: const TextStyle(
            color: ProfilePage._gold,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 78,
              color: ProfilePage._gold.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 22),
            Text(
              menu,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              "Coming soon",
              style: TextStyle(color: Colors.grey, fontSize: 14),
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

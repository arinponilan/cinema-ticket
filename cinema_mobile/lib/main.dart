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

// ═══════════════════════════════════════════════════════════════
// GLOBAL TICKET LIST — tidak akan reset
// ═══════════════════════════════════════════════════════════════
final List<BookedTicket> globalTickets = [];

String generateBookingCode() {
  final now = DateTime.now();
  return "BKG-${now.millisecondsSinceEpoch % 100000}";
}

// ═══════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════
class MovieData {
  final String title;
  final String genre;
  final String rating;
  final String imgUrl;
  MovieData(this.title, this.genre, this.rating, this.imgUrl);
}

enum SeatStatus { available, selected, booked }

class SeatModel {
  final String id;
  SeatStatus status;
  SeatModel({required this.id, required this.status});
}

class BookedTicket {
  final String movieTitle;
  final String imgUrl;
  final String seats;
  final String date;
  final String time;
  final String hall;
  final double total;
  final String bookingCode;
  final String paymentMethod;

  BookedTicket({
    required this.movieTitle,
    required this.imgUrl,
    required this.seats,
    required this.date,
    required this.time,
    required this.hall,
    required this.total,
    required this.bookingCode,
    required this.paymentMethod,
  });
}

// ═══════════════════════════════════════════════════════════════
// DUMMY DATA
// ═══════════════════════════════════════════════════════════════
final List<MovieData> allMovies = [
  MovieData("AVENGERS: ENDGAME", "ACTION / SCI-FI", "4.9",
      "https://img.fruugo.com/product/7/41/145324147_max.jpg"),
  MovieData("JOKER", "DRAMA / CRIME", "4.8",
      "https://image.tmdb.org/t/p/original/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg"),
  MovieData("SPIDER-MAN: NO WAY HOME", "ACTION / ADVENTURE", "4.7",
      "https://m.media-amazon.com/images/M/MV5BZWMyYzFjYTYtNTRjYi00OGExLWE2YzgtOGRmYjAxZTU3NzBiXkEyXkFqcGdeQXVyMzQ0MzA0NTM@._V1_.jpg"),
  MovieData("BATMAN: THE DARK KNIGHT", "ACTION / DRAMA", "4.9",
      "https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_.jpg"),
];

// ═══════════════════════════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════════════════════════
class TC {
  static const bg      = Color(0xFF0E0E1A);
  static const card    = Color(0xFF16162A);
  static const surface = Color(0xFF1C1C35);
  static const seatAvail  = Color(0xFF2E2E4A);
  static const seatSel    = Color(0xFFD4A017);
  static const seatBook   = Color(0xFF757575);
  static const accent  = Color(0xFFD4A017);
  static const textPri = Color(0xFFFFFFFF);
  static const textSec = Color(0xFF9090A8);
  static const textHint= Color(0xFF5A5A78);
  static const success = Color(0xFF4CAF50);
  static const purple  = Color(0xFF9B72E8);
}

// ═══════════════════════════════════════════════════════════════
// APP
// ═══════════════════════════════════════════════════════════════
class CinemaApp extends StatelessWidget {
  const CinemaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TIXTIX PREMIERE',
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

// ═══════════════════════════════════════════════════════════════
// REGISTER PAGE
// ═══════════════════════════════════════════════════════════════
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  String _role = 'Customer';
  bool _loading = false;

  Future<void> _register() async {
    final email = _emailCtrl.text;
    if (_role == 'Admin' && email != 'admin@gmail.com') {
      _snack('Akses Ditolak! Hanya akun resmi yang bisa mendaftar sebagai Admin.');
      return;
    }
    if (!email.endsWith('@gmail.com')) {
      _snack('Email harus menggunakan @gmail.com!');
      return;
    }
    setState(() => _loading = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8081/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameCtrl.text,
          'email': email,
          'password': _passCtrl.text,
          'admin': _role == 'Admin'
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.')),
        );
        Navigator.pop(context);
      } else {
        _snack('Registrasi Gagal! Mungkin email sudah terdaftar.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const Text("Create Account", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.amber)),
            const Text("Join the premiere cinema club", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 50),
            _buildTextField(_nameController, "Full Name", Icons.person),
            const SizedBox(height: 20),
            _buildTextField(_emailController, "Email", Icons.email),
            const SizedBox(height: 20),
            _buildTextField(_passwordController, "Password", Icons.lock, obscure: true),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("Register as Admin?", style: TextStyle(color: Colors.white)),
              value: _isAdmin,
              onChanged: (val) => setState(() => _isAdmin = val),
              activeColor: Colors.amber,
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text("REGISTER",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.amber),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LOGIN PAGE
// ═══════════════════════════════════════════════════════════════
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    final email = _emailCtrl.text;
    if (!email.endsWith('@gmail.com')) {
      _snack('Email harus menggunakan @gmail.com!');
      return;
    }
    setState(() => _loading = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8081/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': _passCtrl.text}),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        String role = userData['role'] ?? 'Customer';
        String name = userData['name'];
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainContainer(userName: name, role: role)),
        );
      } else {
        _snack('Login Gagal! Email/Password salah.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.movie_filter, size: 100, color: Colors.amber),
            const SizedBox(height: 20),
            const Text("TIXTIX PREMIERE",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const Text("PREMIERE ACCESS",
                style: TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 50),
            _field(_emailCtrl, "Email", Icons.email),
            const SizedBox(height: 20),
            _field(_passCtrl, "Password", Icons.lock, obscure: true),
            const SizedBox(height: 40),
            _loading
                ? const CircularProgressIndicator(color: Colors.amber)
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber, foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: const Text("SIGN IN",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 20),
            TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegisterPage())),
                child: const Text("Don't have an account? Register",
                    style: TextStyle(color: Colors.amber))),
          ]),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.amber),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MAIN CONTAINER — pakai IndexedStack supaya state tidak hilang
// ═══════════════════════════════════════════════════════════════
class MainContainer extends StatefulWidget {
  final String userName;
  final String email;
  final String role;
  const MainContainer(
      {super.key, required this.userName, required this.email, required this.role});
  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _idx = 0;
  final _ticketKey = GlobalKey<_TicketPageState>();

  void _goToTicket() {
    setState(() => _idx = 2);
    // Force rebuild TicketPage
    _ticketKey.currentState?.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _idx,
        children: [
          HomePage(
              userName: widget.userName,
              role: widget.role,
              onBookNow: (movie) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SeatSelectionPage(
                          movie: movie,
                          onConfirm: _goToTicket)))),
          const SearchPage(),
          TicketPage(key: _ticketKey),
          ProfilePage(
              userName: widget.userName,
              email: widget.email,
              role: widget.role),
          SettingsPage(userName: widget.userName),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _idx,
        onTap: (i) {
          setState(() => _idx = i);
          if (i == 2) {
            _ticketKey.currentState?.setState(() {});
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined), label: "Ticket"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════════
// HOME PAGE
// ═══════════════════════════════════════════════════════════════
class HomePage extends StatelessWidget {
  final String userName;
  final String role;
  final Function(MovieData) onBookNow;
  const HomePage(
      {super.key, required this.userName, required this.role, required this.onBookNow});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role.toLowerCase() == 'admin';
    return Scaffold(
      appBar: AppBar(
          title: Text(isAdmin ? "ADMIN DASHBOARD" : "TIXTIX PREMIERE",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
          backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Hello, $userName",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("Logged in as $role",
              style: const TextStyle(color: Colors.amber, fontSize: 12)),
          const SizedBox(height: 30),
          if (isAdmin) ...[
            const Text("Management Tools",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 15),
            _adminCard(context, Icons.movie, "Movie Management", "EDIT MOVIES"),
            const SizedBox(height: 15),
            _adminCard(context, Icons.calendar_today, "Schedule Management", "MANAGE TIMES"),
          ] else ...[
            const Text("Now Playing",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 15),
            ...allMovies.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: _movieCard(context, m))),
          ],
        ]),
      ),
    );
  }

  Widget _adminCard(
      BuildContext context, IconData icon, String title, String action) {
    return InkWell(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => AdminDetailPage(title: title))),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.amber),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(action, style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _movieCard(BuildContext context, MovieData movie) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            child: Image.network(movie.imgUrl,
                width: 100, height: 150, fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    Container(width: 100, color: Colors.grey))),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(movie.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(movie.genre,
                style: const TextStyle(color: Colors.grey, fontSize: 10)),
            Row(children: [
              const Icon(Icons.star, color: Colors.amber, size: 14),
              Text(" ${movie.rating}", style: const TextStyle(fontSize: 12)),
            ]),
            const Spacer(),
            ElevatedButton(
                onPressed: () => onBookNow(movie),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(100, 30)),
                child: const Text("BOOK NOW",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
          ]),
        )),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SCREEN 1 — SEAT SELECTION
// ═══════════════════════════════════════════════════════════════
class SeatSelectionPage extends StatefulWidget {
  final MovieData movie;
  final VoidCallback onConfirm;
  const SeatSelectionPage(
      {super.key, required this.movie, required this.onConfirm});
  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  static const _rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  static const _cols = 10;
  static const _pricePerSeat = 17.00;
  static const _convFee = 2.50;
  late List<List<SeatModel>> _seats;

  @override
  void initState() {
    super.initState();
    const booked = {
      'B6', 'B7', 'B8', 'D3', 'D4', 'E8', 'E9', 'E10',
      'F2', 'F3', 'G5', 'G6', 'G9', 'H7', 'H8'
    };
    _seats = List.generate(_rows.length, (r) => List.generate(_cols, (c) {
      final id = '${_rows[r]}${c + 1}';
      return SeatModel(
          id: id,
          status: booked.contains(id) ? SeatStatus.booked : SeatStatus.available);
    }));
  }

  List<SeatModel> get _selected =>
      _seats.expand((r) => r).where((s) => s.status == SeatStatus.selected).toList();
  String get _seatLabel =>
      _selected.isEmpty ? '-' : _selected.map((s) => s.id).join(', ');
  double get _total =>
      _selected.length * _pricePerSeat + (_selected.isEmpty ? 0 : _convFee);

  void _toggle(SeatModel s) {
    if (s.status == SeatStatus.booked) return;
    setState(() => s.status =
        s.status == SeatStatus.selected ? SeatStatus.available : SeatStatus.selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TC.bg,
      body: SafeArea(
        child: Column(children: [
          // Top bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: TC.accent.withOpacity(0.15)))),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: TC.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: TC.accent)),
                  child: const Icon(Icons.arrow_back_ios_new, color: TC.accent, size: 16),
                ),
              ),
              const Expanded(
                child: Text('SELECT SEATS',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: TC.accent, fontSize: 14,
                        fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: TC.card, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.access_time, color: TC.accent, size: 18),
              ),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                const SizedBox(height: 16),
                Text(widget.movie.title,
                    style: const TextStyle(
                        color: TC.textPri, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Today, 20:30  •  Hall 01',
                    style: TextStyle(color: TC.textSec, fontSize: 13)),
                const SizedBox(height: 28),
                // Layar
                Column(children: [
                  const Text('SCREEN',
                      style: TextStyle(color: TC.textSec, fontSize: 9, letterSpacing: 3)),
                  const SizedBox(height: 8),
                  Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Colors.transparent, TC.accent, Colors.transparent]),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [BoxShadow(
                          color: TC.accent.withOpacity(0.7), blurRadius: 14, spreadRadius: 2)],
                    ),
                  ),
                ]),
                const SizedBox(height: 22),
                // Grid kursi
                Column(
                  children: List.generate(_rows.length, (r) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: [
                      SizedBox(width: 18,
                          child: Text(_rows[r],
                              style: const TextStyle(color: TC.textSec, fontSize: 10))),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(_cols, (c) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _seatWidget(_seats[r][c]),
                              if (c == 4) const SizedBox(width: 10),
                            ],
                          )),
                        ),
                      ),
                    ]),
                  )),
                ),
                const SizedBox(height: 20),
                // Legenda
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _leg(TC.seatAvail, 'Available'),
                  const SizedBox(width: 20),
                  _leg(TC.seatSel, 'Selected'),
                  const SizedBox(width: 20),
                  _leg(TC.seatBook, 'Booked'),
                ]),
                const SizedBox(height: 24),
              ]),
            ),
          ),
          // Bottom bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
                color: TC.bg,
                border: Border(top: BorderSide(color: TC.accent.withOpacity(0.15)))),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('TOTAL PRICE',
                      style: TextStyle(color: TC.textSec, fontSize: 10, letterSpacing: 1)),
                  Text('\$${_total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: TC.accent, fontSize: 24, fontWeight: FontWeight.w900)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('SEATS',
                      style: TextStyle(color: TC.textSec, fontSize: 10, letterSpacing: 1)),
                  Text(_seatLabel,
                      style: const TextStyle(
                          color: TC.textPri, fontSize: 14, fontWeight: FontWeight.w700)),
                ]),
              ]),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ReviewOrderPage(
                              movie: widget.movie,
                              selectedSeats: _selected,
                              ticketPrice: _pricePerSeat,
                              convFee: _convFee,
                              onConfirm: widget.onConfirm))),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: TC.accent,
                      disabledBackgroundColor: const Color(0xFF3A3A3A),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0),
                  child: const Text('CONFIRM SELECTION',
                      style: TextStyle(color: Colors.black, fontSize: 14,
                          fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _seatWidget(SeatModel seat) {
    Color color;
    switch (seat.status) {
      case SeatStatus.available: color = TC.seatAvail; break;
      case SeatStatus.selected:  color = TC.seatSel;   break;
      case SeatStatus.booked:    color = TC.seatBook;  break;
    }
    return GestureDetector(
      onTap: () => _toggle(seat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 26, height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5), topRight: Radius.circular(5),
              bottomLeft: Radius.circular(2), bottomRight: Radius.circular(2)),
          boxShadow: seat.status == SeatStatus.selected
              ? [BoxShadow(color: TC.accent.withOpacity(0.6), blurRadius: 6)]
              : null,
        ),
      ),
    );
  }

  Widget _leg(Color c, String label) => Row(children: [
    Container(width: 18, height: 14,
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(color: TC.textSec, fontSize: 11)),
  ]);
}

// ═══════════════════════════════════════════════════════════════
// SCREEN 2 — REVIEW ORDER
// ═══════════════════════════════════════════════════════════════
class ReviewOrderPage extends StatelessWidget {
  final MovieData movie;
  final List<SeatModel> selectedSeats;
  final double ticketPrice;
  final double convFee;
  final VoidCallback onConfirm;

  const ReviewOrderPage({
    super.key,
    required this.movie,
    required this.selectedSeats,
    required this.ticketPrice,
    required this.convFee,
    required this.onConfirm,
  });

  String get _seatLabel => selectedSeats.map((s) => s.id).join(', ');
  double get _total => selectedSeats.length * ticketPrice + convFee;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.amber.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          if (extra != null) Text(extra!, style: const TextStyle(color: Colors.amber)),
          const Text("Feature coming soon", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _payOpt({required String id, required IconData icon,
      required String title, required String sub}) {
    final sel = _method == id;
    return GestureDetector(
      onTap: () => setState(() => _method = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: sel ? TC.accent.withOpacity(0.08) : TC.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: sel ? TC.accent : TC.surface, width: sel ? 1.5 : 1)),
        child: Row(children: [
          Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                  color: sel ? TC.accent.withOpacity(0.15) : TC.surface,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: sel ? TC.accent : TC.textSec, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(
                color: sel ? TC.textPri : TC.textSec,
                fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(color: TC.textHint, fontSize: 12)),
          ])),
          AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22, height: 22,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? TC.accent : Colors.transparent,
                  border: Border.all(
                      color: sel ? TC.accent : TC.textHint, width: 1.5)),
              child: sel
                  ? const Icon(Icons.check, color: Colors.black, size: 13)
                  : null),
        ]),
      ),
    );
  }

  Widget _feeRow(String label, String value) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: TC.textSec, fontSize: 13)),
        Text(value, style: const TextStyle(color: TC.textPri, fontSize: 13,
            fontWeight: FontWeight.w600)),
      ]);

  void _confirmAndSave(BuildContext context) {
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final dateStr =
        '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
    final methodLabel = _method == 'ewallet' ? 'E-Wallet' : 'Cash (Tunai)';

    // ── Simpan ke global list ──
    globalTickets.insert(0, BookedTicket(
      movieTitle:    widget.movie.title,
      imgUrl:        widget.movie.imgUrl,
      seats:         _seatLabel,
      date:          dateStr,
      time:          '20:30',
      hall:          'Hall 01',
      total:         _grandTotal,
      bookingCode:   generateBookingCode(),
      paymentMethod: methodLabel,
    ));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: TC.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                  color: TC.success.withOpacity(0.12), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded,
                  color: TC.success, size: 48),
            ),
            const SizedBox(height: 20),
            const Text('Booking Confirmed!',
                style: TextStyle(color: TC.textPri, fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Tiket ${widget.movie.title} berhasil dipesan!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: TC.textSec, fontSize: 13)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: TC.surface, borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                _dRow('Seats', _seatLabel, TC.accent),
                const SizedBox(height: 8),
                _dRow('Metode', methodLabel, TC.textPri),
                const SizedBox(height: 8),
                _dRow('Total', '\$${_grandTotal.toStringAsFixed(2)}', TC.accent),
              ]),
            ),
            const SizedBox(height: 24),
            // Tombol lihat tiket
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  widget.onConfirm();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: TC.accent, foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0),
                child: const Text('LIHAT TIKET SAYA',
                    style: TextStyle(color: Colors.black,
                        fontWeight: FontWeight.w800, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                style: OutlinedButton.styleFrom(
                    foregroundColor: TC.accent,
                    side: const BorderSide(color: TC.accent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text('KEMBALI KE HOME',
                    style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _dRow(String label, String value, Color color) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: TC.textSec, fontSize: 12)),
        Text(value, style: TextStyle(color: color, fontSize: 12,
            fontWeight: FontWeight.w700)),
      ]);
}

// ═══════════════════════════════════════════════════════════════
// TICKET PAGE — baca dari globalTickets
// ═══════════════════════════════════════════════════════════════
class TicketPage extends StatefulWidget {
  const TicketPage({super.key});
  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: TC.bg,
      appBar: AppBar(
          backgroundColor: TC.bg, elevation: 0, centerTitle: true,
          title: const Text('MY TICKETS',
              style: TextStyle(color: TC.accent, fontSize: 13,
                  fontWeight: FontWeight.w800, letterSpacing: 1.5))),
      body: globalTickets.isEmpty
          ? const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.confirmation_number_outlined,
                    color: TC.textHint, size: 64),
                SizedBox(height: 16),
                Text('No Tickets Yet',
                    style: TextStyle(color: TC.textPri, fontSize: 18,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text('Book a movie to get your tickets here.',
                    style: TextStyle(color: TC.textSec, fontSize: 13)),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: globalTickets.length,
              itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _TicketCard(ticket: globalTickets[i])),
            ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final BookedTicket ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TC.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TC.accent.withOpacity(0.2)),
        boxShadow: [BoxShadow(
            color: TC.accent.withOpacity(0.06),
            blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                TC.accent.withOpacity(0.15),
                TC.purple.withOpacity(0.10)]),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20))),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(ticket.imgUrl,
                  width: 60, height: 75, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      width: 60, height: 75, color: TC.surface,
                      child: Center(child: Text(ticket.movieTitle[0],
                          style: const TextStyle(color: TC.accent,
                              fontSize: 26, fontWeight: FontWeight.w900))))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ticket.movieTitle,
                  style: const TextStyle(color: TC.textPri, fontSize: 15,
                      fontWeight: FontWeight.w800),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.chair_outlined, color: TC.accent, size: 12),
                const SizedBox(width: 4),
                Text(ticket.seats, style: const TextStyle(
                    color: TC.accent, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.place_outlined, color: TC.textSec, size: 12),
                const SizedBox(width: 4),
                Text(ticket.hall,
                    style: const TextStyle(color: TC.textSec, fontSize: 11)),
              ]),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: TC.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: TC.accent.withOpacity(0.3))),
              child: Text(ticket.paymentMethod,
                  style: const TextStyle(color: TC.accent, fontSize: 8,
                      fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ),
          ]),
        ),
        // Perforated divider
        Row(children: [
          Container(width: 18, height: 18,
              decoration: BoxDecoration(
                  color: TC.bg, borderRadius: BorderRadius.circular(9))),
          Expanded(child: LayoutBuilder(builder: (_, c) {
            const dW = 6.0, gW = 4.0;
            final count = (c.maxWidth / (dW + gW)).floor();
            return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(count, (_) =>
                    Container(width: dW, height: 1, color: TC.surface)));
          })),
          Container(width: 18, height: 18,
              decoration: BoxDecoration(
                  color: TC.bg, borderRadius: BorderRadius.circular(9))),
        ]),
        // Body
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _info('DATE', ticket.date),
              _info('TIME', ticket.time),
              _info('TOTAL', '\$${ticket.total.toStringAsFixed(2)}',
                  valueColor: TC.accent),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: TC.surface, borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('BOOKING ID',
                    style: TextStyle(color: TC.textSec, fontSize: 10,
                        letterSpacing: 1, fontWeight: FontWeight.w600)),
                Text(ticket.bookingCode,
                    style: const TextStyle(color: TC.purple, fontSize: 12,
                        fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              ]),
            ),
            const SizedBox(height: 14),
            const Icon(Icons.qr_code_2_rounded, size: 80, color: TC.textSec),
            const SizedBox(height: 4),
            const Text('SCAN AT ENTRANCE',
                style: TextStyle(color: TC.textHint, fontSize: 9,
                    letterSpacing: 2, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  Widget _info(String label, String value, {Color? valueColor}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: TC.textSec, fontSize: 9,
            letterSpacing: 1.2, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(
            color: valueColor ?? TC.textPri, fontSize: 13,
            fontWeight: FontWeight.w700)),
      ]);
}

// ═══════════════════════════════════════════════════════════════
// SEARCH PAGE
// ═══════════════════════════════════════════════════════════════
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<MovieData> _filtered = allMovies;
  void _search(String q) => setState(() => _filtered = allMovies
      .where((m) => m.title.toLowerCase().contains(q.toLowerCase()))
      .toList());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("SEARCH",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  color: Colors.amber)),
          backgroundColor: Colors.transparent),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            TextField(
                onChanged: _search,
                decoration: InputDecoration(
                    hintText: "Search your favorite movies...",
                    prefixIcon: const Icon(Icons.search, color: Colors.amber),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none))),
            const SizedBox(height: 20),
            Expanded(
                child: ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => ListTile(
                        leading: Image.network(_filtered[i].imgUrl,
                            width: 50, fit: BoxFit.cover),
                        title: Text(_filtered[i].title),
                        subtitle: Text(_filtered[i].genre),
                        trailing: const Icon(Icons.chevron_right)))),
          ])),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PROFILE PAGE
// ═══════════════════════════════════════════════════════════════
class ProfilePage extends StatelessWidget {
  final String userName;
  final String email;
  final String role;
  const ProfilePage(
      {super.key, required this.userName, required this.email, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      const SizedBox(height: 80),
      const Center(
          child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.amber,
              child: Icon(Icons.person, size: 60, color: Colors.black))),
      const SizedBox(height: 20),
      Text(userName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      Text(email, style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 10),
      Chip(
          label: Text(role,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.amber),
      const SizedBox(height: 30),
      ListTile(
          leading: const Icon(Icons.history, color: Colors.amber),
          title: const Text("Booking History"),
          trailing: const Icon(Icons.chevron_right)),
      ListTile(
          leading: const Icon(Icons.payment, color: Colors.amber),
          title: const Text("Payment Methods"),
          trailing: const Icon(Icons.chevron_right)),
    ]));
  }
}

// ═══════════════════════════════════════════════════════════════
// ADMIN DETAIL PAGE
// ═══════════════════════════════════════════════════════════════
class AdminDetailPage extends StatelessWidget {
  final String title;
  const AdminDetailPage({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView.builder(
            itemCount: 5,
            itemBuilder: (_, i) => ListTile(
                title: Text("Sample Data $i"),
                subtitle: const Text("Admin Access Only"),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {}),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {}),
                ]))),
        floatingActionButton: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.amber,
            child: const Icon(Icons.add, color: Colors.black)));
  }
}

// ═══════════════════════════════════════════════════════════════
// SETTINGS PAGE
// ═══════════════════════════════════════════════════════════════
class SettingsPage extends StatelessWidget {
  final String userName;
  const SettingsPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("SETTINGS",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
            backgroundColor: Colors.transparent),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              ListTile(
                  leading: const Icon(Icons.person, color: Colors.amber),
                  title: const Text("Account"),
                  subtitle: Text(userName),
                  trailing: const Icon(Icons.chevron_right)),
              const Divider(color: Colors.white10),
              ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.amber),
                  title: const Text("Notifications"),
                  trailing: const Icon(Icons.chevron_right)),
              const Spacer(),
              ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("LOGOUT"),
                  onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginPage())),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)))),
              const SizedBox(height: 20),
            ])));
  }
}
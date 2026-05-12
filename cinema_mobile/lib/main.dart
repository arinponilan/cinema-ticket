import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const CinemaApp());
}

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

// --- MODELS ---
class MovieData {
  final String title;
  final String genre;
  final String rating;
  final String imgUrl;
  MovieData(this.title, this.genre, this.rating, this.imgUrl);
}

// --- DATA DUMMY ---
final List<MovieData> allMovies = [
  MovieData("AVENGERS: ENDGAME", "ACTION / SCI-FI", "4.9", "https://img.fruugo.com/product/7/41/145324147_max.jpg"),
  MovieData("JOKER", "DRAMA / CRIME", "4.8", "https://image.tmdb.org/t/p/original/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg"),
  MovieData("SPIDER-MAN: NO WAY HOME", "ACTION / ADVENTURE", "4.7", "https://m.media-amazon.com/images/M/MV5BZWMyYzFjYTYtNTRjYi00OGExLWE2YzgtOGRmYjAxZTU3NzBiXkEyXkFqcGdeQXVyMzQ0MzA0NTM@._V1_.jpg"),
  MovieData("BATMAN: THE DARK KNIGHT", "ACTION / DRAMA", "4.9", "https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_.jpg"),
  MovieData("INTERSTELLAR", "SCI-FI / DRAMA", "4.8", "https://m.media-amazon.com/images/M/MV5BZjdkOTU3MDktN2IxOS00OGEyLWFmMjktY2FiMmZkNWIyODZiXkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_.jpg"),
  MovieData("DUNE: PART TWO", "SCI-FI / ACTION", "4.7", "https://m.media-amazon.com/images/M/MV5BN2QyZGU4ZDctOWMzMy00NTc5LThlOGQtODhmNDI1NmY5YzAwXkEyXkFqcGdeQXVyMDM2NDM2MQ@@._V1_.jpg"),
  MovieData("OPPENHEIMER", "DRAMA / HISTORY", "4.8", "https://m.media-amazon.com/images/M/MV5BMDBmYTZjNjUtN2M1MS00MTQ2LTk2ODgtNzc2M2QyZGE5NTVjXkEyXkFqcGdeQXVyNzAwMjU2MTY@._V1_.jpg"),
  MovieData("INSIDE OUT 2", "ANIMATION / COMEDY", "4.6", "https://m.media-amazon.com/images/M/MV5BYTc1MDQ3NjAtOWEzMi00YzE1LWI2OWUtNjQ0OWJkMTlhNWI5XkEyXkFqcGdeQXVyMDM2NDM2MQ@@._V1_.jpg"),
  MovieData("THE CONJURING", "HORROR / THRILLER", "4.5", "https://m.media-amazon.com/images/M/MV5BMTM3NjA1NDMyMV5BMl5BanBnXkFtZTcwMDQzNDMzOQ@@._V1_.jpg"),
  MovieData("PARASITE", "THRILLER / DRAMA", "4.9", "https://m.media-amazon.com/images/M/MV5BYWZjMjk3ZTItODQ2ZC00NTY5LWE0ZDYtZTI3MjcwN2Q5NTVkXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_.jpg"),
  MovieData("JOHN WICK 4", "ACTION / THRILLER", "4.6", "https://m.media-amazon.com/images/M/MV5BMDExZGMyOTMtMDgyYi00NGIwLWJhMTEtOTdkZGFjNmZiMTEwXkEyXkFqcGdeQXVyMjM4NTM5NDY@._V1_.jpg"),
  MovieData("GUARDIANS OF THE GALAXY 3", "ACTION / COMEDY", "4.7", "https://m.media-amazon.com/images/M/MV5BMDgxOTdjMzYtZGQxMS00ZTAzLWI4Y2UtMTQzN2VlYjYyZWRiXkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_.jpg"),
];

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
  String _selectedRole = 'Customer';
  bool _isLoading = false;

  Future<void> _register() async {
    final email = _emailController.text;
    
    // VALIDASI KHUSUS ADMIN
    if (_selectedRole == 'Admin' && email != 'admin@gmail.com') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akses Ditolak! Hanya akun resmi yang bisa mendaftar sebagai Admin.')),
      );
      return;
    }

    if (!email.endsWith('@gmail.com')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email harus menggunakan @gmail.com!')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8081/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text, 
          'email': email, 
          'password': _passwordController.text, 
          'admin': _selectedRole == 'Admin'
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi Gagal! Mungkin email sudah terdaftar.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
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
            const Text("Create Account", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.amber)),
            const Text("Join the premiere cinema club", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            _buildTextField(_nameController, "Full Name", Icons.person),
            const SizedBox(height: 20),
            _buildTextField(_emailController, "Email", Icons.email),
            const SizedBox(height: 20),
            _buildTextField(_passwordController, "Password", Icons.lock, obscure: true),
            const SizedBox(height: 30),
            const Align(alignment: Alignment.centerLeft, child: Text("Select Role:", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
            Row(
              children: [
                Expanded(child: RadioListTile<String>(title: const Text("Customer"), value: 'Customer', groupValue: _selectedRole, onChanged: (val) => setState(() => _selectedRole = val!), activeColor: Colors.amber, contentPadding: EdgeInsets.zero)),
                Expanded(child: RadioListTile<String>(title: const Text("Admin"), value: 'Admin', groupValue: _selectedRole, onChanged: (val) => setState(() => _selectedRole = val!), activeColor: Colors.amber, contentPadding: EdgeInsets.zero)),
              ],
            ),
            const SizedBox(height: 40),
            _isLoading ? const CircularProgressIndicator(color: Colors.amber) : ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: const Text("REGISTER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return TextField(controller: controller, obscureText: obscure, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: Colors.amber), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)));
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
    final email = _emailController.text;
    if (!email.endsWith('@gmail.com')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email harus menggunakan @gmail.com!')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8081/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': _passwordController.text}),
      );
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainContainer(userName: userData['name'], email: userData['email'], role: userData['role'] ?? 'Customer')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Gagal! Email/Password salah.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
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
              const Text("TIXTIX PREMIERE", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const Text("PREMIERE ACCESS", style: TextStyle(color: Colors.grey, fontSize: 10)),
              const SizedBox(height: 50),
              _buildTextField(_emailController, "Email", Icons.email),
              const SizedBox(height: 20),
              _buildTextField(_passwordController, "Password", Icons.lock, obscure: true),
              const SizedBox(height: 40),
              _isLoading ? const CircularProgressIndicator(color: Colors.amber) : ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text("SIGN IN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 20),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())), child: const Text("Don't have an account? Register", style: TextStyle(color: Colors.amber))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return TextField(controller: controller, obscureText: obscure, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: Colors.amber), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)));
  }
}

// --- MAIN CONTAINER ---
class MainContainer extends StatefulWidget {
  final String userName;
  final String email;
  final String role;
  const MainContainer({super.key, required this.userName, required this.email, required this.role});
  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;
  void _onTabTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(userName: widget.userName, role: widget.role, onBookNow: (movie) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SeatSelectionPage(movie: movie, onConfirm: () => _onTabTapped(2))));
      }),
      const SearchPage(),
      const TicketPage(),
      ProfilePage(userName: widget.userName, email: widget.email, role: widget.role),
      SettingsPage(userName: widget.userName),
    ];
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), label: "Ticket"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

// --- HOME PAGE ---
class HomePage extends StatelessWidget {
  final String userName;
  final String role;
  final Function(MovieData) onBookNow;
  const HomePage({super.key, required this.userName, required this.role, required this.onBookNow});

  @override
  Widget build(BuildContext context) {
    bool isAdmin = role.toLowerCase() == 'admin';
    return Scaffold(
      appBar: AppBar(title: Text(isAdmin ? "ADMIN DASHBOARD" : "TIXTIX PREMIERE", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)), backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, $userName", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Logged in as $role", style: const TextStyle(color: Colors.amber, fontSize: 12)),
            const SizedBox(height: 30),
            if (isAdmin) ...[
              const Text("Management Tools", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 15),
              _buildAdminCard(context, Icons.movie, "Movie Management", "EDIT MOVIES"),
              const SizedBox(height: 15),
              _buildAdminCard(context, Icons.calendar_today, "Schedule Management", "MANAGE TIMES"),
            ] else ...[
              const Text("Now Playing", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 15),
              ...allMovies.map((m) => Padding(padding: const EdgeInsets.only(bottom: 15), child: _buildMovieCard(context, m))).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, IconData icon, String title, String action) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDetailPage(title: title))),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber.withOpacity(0.3))),
        child: Row(children: [Icon(icon, size: 40, color: Colors.amber), const SizedBox(width: 20), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(action, style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold))])), const Icon(Icons.chevron_right, color: Colors.grey)]),
      ),
    );
  }

  Widget _buildMovieCard(BuildContext context, MovieData movie) {
    return Container(
      height: 150,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)), child: Image.network(movie.imgUrl, width: 100, height: 150, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 100, color: Colors.grey))),
          Expanded(child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(movie.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis), Text(movie.genre, style: const TextStyle(color: Colors.grey, fontSize: 10)), Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), Text(" ${movie.rating}", style: const TextStyle(fontSize: 12))]), const Spacer(), ElevatedButton(onPressed: () => onBookNow(movie), style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(100, 30)), child: const Text("BOOK NOW", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))]))),
        ],
      ),
    );
  }
}

// --- SEAT SELECTION PAGE ---
class SeatSelectionPage extends StatefulWidget {
  final MovieData movie;
  final VoidCallback onConfirm;
  const SeatSelectionPage({super.key, required this.movie, required this.onConfirm});
  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  final List<String> _selectedSeats = [];
  final List<String> _bookedSeats = ["B1", "B2", "D4", "D5", "D6"];
  final double _pricePerSeat = 35000.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SELECT SEATS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(widget.movie.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
          const Text("Today, 20:30 • Hall 01", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 40),
          Center(child: Column(children: [Container(width: 300, height: 5, decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)])), const SizedBox(height: 10), const Text("SCREEN", style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 5))])),
          const SizedBox(height: 40),
          Expanded(child: GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 40), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: 64, itemBuilder: (context, index) {
            String seatId = "${String.fromCharCode(65 + (index ~/ 8))}${index % 8 + 1}";
            bool isBooked = _bookedSeats.contains(seatId);
            bool isSelected = _selectedSeats.contains(seatId);
            return InkWell(onTap: isBooked ? null : () { setState(() { if (isSelected) { _selectedSeats.remove(seatId); } else { _selectedSeats.add(seatId); } }); }, child: Container(decoration: BoxDecoration(color: isBooked ? Colors.white10 : (isSelected ? Colors.amber : Colors.deepPurple.shade900), borderRadius: BorderRadius.circular(5))));
          })),
          Padding(padding: const EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildLegend(Colors.deepPurple.shade900, "Available"), _buildLegend(Colors.amber, "Selected"), _buildLegend(Colors.white10, "Booked")])),
          Container(padding: const EdgeInsets.all(25), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: const BorderRadius.vertical(top: Radius.circular(30))), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("TOTAL PRICE", style: TextStyle(color: Colors.grey, fontSize: 10)), Text("Rp ${(_selectedSeats.length * _pricePerSeat).toInt()}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber))]), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text("SEATS", style: TextStyle(color: Colors.grey, fontSize: 10)), Text(_selectedSeats.isEmpty ? "-" : _selectedSeats.join(", "), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))])]), const SizedBox(height: 20), ElevatedButton(onPressed: _selectedSeats.isEmpty ? null : () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking Confirmed!'))); widget.onConfirm(); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text("CONFIRM SELECTION", style: TextStyle(fontWeight: FontWeight.bold)))]))
        ],
      ),
    );
  }
  Widget _buildLegend(Color color, String text) => Row(children: [Container(width: 15, height: 15, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))), const SizedBox(width: 8), Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey))]);
}

// --- SEARCH PAGE ---
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<MovieData> _filtered = allMovies;
  void _search(String query) => setState(() => _filtered = allMovies.where((m) => m.title.toLowerCase().contains(query.toLowerCase())).toList());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SEARCH", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)), backgroundColor: Colors.transparent),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [TextField(onChanged: _search, decoration: InputDecoration(hintText: "Search your favorite movies...", prefixIcon: const Icon(Icons.search, color: Colors.amber), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))), const SizedBox(height: 20), Expanded(child: ListView.builder(itemCount: _filtered.length, itemBuilder: (c, i) => ListTile(leading: Image.network(_filtered[i].imgUrl, width: 50, fit: BoxFit.cover), title: Text(_filtered[i].title), subtitle: Text(_filtered[i].genre), trailing: const Icon(Icons.chevron_right))))])),
    );
  }
}

// --- TICKET PAGE ---
class TicketPage extends StatelessWidget {
  const TicketPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MY TICKETS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)), backgroundColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.all(20), children: [_buildTicket(context, "AVENGERS: ENDGAME", "Seat A12", "Mon, 22 May", "19:00 PM", "BKG-88219"), const SizedBox(height: 20), _buildTicket(context, "JOKER", "Seat C05", "Tue, 23 May", "21:30 PM", "BKG-11204")]),
    );
  }
  Widget _buildTicket(BuildContext context, String title, String seat, String date, String time, String code) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)), Text(seat, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600))]), const Icon(Icons.confirmation_number, color: Colors.black54)]), const Divider(color: Colors.black26, height: 30), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("DATE", style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)), Text(date, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))]), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("TIME", style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)), Text(time, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))]), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("ID", style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)), Text(code, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))])]), const SizedBox(height: 20), const Icon(Icons.qr_code_2, size: 80, color: Colors.black), const Text("SCAN AT ENTRANCE", style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold))]));
}

// --- PROFILE PAGE ---
class ProfilePage extends StatelessWidget {
  final String userName;
  final String email;
  final String role;
  const ProfilePage({super.key, required this.userName, required this.email, required this.role});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [const SizedBox(height: 80), const Center(child: CircleAvatar(radius: 50, backgroundColor: Colors.amber, child: Icon(Icons.person, size: 60, color: Colors.black))), const SizedBox(height: 20), Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), Text(email, style: const TextStyle(color: Colors.grey)), const SizedBox(height: 10), Chip(label: Text(role, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.amber), const SizedBox(height: 30), ListTile(leading: const Icon(Icons.history, color: Colors.amber), title: const Text("Booking History"), trailing: const Icon(Icons.chevron_right)), ListTile(leading: const Icon(Icons.payment, color: Colors.amber), title: const Text("Payment Methods"), trailing: const Icon(Icons.chevron_right))]));
  }
}

// --- ADMIN DETAIL PAGE ---
class AdminDetailPage extends StatelessWidget {
  final String title;
  const AdminDetailPage({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title)), body: ListView.builder(itemCount: 5, itemBuilder: (c, i) => ListTile(title: Text("Sample Data $i"), subtitle: const Text("Admin Access Only"), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {})]))), floatingActionButton: FloatingActionButton(onPressed: () {}, backgroundColor: Colors.amber, child: const Icon(Icons.add, color: Colors.black)));
  }
}

// --- SETTINGS PAGE ---
class SettingsPage extends StatelessWidget {
  final String userName;
  const SettingsPage({super.key, required this.userName});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("SETTINGS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)), backgroundColor: Colors.transparent), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [ListTile(leading: const Icon(Icons.person, color: Colors.amber), title: const Text("Account"), subtitle: Text(userName), trailing: const Icon(Icons.chevron_right)), const Divider(color: Colors.white10), ListTile(leading: const Icon(Icons.notifications, color: Colors.amber), title: const Text("Notifications"), trailing: const Icon(Icons.chevron_right)), const Spacer(), ElevatedButton.icon(icon: const Icon(Icons.logout), label: const Text("LOGOUT"), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())), style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.8), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))), const SizedBox(height: 20)])));
  }
}

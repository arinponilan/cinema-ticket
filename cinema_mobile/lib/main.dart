import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String backendBaseUrl = 'http://10.0.2.2:8081';

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
        scaffoldBackgroundColor: AppColors.black,
        primaryColor: AppColors.gold,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.gold,
          brightness: Brightness.dark,
          primary: AppColors.gold,
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class AppColors {
  static const black = Color(0xFF050606);
  static const surface = Color(0xFF151819);
  static const panel = Color(0xFF1B1B1B);
  static const softPanel = Color(0xFF262626);
  static const gold = Color(0xFFFFC107);
  static const softGold = Color(0xFFE0B84B);
  static const warmSeat = Color(0xFF5D4A14);
  static const bookedSeat = Color(0xFF202326);
}

class CinemaApi {
  const CinemaApi();

  Future<List<CinemaMovie>> fetchMovies() async {
    final response = await http.get(Uri.parse('$backendBaseUrl/api/movies'));
    _ensureOk(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => CinemaMovie.fromJson(item)).toList();
  }

  Future<List<MovieSchedule>> fetchSchedules(int movieId) async {
    final response = await http.get(
      Uri.parse('$backendBaseUrl/api/schedules/movie/$movieId'),
    );
    _ensureOk(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => MovieSchedule.fromJson(item)).toList();
  }

  Future<List<CinemaSeat>> fetchSeats(int scheduleId) async {
    final response = await http.get(
      Uri.parse('$backendBaseUrl/api/seats/schedule/$scheduleId'),
    );
    _ensureOk(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => CinemaSeat.fromJson(item)).toList();
  }

  Future<BookingTicket> createBooking({
    required int userId,
    required int scheduleId,
    required List<int> seatIds,
  }) async {
    final response = await http.post(
      Uri.parse('$backendBaseUrl/api/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'scheduleId': scheduleId,
        'seatIds': seatIds,
      }),
    );
    _ensureOk(response);
    return BookingTicket.fromJson(jsonDecode(response.body));
  }

  Future<List<BookingTicket>> fetchUserBookings(int userId) async {
    final response = await http.get(
      Uri.parse('$backendBaseUrl/api/bookings/user/$userId'),
    );
    _ensureOk(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => BookingTicket.fromJson(item)).toList();
  }

  Future<ProfileSummary> fetchProfileSummary(int userId) async {
    final response = await http.get(
      Uri.parse('$backendBaseUrl/api/bookings/user/$userId/profile'),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ProfileSummary.fromJson(jsonDecode(response.body));
    }

    final bookings = await fetchUserBookings(userId);
    return ProfileSummary(
      moviesWatched: bookings.length,
      transactionHistory: bookings,
    );
  }
  Future<bool> changePassword(int userId, String oldPassword, String newPassword) async {
    final response = await http.post(
      Uri.parse('$backendBaseUrl/api/auth/change-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );
    return response.statusCode == 200;
  }


  void _ensureOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(response.body.isEmpty ? 'Request failed' : response.body);
    }
  }
}

class CinemaMovie {
  final int id;
  final String title;
  final String genre;
  final int duration;
  final String synopsis;
  final double price;
  final String imageUrl;

  const CinemaMovie({
    required this.id,
    required this.title,
    required this.genre,
    required this.duration,
    required this.synopsis,
    required this.price,
    required this.imageUrl,
  });

  factory CinemaMovie.fromJson(Map<String, dynamic> json) {
    return CinemaMovie(
      id: _intValue(json['id']),
      title: json['title']?.toString() ?? 'Untitled',
      genre: json['genre']?.toString() ?? '-',
      duration: _intValue(json['duration']),
      synopsis: json['synopsis']?.toString() ?? '',
      price: _doubleValue(json['price']),
      imageUrl: _normalizeImageUrl(
        json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? '',
      ),
    );
  }

  String get posterUrl => imageUrl;
}

class MovieSchedule {
  final int scheduleId;
  final String date;
  final String time;

  const MovieSchedule({
    required this.scheduleId,
    required this.date,
    required this.time,
  });

  factory MovieSchedule.fromJson(Map<String, dynamic> json) {
    return MovieSchedule(
      scheduleId: _intValue(json['scheduleId'] ?? json['schedule_id']),
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }
}

class CinemaSeat {
  final int id;
  final String seatNumber;
  final bool isBooked;

  const CinemaSeat({
    required this.id,
    required this.seatNumber,
    required this.isBooked,
  });

  factory CinemaSeat.fromJson(Map<String, dynamic> json) {
    return CinemaSeat(
      id: _intValue(json['id']),
      seatNumber:
          json['seatNumber']?.toString() ??
          json['seat_number']?.toString() ??
          '-',
      isBooked: json['booked'] == true || json['isBooked'] == true,
    );
  }
}

class BookingTicket {
  final String bookingCode;
  final String movieTitle;
  final List<String> seatNumbers;
  final String showDate;
  final String showTime;
  final double totalPrice;

  const BookingTicket({
    required this.bookingCode,
    required this.movieTitle,
    required this.seatNumbers,
    required this.showDate,
    required this.showTime,
    required this.totalPrice,
  });

  factory BookingTicket.fromJson(Map<String, dynamic> json) {
    final seats = json['seatNumbers'] as List<dynamic>?;
    return BookingTicket(
      bookingCode: json['bookingCode']?.toString() ?? '-',
      movieTitle: json['movieTitle']?.toString() ?? 'Unknown Movie',
      seatNumbers: seats?.map((item) => item.toString()).toList() ?? const [],
      showDate:
          json['bookingDate']?.toString() ??
          json['showDate']?.toString() ??
          '-',
      showTime: json['showTime']?.toString() ?? '-',
      totalPrice: _doubleValue(json['totalPrice']),
    );
  }
}

class ProfileSummary {
  final int moviesWatched;
  final List<BookingTicket> transactionHistory;

  const ProfileSummary({
    required this.moviesWatched,
    required this.transactionHistory,
  });

  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    final history = json['transactionHistory'] as List<dynamic>?;
    return ProfileSummary(
      moviesWatched: _intValue(json['moviesWatched']),
      transactionHistory:
          history?.map((item) => BookingTicket.fromJson(item)).toList() ??
          const [],
    );
  }
}

int _intValue(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _doubleValue(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _normalizeImageUrl(String value) {
  final url = value.trim();
  if (url.isEmpty) return '';
  if (url.startsWith('//')) return 'https:$url';
  return url
      .replaceFirst('http://localhost', 'http://10.0.2.2')
      .replaceFirst('http://127.0.0.1', 'http://10.0.2.2');
}

String rupiah(num value) {
  final text = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write('.');
    buffer.write(text[i]);
  }
  return 'Rp$buffer';
}

String formatDate(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value.isEmpty ? '-' : value;
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
}

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
    final email = _emailController.text.trim();
    if (!email.endsWith('@gmail.com')) {
      _snack('Email harus menggunakan @gmail.com!');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$backendBaseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': _passwordController.text,
        }),
      );
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainContainer(
              userName: userData['name']?.toString() ?? 'Customer',
              email: userData['email']?.toString() ?? email,
              role: userData['role']?.toString() ?? 'Customer',
              userId: _intValue(userData['userId']),
            ),
          ),
        );
      } else {
        _snack('Login gagal! Email/password salah.');
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
              const Icon(Icons.movie_filter, size: 100, color: AppColors.gold),
              const SizedBox(height: 20),
              const Text(
                'TIXTIX PREMIERE',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                'PREMIERE ACCESS',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 50),
              _AuthField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
              ),
              const SizedBox(height: 18),
              _AuthField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                obscure: true,
              ),
              const SizedBox(height: 38),
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.gold)
                  : PrimaryButton(label: 'SIGN IN', onPressed: _login),
              const SizedBox(height: 18),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                ),
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(color: AppColors.gold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    final email = _emailController.text.trim();
    if (_selectedRole == 'Admin' && email != 'admin@gmail.com') {
      _snack('Akses ditolak! Hanya akun resmi yang bisa menjadi Admin.');
      return;
    }
    if (!email.endsWith('@gmail.com')) {
      _snack('Email harus menggunakan @gmail.com!');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$backendBaseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'email': email,
          'password': _passwordController.text,
          'admin': _selectedRole == 'Admin',
        }),
      );
      if (response.statusCode == 200) {
        _snack('Registrasi berhasil! Silakan login.');
        if (mounted) Navigator.pop(context);
      } else {
        _snack('Registrasi gagal! Mungkin email sudah terdaftar.');
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
              'Create Account',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
            const Text(
              'Join the premiere cinema club',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 36),
            _AuthField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 18),
            _AuthField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
            ),
            const SizedBox(height: 18),
            _AuthField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock,
              obscure: true,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Customer'),
                    value: 'Customer',
                    groupValue: _selectedRole,
                    onChanged: (val) => setState(() => _selectedRole = val!),
                    activeColor: AppColors.gold,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Admin'),
                    value: 'Admin',
                    groupValue: _selectedRole,
                    onChanged: (val) => setState(() => _selectedRole = val!),
                    activeColor: AppColors.gold,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator(color: AppColors.gold)
                : PrimaryButton(label: 'REGISTER', onPressed: _register),
          ],
        ),
      ),
    );
  }
}

class MainContainer extends StatefulWidget {
  final String userName;
  final String email;
  final String role;
  final int userId;

  const MainContainer({
    super.key,
    required this.userName,
    required this.email,
    required this.role,
    required this.userId,
  });

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;
  int _ticketRefresh = 0;

  void _showTickets() {
    setState(() {
      _selectedIndex = 2;
      _ticketRefresh++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        userName: widget.userName,
        role: widget.role,
        userId: widget.userId,
        onBookingComplete: _showTickets,
      ),
      const SearchPage(),
      TicketPage(userId: widget.userId, refreshKey: _ticketRefresh),
      ProfilePage(
        userName: widget.userName,
        email: widget.email,
        role: widget.role,
        userId: widget.userId,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: AppColors.gold,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            label: 'Ticket',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String userName;
  final String role;
  final int userId;
  final VoidCallback onBookingComplete;

  const HomePage({
    super.key,
    required this.userName,
    required this.role,
    required this.userId,
    required this.onBookingComplete,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _api = const CinemaApi();
  late Future<List<CinemaMovie>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _api.fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.role.toLowerCase() == 'admin';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAdmin ? 'ADMIN DASHBOARD' : 'TIXTIX PREMIERE',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () async {
          setState(() => _moviesFuture = _api.fetchMovies());
          await _moviesFuture;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${widget.userName}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Logged in as ${widget.role}',
                style: const TextStyle(color: AppColors.gold, fontSize: 12),
              ),
              const SizedBox(height: 30),
              if (isAdmin)
                const AdminTools()
              else ...[
                const Text(
                  'Now Playing',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 15),
                FutureBuilder<List<CinemaMovie>>(
                  future: _moviesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return ErrorPanel(
                        message: 'Could not load movies.\n${snapshot.error}',
                        onRetry: () =>
                            setState(() => _moviesFuture = _api.fetchMovies()),
                      );
                    }
                    final movies = snapshot.data ?? [];
                    if (movies.isEmpty) {
                      return const EmptyState(message: 'No movies available.');
                    }
                    return Column(
                      children: movies
                          .map(
                            (movie) => Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: MovieCard(
                                movie: movie,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MovieDetailPage(
                                      movie: movie,
                                      userId: widget.userId,
                                      onBookingComplete:
                                          widget.onBookingComplete,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final CinemaMovie movie;
  final VoidCallback onTap;

  const MovieCard({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 138,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            PosterImage(
              url: movie.posterUrl,
              title: movie.title,
              width: 100,
              height: 138,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      movie.genre,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black,
                          fixedSize: const Size(132, 38),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'BOOK NOW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

class MovieDetailPage extends StatefulWidget {
  final CinemaMovie movie;
  final int userId;
  final VoidCallback onBookingComplete;

  const MovieDetailPage({
    super.key,
    required this.movie,
    required this.userId,
    required this.onBookingComplete,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final _api = const CinemaApi();
  late Future<List<MovieSchedule>> _schedulesFuture;
  MovieSchedule? _selectedSchedule;

  @override
  void initState() {
    super.initState();
    _schedulesFuture = _api.fetchSchedules(widget.movie.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 330,
            pinned: true,
            backgroundColor: AppColors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.movie.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.panel,
                      child: const Icon(
                        Icons.movie,
                        color: AppColors.gold,
                        size: 72,
                      ),
                    ),
                  ),
                  Container(color: Colors.black.withOpacity(0.62)),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.black],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 26,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        PosterImage(
                          url: widget.movie.posterUrl,
                          title: widget.movie.title,
                          width: 98,
                          height: 142,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.movie.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.movie.genre,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                children: [
                                  SmallPill(text: '${widget.movie.duration}m'),
                                  const SmallPill(text: '2D'),
                                  SmallPill(text: rupiah(widget.movie.price)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Schedule'),
                  const SizedBox(height: 16),
                  FutureBuilder<List<MovieSchedule>>(
                    future: _schedulesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(28),
                            child: CircularProgressIndicator(
                              color: AppColors.gold,
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return ErrorPanel(
                          message:
                              'Could not load schedules.\n${snapshot.error}',
                          onRetry: () => setState(
                            () => _schedulesFuture = _api.fetchSchedules(
                              widget.movie.id,
                            ),
                          ),
                        );
                      }
                      final schedules = snapshot.data ?? [];
                      if (schedules.isEmpty) {
                        return const EmptyState(
                          message: 'No showtimes available.',
                        );
                      }
                      return SchedulePicker(
                        movie: widget.movie,
                        schedules: schedules,
                        selected: _selectedSchedule,
                        onSelected: (schedule) =>
                            setState(() => _selectedSchedule = schedule),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const SectionTitle('Details'),
                  const SizedBox(height: 10),
                  Text(
                    widget.movie.synopsis.isEmpty
                        ? 'Synopsis is not available.'
                        : widget.movie.synopsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: PrimaryButton(
          label: _selectedSchedule == null
              ? 'SELECT SHOWTIME'
              : 'CONTINUE TO SEATS',
          onPressed: _selectedSchedule == null
              ? null
              : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SeatSelectionPage(
                      movie: widget.movie,
                      schedule: _selectedSchedule!,
                      userId: widget.userId,
                      onBookingComplete: widget.onBookingComplete,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class SchedulePicker extends StatelessWidget {
  final CinemaMovie movie;
  final List<MovieSchedule> schedules;
  final MovieSchedule? selected;
  final ValueChanged<MovieSchedule> onSelected;

  const SchedulePicker({
    super.key,
    required this.movie,
    required this.schedules,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<MovieSchedule>>{};
    for (final schedule in schedules) {
      grouped.putIfAbsent(schedule.date, () => []).add(schedule);
    }

    return Column(
      children: grouped.entries.map((entry) {
        final times = entry.value..sort((a, b) => a.time.compareTo(b.time));
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gold.withOpacity(0.16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatDate(entry.key),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Cinema TIXTIX - Reguler 2D',
                          style: TextStyle(color: AppColors.softGold),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    rupiah(movie.price),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: times.map((schedule) {
                  final isSelected =
                      selected?.scheduleId == schedule.scheduleId;
                  return ChoiceChip(
                    selected: isSelected,
                    label: SizedBox(
                      width: 92,
                      child: Center(
                        child: Text(
                          schedule.time,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    onSelected: (_) => onSelected(schedule),
                    showCheckmark: false,
                    selectedColor: AppColors.gold,
                    backgroundColor: AppColors.softGold,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.black87,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class SeatSelectionPage extends StatefulWidget {
  final CinemaMovie movie;
  final MovieSchedule schedule;
  final int userId;
  final VoidCallback onBookingComplete;

  const SeatSelectionPage({
    super.key,
    required this.movie,
    required this.schedule,
    required this.userId,
    required this.onBookingComplete,
  });

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  final _api = const CinemaApi();
  late Future<List<CinemaSeat>> _seatsFuture;
  final Set<int> _selectedSeatIds = {};

  @override
  void initState() {
    super.initState();
    _seatsFuture = _api.fetchSeats(widget.schedule.scheduleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.movie.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${formatDate(widget.schedule.date)} • ${widget.schedule.time}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<CinemaSeat>>(
        future: _seatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: ErrorPanel(
                message: 'Could not load seats.\n${snapshot.error}',
                onRetry: () => setState(
                  () => _seatsFuture = _api.fetchSeats(
                    widget.schedule.scheduleId,
                  ),
                ),
              ),
            );
          }

          final seats = (snapshot.data ?? [])..sort(_seatSorter);
          if (seats.isEmpty) {
            return const EmptyState(message: 'No seats for this schedule.');
          }

          return Column(
            children: [
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: Colors.white,
                child: const Center(
                  child: Text(
                    'S c r e e n   a r e a',
                    style: TextStyle(
                      color: Colors.black45,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.12,
                  ),
                  itemCount: seats.length,
                  itemBuilder: (context, index) {
                    final seat = seats[index];
                    final selected = _selectedSeatIds.contains(seat.id);
                    return SeatTile(
                      seat: seat,
                      selected: selected,
                      onTap: seat.isBooked
                          ? null
                          : () => setState(() {
                              if (selected) {
                                _selectedSeatIds.remove(seat.id);
                              } else {
                                _selectedSeatIds.add(seat.id);
                              }
                            }),
                    );
                  },
                ),
              ),
              _SeatBottomBar(
                movie: widget.movie,
                schedule: widget.schedule,
                seats: seats,
                selectedSeatIds: _selectedSeatIds,
                onClear: () => setState(_selectedSeatIds.clear),
                onContinue: () {
                  final selectedSeats = seats
                      .where((seat) => _selectedSeatIds.contains(seat.id))
                      .toList();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingConfirmationPage(
                        movie: widget.movie,
                        schedule: widget.schedule,
                        selectedSeats: selectedSeats,
                        userId: widget.userId,
                        onBookingComplete: widget.onBookingComplete,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  int _seatSorter(CinemaSeat a, CinemaSeat b) {
    final reg = RegExp(r'^([A-Za-z]+)(\d+)$');
    final ma = reg.firstMatch(a.seatNumber);
    final mb = reg.firstMatch(b.seatNumber);
    if (ma == null || mb == null) return a.seatNumber.compareTo(b.seatNumber);
    final row = ma.group(1)!.compareTo(mb.group(1)!);
    if (row != 0) return row;
    return _intValue(ma.group(2)).compareTo(_intValue(mb.group(2)));
  }
}

class SeatTile extends StatelessWidget {
  final CinemaSeat seat;
  final bool selected;
  final VoidCallback? onTap;

  const SeatTile({
    super.key,
    required this.seat,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = seat.isBooked
        ? AppColors.bookedSeat
        : selected
        ? AppColors.gold
        : AppColors.warmSeat;
    final textColor = selected
        ? Colors.black
        : seat.isBooked
        ? Colors.white30
        : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withOpacity(0.06),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            seat.seatNumber,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _SeatBottomBar extends StatelessWidget {
  final CinemaMovie movie;
  final MovieSchedule schedule;
  final List<CinemaSeat> seats;
  final Set<int> selectedSeatIds;
  final VoidCallback onClear;
  final VoidCallback onContinue;

  const _SeatBottomBar({
    required this.movie,
    required this.schedule,
    required this.seats,
    required this.selectedSeatIds,
    required this.onClear,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final selectedSeats = seats
        .where((seat) => selectedSeatIds.contains(seat.id))
        .map((seat) => seat.seatNumber)
        .join(', ');
    final total = selectedSeatIds.length * movie.price;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.black.withOpacity(0.96),
        border: const Border(top: BorderSide(color: Colors.white12)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Legend(color: AppColors.warmSeat, label: 'Available'),
                Legend(color: AppColors.bookedSeat, label: 'Booked'),
                Legend(color: AppColors.gold, label: 'Selected'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedSeats.isEmpty ? '-' : selectedSeats,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${selectedSeatIds.length} seat picked',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  rupiah(total),
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: selectedSeatIds.isEmpty ? null : onClear,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('Clear picks'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: PrimaryButton(
                    label: 'Continue',
                    onPressed: selectedSeatIds.isEmpty ? null : onContinue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BookingConfirmationPage extends StatefulWidget {
  final CinemaMovie movie;
  final MovieSchedule schedule;
  final List<CinemaSeat> selectedSeats;
  final int userId;
  final VoidCallback onBookingComplete;

  const BookingConfirmationPage({
    super.key,
    required this.movie,
    required this.schedule,
    required this.selectedSeats,
    required this.userId,
    required this.onBookingComplete,
  });

  @override
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  @override
  Widget build(BuildContext context) {
    final seats = widget.selectedSeats
        .map((seat) => seat.seatNumber)
        .join(', ');
    final subtotal = widget.selectedSeats.length * widget.movie.price;
    const serviceFee = 0.0;
    final total = subtotal + serviceFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'REVIEW ORDER',
          style: TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: AppColors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 18, 28, 120),
        children: [
          Center(
            child: PosterImage(
              url: widget.movie.posterUrl,
              title: widget.movie.title,
              width: min(MediaQuery.of(context).size.width - 88, 360),
              height: 430,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            widget.movie.title.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${formatDate(widget.schedule.date)}  •  ${widget.schedule.time}  •  Cinema TIXTIX',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.softPanel,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.gold.withOpacity(0.18)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.chair_outlined, color: AppColors.gold),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Selected seats',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        seats,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 34),
                _PriceRow(
                  label: 'Ticket price',
                  value:
                      '${rupiah(widget.movie.price)} x ${widget.selectedSeats.length}',
                ),
                const _PriceRow(label: 'Service fee', value: 'Rp0'),
                _PriceRow(
                  label: 'Showtime',
                  value:
                      '${widget.schedule.time}, ${formatDate(widget.schedule.date)}',
                ),
                const _PriceRow(label: 'Cinema', value: 'Cinema TIXTIX'),
              ],
            ),
          ),
          const SizedBox(height: 34),
          const Text(
            'GRAND TOTAL',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  rupiah(total),
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.confirmation_number_outlined,
                color: AppColors.softGold,
                size: 34,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(28, 12, 28, 22),
        child: GoldActionButton(
          label: 'CONTINUE',
          icon: Icons.arrow_forward,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentMethodPage(
                movie: widget.movie,
                schedule: widget.schedule,
                selectedSeats: widget.selectedSeats,
                userId: widget.userId,
                onBookingComplete: widget.onBookingComplete,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentMethodPage extends StatefulWidget {
  final CinemaMovie movie;
  final MovieSchedule schedule;
  final List<CinemaSeat> selectedSeats;
  final int userId;
  final VoidCallback onBookingComplete;

  const PaymentMethodPage({
    super.key,
    required this.movie,
    required this.schedule,
    required this.selectedSeats,
    required this.userId,
    required this.onBookingComplete,
  });

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final _api = const CinemaApi();
  bool _isSubmitting = false;

  Future<void> _confirmBooking() async {
    setState(() => _isSubmitting = true);
    try {
      final ticket = await _api.createBooking(
        userId: widget.userId,
        scheduleId: widget.schedule.scheduleId,
        seatIds: widget.selectedSeats.map((seat) => seat.id).toList(),
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => TicketDetailPage(ticket: ticket)),
        (route) => route.isFirst,
      );
      widget.onBookingComplete();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Booking gagal: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final seats = widget.selectedSeats
        .map((seat) => seat.seatNumber)
        .join(', ');
    final subtotal = widget.selectedSeats.length * widget.movie.price;
    const serviceFee = 0.0;
    final total = subtotal + serviceFee;
    final posterWidth = min(MediaQuery.of(context).size.width * 0.34, 150.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confirm Booking',
          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 130),
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 204),
            decoration: BoxDecoration(
              color: AppColors.softPanel,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.gold.withOpacity(0.18)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  right: 0,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Opacity(
                      opacity: 0.18,
                      child: widget.movie.posterUrl.isEmpty
                          ? const SizedBox.shrink()
                          : Image.network(
                              widget.movie.posterUrl,
                              width: posterWidth,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 14,
                        runSpacing: 8,
                        children: [
                          PaymentMeta(
                            icon: Icons.access_time,
                            text: widget.schedule.time,
                          ),
                          PaymentMeta(
                            icon: Icons.chair_outlined,
                            text: 'Seats $seats',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'TOTAL BOOKING',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        rupiah(total),
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 31,
                          fontWeight: FontWeight.bold,
                          height: 1.05,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          const Text(
            'BOOKING ACTION',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.softPanel,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.gold, width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create ticket',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Booking will be saved to database',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.gold,
                  child: Icon(Icons.check, color: Colors.black, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: PaymentInfoBox(
                  label: 'TICKET TOTAL',
                  value: rupiah(subtotal),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: PaymentInfoBox(
                  label: 'BOOKING STATUS',
                  value: 'SUCCESS',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          PaymentInfoBox(
            label: 'SHOWTIME',
            value:
                '${formatDate(widget.schedule.date)}, ${widget.schedule.time}',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(28, 12, 28, 22),
        child: GoldActionButton(
          label: _isSubmitting ? 'PROCESSING...' : 'CONFIRM BOOKING',
          onPressed: _isSubmitting ? null : _confirmBooking,
        ),
      ),
    );
  }
}

class TicketPage extends StatefulWidget {
  final int userId;
  final int refreshKey;

  const TicketPage({super.key, required this.userId, required this.refreshKey});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final _api = const CinemaApi();
  late Future<List<BookingTicket>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _api.fetchUserBookings(widget.userId);
  }

  @override
  void didUpdateWidget(covariant TicketPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) {
      _bookingsFuture = _api.fetchUserBookings(widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MY TICKETS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<List<BookingTicket>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: ErrorPanel(
                message: 'Could not load tickets.\n${snapshot.error}',
                onRetry: () => setState(
                  () => _bookingsFuture = _api.fetchUserBookings(widget.userId),
                ),
              ),
            );
          }

          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const EmptyState(message: 'No bookings found.');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final ticket = bookings[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: TicketCard(
                  ticket: ticket,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketDetailPage(ticket: ticket),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  final BookingTicket ticket;
  final VoidCallback onTap;

  const TicketCard({super.key, required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            MiniQrCode(data: ticket.bookingCode, size: 74),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.movieTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${formatDate(ticket.showDate)}, ${ticket.showTime}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    ticket.seatNumbers.join(', '),
                    style: const TextStyle(color: AppColors.softGold),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class TicketDetailPage extends StatelessWidget {
  final BookingTicket ticket;

  const TicketDetailPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold.withOpacity(0.14)),
            ),
            child: Column(
              children: [
                const Text('Order code', style: TextStyle(color: Colors.grey)),
                Text(
                  ticket.bookingCode,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                MiniQrCode(data: ticket.bookingCode, size: 190),
                const SizedBox(height: 12),
                const Text(
                  'Scan to redeem',
                  style: TextStyle(color: Colors.white70),
                ),
                const Divider(color: Colors.white24, height: 38),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.movieTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const IconLine(
                        icon: Icons.local_movies_outlined,
                        text: 'Cinema TIXTIX',
                      ),
                      IconLine(
                        icon: Icons.event,
                        text:
                            '${formatDate(ticket.showDate)}, ${ticket.showTime}',
                      ),
                      IconLine(
                        icon: Icons.chair_outlined,
                        text: ticket.seatNumbers.join(', '),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _PriceRow(
                  label: 'Total payment',
                  value: rupiah(ticket.totalPrice),
                  strong: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MiniQrCode extends StatelessWidget {
  final String data;
  final double size;

  const MiniQrCode({super.key, required this.data, required this.size});

  @override
  Widget build(BuildContext context) {
    final random = Random(data.hashCode);
    const count = 17;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      color: Colors.white,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: count * count,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
        ),
        itemBuilder: (_, index) {
          final row = index ~/ count;
          final col = index % count;
          final finder =
              (row < 5 && col < 5) ||
              (row < 5 && col > count - 6) ||
              (row > count - 6 && col < 5);
          final filled =
              finder ||
              random.nextBool() &&
                  ((row + col + data.length) % 3 != 0 || index.isEven);
          return Container(color: filled ? Colors.black : Colors.white);
        },
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Use Home to browse database movies.',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String userName;
  final String email;
  final String role;
  final int userId;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.email,
    required this.role,
    required this.userId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _api = const CinemaApi();
  late Future<ProfileSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _api.fetchProfileSummary(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PROFILE',
          style: TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.black,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(userName: widget.userName),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined, color: AppColors.gold),
          ),
        ],
      ),
      body: FutureBuilder<ProfileSummary>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: ErrorPanel(
                message: 'Could not load profile.\n${snapshot.error}',
                onRetry: () => setState(
                  () =>
                      _summaryFuture = _api.fetchProfileSummary(widget.userId),
                ),
              ),
            );
          }

          final summary =
              snapshot.data ??
              const ProfileSummary(moviesWatched: 0, transactionHistory: []);

          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () async {
              setState(
                () => _summaryFuture = _api.fetchProfileSummary(widget.userId),
              );
              await _summaryFuture;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
              children: [
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 58,
                          backgroundColor: AppColors.softPanel,
                          child: Icon(
                            Icons.person,
                            size: 70,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 4,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  widget.userName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softPanel,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.24),
                      ),
                    ),
                    child: Text(
                      widget.role.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 34),

                const Text(
                  'ACCOUNT SETTINGS',
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      ProfileMenuTile(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        onTap: () => _showChangePasswordDialog(context),
                      ),

                      const Divider(color: Colors.white10, height: 1),
                      ProfileMenuTile(
                        icon: Icons.receipt_long_outlined,
                        title: 'Transaction History',
                        subtitle:
                            '${summary.transactionHistory.length} bookings',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransactionHistoryPage(
                              transactions: summary.transactionHistory,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('LOGOUT'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent.shade100,
                    side: BorderSide(color: Colors.redAccent.withOpacity(0.22)),
                    backgroundColor: Colors.redAccent.withOpacity(0.08),
                    minimumSize: const Size(double.infinity, 58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.panel,
              title: const Text('Change Password', style: TextStyle(color: AppColors.gold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Old Password'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'New Password'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: 20, height: 20, 
                          child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2)
                        ),
                      )
                    : TextButton(
                        onPressed: () async {
                          final oldPass = oldPasswordController.text;
                          final newPass = newPasswordController.text;
                          if (oldPass.isEmpty || newPass.isEmpty) return;

                          setState(() => isLoading = true);
                          try {
                            final success = await _api.changePassword(widget.userId, oldPass, newPass);
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(success ? 'Password successfully changed!' : 'Failed: Incorrect old password.')),
                              );
                            }
                          } catch (e) {
                            setState(() => isLoading = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('Save', style: TextStyle(color: AppColors.gold)),
                      ),
              ],
            );
          },
        );
      },
    );
  }
}

class ProfileStatCard extends StatelessWidget {
  final String label;
  final String value;

  const ProfileStatCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.softGold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.softPanel,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.gold),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: const TextStyle(color: Colors.white54)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
    );
  }
}

class TransactionHistoryPage extends StatelessWidget {
  final List<BookingTicket> transactions;

  const TransactionHistoryPage({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.black,
      ),
      body: transactions.isEmpty
          ? const EmptyState(message: 'No transaction history yet.')
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final item = transactions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: TicketCard(
                    ticket: item,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TicketDetailPage(ticket: item),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final String userName;

  const SettingsPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.gold),
              title: const Text('Account'),
              subtitle: Text(userName),
              trailing: const Icon(Icons.chevron_right),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'LOGOUT',
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class AdminTools extends StatelessWidget {
  const AdminTools({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Management Tools',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 15),
        AdminCard(icon: Icons.movie, title: 'Movie Management'),
        SizedBox(height: 15),
        AdminCard(icon: Icons.calendar_today, title: 'Schedule Management'),
      ],
    );
  }
}

class AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const AdminCard({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: AppColors.gold),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

class PosterImage extends StatelessWidget {
  final String url;
  final String title;
  final double width;
  final double height;

  const PosterImage({
    super.key,
    required this.url,
    this.title = '',
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url.isEmpty
          ? _PosterPlaceholder(title: title, width: width, height: height)
          : Image.network(
              url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _PosterPlaceholder(
                title: title,
                width: width,
                height: height,
              ),
            ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  final String title;
  final double width;
  final double height;

  const _PosterPlaceholder({
    required this.title,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = title.trim().isEmpty ? 'MOVIE' : title.trim();

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF303030), Color(0xFF141414), Color(0xFF0A0A0A)],
        ),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        children: [
          const Icon(Icons.local_movies_outlined, color: AppColors.gold),
          const Spacer(),
          Text(
            displayTitle.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 2, width: 32, color: AppColors.gold),
        ],
      ),
    );
  }
}

class SmallPill extends StatelessWidget {
  final String text;

  const SmallPill({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        disabledBackgroundColor: Colors.white24,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class GoldActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const GoldActionButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        disabledBackgroundColor: AppColors.softPanel,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 58),
        elevation: 12,
        shadowColor: AppColors.gold.withOpacity(0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 10),
            Icon(icon, size: 22),
          ],
        ],
      ),
    );
  }
}

class PaymentMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const PaymentMeta({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class PaymentInfoBox extends StatelessWidget {
  final String label;
  final String value;

  const PaymentInfoBox({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.gold),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class Legend extends StatelessWidget {
  final Color color;
  final String label;

  const Legend({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class IconLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const IconLine({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _PriceRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: strong ? FontWeight.bold : FontWeight.w500,
      color: strong ? Colors.white : Colors.white70,
      fontSize: strong ? 16 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Flexible(
            child: Text(value, textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

class ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorPanel({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String message;

  const EmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

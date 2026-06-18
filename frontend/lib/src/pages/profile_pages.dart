import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../models/cinema_models.dart';
import '../services/cinema_api.dart';
import '../theme/tc.dart';
import 'auth_pages.dart';

class ProfilePage extends StatelessWidget {
  final int userId;
  final String userName;
  final String email;
  final String role;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenChangePassword;
  final VoidCallback? onOpenAdmin;

  const ProfilePage({
    super.key,
    required this.userId,
    required this.userName,
    required this.email,
    required this.role,
    required this.onOpenHistory,
    required this.onOpenChangePassword,
    required this.onOpenAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cinemaBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              _profileHeader(),
              const SizedBox(height: 14),
              _menuTile(
                icon: Icons.receipt_long_rounded,
                title: 'Riwayat Transaksi',
                subtitle: 'Tiket yang telah dipesan',
                onTap: onOpenHistory,
              ),
              _menuTile(
                icon: Icons.lock_reset_rounded,
                title: 'Ubah Kata Sandi',
                subtitle: 'Perbarui kata sandi akun',
                onTap: onOpenChangePassword,
              ),
              if (onOpenAdmin != null)
                _menuTile(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Panel Admin',
                  subtitle: 'Kelola film dan jadwal',
                  onTap: onOpenAdmin!,
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Keluar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: CinemaTheme.danger,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        color: CinemaTheme.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: CinemaTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [CinemaTheme.accent, CinemaTheme.purple],
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.black,
              size: 42,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CinemaTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CinemaTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          _roleChip(role),
        ],
      ),
    );
  }

  Widget _profileStats() {
    return cinemaCard(
      child: FutureBuilder<ProfileSummary>(
        future: fetchProfileSummary(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(color: CinemaTheme.accent),
              ),
            );
          }
          if (snapshot.hasError) {
            return const Text(
              'Stats unavailable',
              textAlign: TextAlign.center,
              style: TextStyle(color: CinemaTheme.textSecondary),
            );
          }
          final data = snapshot.data!;
          return Row(
            children: [
              Expanded(
                child: _statTile(
                  icon: Icons.local_movies_outlined,
                  label: 'Movies watched',
                  value: data.moviesWatched.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'History items',
                  value: data.transactionHistory.length.toString(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _roleChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: CinemaTheme.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: CinemaTheme.accent.withValues(alpha: 0.3)),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: CinemaTheme.accent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CinemaTheme.cardAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: CinemaTheme.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: CinemaTheme.accent, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: CinemaTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: CinemaTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = CinemaTheme.accent,
    Color titleColor = CinemaTheme.textPrimary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: cinemaCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CinemaTheme.cardAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: CinemaTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: CinemaTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionHistoryPage extends StatefulWidget {
  final int userId;
  const TransactionHistoryPage({super.key, required this.userId});
  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  late Future<List<BookingHistoryItem>> _future;
  @override
  void initState() {
    super.initState();
    _future = fetchBookingHistory(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cinemaBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Transaction History',
                      style: TextStyle(
                        color: CinemaTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<List<BookingHistoryItem>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: CinemaTheme.accent,
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Failed to load history',
                            style: TextStyle(color: CinemaTheme.textSecondary),
                          ),
                        );
                      }
                      final items = snapshot.data ?? const [];
                      if (items.isEmpty) {
                        return const Center(
                          child: Text(
                            'No transactions yet',
                            style: TextStyle(color: CinemaTheme.textSecondary),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return cinemaCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.movieTitle,
                                  style: const TextStyle(
                                    color: CinemaTheme.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.bookingDate} • ${item.showTime}',
                                  style: const TextStyle(
                                    color: CinemaTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.seatNumbers.join(', '),
                                  style: const TextStyle(
                                    color: CinemaTheme.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.bookingCode,
                                      style: const TextStyle(
                                        color: CinemaTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      money(item.totalPrice),
                                      style: const TextStyle(
                                        color: CinemaTheme.textPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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
  final _current = TextEditingController();
  final _newPass = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  void _snack(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
  Future<void> _submit() async {
    if (_current.text.isEmpty) {
      return _snack('Current password is required');
    }
    if (_newPass.text.length < 8) {
      return _snack('New password must be at least 8 characters');
    }
    if (_newPass.text != _confirm.text) {
      return _snack('Confirm password does not match');
    }
    setState(() => _loading = true);
    try {
      await changePassword(
        email: widget.email,
        currentPassword: _current.text,
        newPassword: _newPass.text,
      );
      if (!mounted) return;
      _snack('Password updated successfully');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: cinemaBackdrop(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Change Password',
                  style: TextStyle(
                    color: CinemaTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            cinemaCard(
              child: Column(
                children: [
                  TextField(
                    controller: _current,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current password',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPass,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New password',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirm,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: CinemaTheme.accent,
                        foregroundColor: Colors.black,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text('Update Password'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class AdminPanelPage extends StatefulWidget {
  final int userId;
  const AdminPanelPage({super.key, required this.userId});
  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<MovieData>> _moviesFuture;
  late Future<List<ScheduleSlot>> _schedulesFuture;
  late Future<List<PromotionItem>> _adsFuture;
  final _movieTitle = TextEditingController();
  final _movieGenre = TextEditingController();
  final _movieDuration = TextEditingController();
  final _movieSynopsis = TextEditingController();
  final _moviePrice = TextEditingController();
  final _movieImage = TextEditingController();
  final _movieStatus = TextEditingController(text: 'Now Showing');
  final _scheduleMovieId = TextEditingController();
  final _scheduleDate = TextEditingController();
  final _scheduleTime = TextEditingController();
  final _scheduleHall = TextEditingController();
  final _adTitle = TextEditingController();
  final _adImage = TextEditingController();
  final _adLink = TextEditingController();
  final _adSort = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _moviesFuture = fetchAdminMovies();
    _schedulesFuture = fetchAdminSchedules();
    _adsFuture = fetchPromotions();
  }

  Future<void> _pickAndUploadImage(TextEditingController target) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null) return;
    final file = result.files.single;
    final url = kIsWeb
        ? await uploadImageBytes(
            filename: file.name,
            bytes: file.bytes ?? Uint8List(0),
          )
        : await uploadImageFile(
            file.path ?? (throw Exception('Selected file path is empty')),
          );
    if (!mounted) return;
    setState(() => target.text = url);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Image uploaded')));
  }

  void _refresh() {
    setState(() {
      _moviesFuture = fetchAdminMovies();
      _schedulesFuture = fetchAdminSchedules();
      _adsFuture = fetchPromotions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _movieTitle.dispose();
    _movieGenre.dispose();
    _movieDuration.dispose();
    _movieSynopsis.dispose();
    _moviePrice.dispose();
    _movieImage.dispose();
    _movieStatus.dispose();
    _scheduleMovieId.dispose();
    _scheduleDate.dispose();
    _scheduleTime.dispose();
    _scheduleHall.dispose();
    _adTitle.dispose();
    _adImage.dispose();
    _adLink.dispose();
    _adSort.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cinemaBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: CinemaTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: CinemaTheme.accent,
                  unselectedLabelColor: CinemaTheme.textSecondary,
                  indicatorColor: CinemaTheme.accent,
                  tabs: const [
                    Tab(text: 'Movies'),
                    Tab(text: 'Schedules'),
                    Tab(text: 'Ads'),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_movieTab(), _scheduleTab(), _adsTab()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CinemaTheme.accent,
        foregroundColor: Colors.black,
        onPressed: _refresh,
        child: const Icon(Icons.refresh_rounded),
      ),
    );
  }

  Widget _movieTab() {
    return FutureBuilder<List<MovieData>>(
      future: _moviesFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: CinemaTheme.accent),
          );
        }
        if (snap.hasError) {
          return const Center(
            child: Text(
              'Failed to load movies',
              style: TextStyle(color: CinemaTheme.textSecondary),
            ),
          );
        }
        final movies = snap.data ?? const [];
        return ListView(
          children: [
            cinemaCard(
              child: Column(
                children: [
                  TextField(
                    controller: _movieTitle,
                    decoration: const InputDecoration(labelText: 'Movie title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _movieGenre,
                    decoration: const InputDecoration(labelText: 'Genre'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _movieDuration,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration minutes',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _movieSynopsis,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Synopsis'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _moviePrice,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ticket price',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _movieImage,
                    decoration: const InputDecoration(labelText: 'Poster URL'),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _pickAndUploadImage(_movieImage),
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Pick poster from laptop'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _movieStatus.text,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Now Showing',
                        child: Text('Now Showing'),
                      ),
                      DropdownMenuItem(
                        value: 'Coming Soon',
                        child: Text('Coming Soon'),
                      ),
                    ],
                    onChanged: (value) => setState(
                      () => _movieStatus.text = value ?? 'Now Showing',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        await saveAdminMovie(
                          title: _movieTitle.text,
                          code: _movieTitle.text.toLowerCase().replaceAll(' ', '_'),
                          genre: _movieGenre.text,
                          duration: int.tryParse(_movieDuration.text) ?? 0,
                          synopsis: _movieSynopsis.text,
                          price: double.tryParse(_moviePrice.text) ?? 0,
                          imageUrl: _movieImage.text,
                          status: _movieStatus.text,
                        );
                        _movieTitle.clear();
                        _movieGenre.clear();
                        _movieDuration.clear();
                        _movieSynopsis.clear();
                        _moviePrice.clear();
                        _movieImage.clear();
                        _movieStatus.text = 'Now Showing';
                        _refresh();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: CinemaTheme.accent,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Save Movie'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (movies.isEmpty)
              const Center(
                child: Text(
                  'No movies found',
                  style: TextStyle(color: CinemaTheme.textSecondary),
                ),
              )
            else
              ...movies.map((movie) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: cinemaCard(
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            movie.imgUrl,
                            headers: const {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'},
                            width: 60,
                            height: 84,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 60,
                                  height: 84,
                                  color: CinemaTheme.cardAlt,
                                ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                style: const TextStyle(
                                  color: CinemaTheme.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                movie.genre,
                                style: const TextStyle(
                                  color: CinemaTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                money(movie.price),
                                style: const TextStyle(
                                  color: CinemaTheme.accent,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () async =>
                              _pickAndUploadImage(_movieImage),
                          icon: const Icon(
                            Icons.image_rounded,
                            color: CinemaTheme.accent,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await deleteAdminMovie(movie.id);
                            _refresh();
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: CinemaTheme.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _scheduleTab() {
    return FutureBuilder<List<ScheduleSlot>>(
      future: _schedulesFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: CinemaTheme.accent),
          );
        }
        if (snap.hasError) {
          return const Center(
            child: Text(
              'Failed to load schedules',
              style: TextStyle(color: CinemaTheme.textSecondary),
            ),
          );
        }
        final schedules = snap.data ?? const [];
        return ListView(
          children: [
            cinemaCard(
              child: Column(
                children: [
                  TextField(
                    controller: _scheduleMovieId,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Movie ID'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _scheduleDate,
                    decoration: const InputDecoration(
                      labelText: 'Date (YYYY-MM-DD)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _scheduleTime,
                    decoration: const InputDecoration(
                      labelText: 'Time (HH:MM)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _scheduleHall,
                    decoration: const InputDecoration(
                      labelText: 'Hall / Studio',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final movieId =
                            int.tryParse(_scheduleMovieId.text) ?? 0;

                        await saveAdminSchedule(
                          movieId: movieId,
                          date: _scheduleDate.text,
                          time: _scheduleTime.text,
                          hall: _scheduleHall.text,
                        );
                        _scheduleMovieId.clear();
                        _scheduleDate.clear();
                        _scheduleTime.clear();
                        _scheduleHall.clear();
                        _refresh();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: CinemaTheme.accent,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Save Schedule'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (schedules.isEmpty)
              const Center(
                child: Text(
                  'No schedules found',
                  style: TextStyle(color: CinemaTheme.textSecondary),
                ),
              )
            else
              ...schedules.map((schedule) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: cinemaCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Schedule #${schedule.id}',
                                style: const TextStyle(
                                  color: CinemaTheme.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${schedule.date} • ${schedule.time}',
                                style: const TextStyle(
                                  color: CinemaTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                schedule.hall,
                                style: const TextStyle(
                                  color: CinemaTheme.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await deleteAdminSchedule(schedule.id);
                              if (!mounted) return;
                              _refresh();
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Schedule deleted'),
                                ),
                              );
                            } catch (error) {
                              if (!mounted) return;
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to delete schedule: $error',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: CinemaTheme.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _adsTab() {
    return ListView(
      children: [
        cinemaCard(
          child: Column(
            children: [
              TextField(
                controller: _adTitle,
                decoration: const InputDecoration(labelText: 'Ad title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _adImage,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _pickAndUploadImage(_adImage),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Pick image from laptop'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _adLink,
                decoration: const InputDecoration(labelText: 'Link URL'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _adSort,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sort order'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    try {
                      await saveAdvertisement(
                        title: _adTitle.text,
                        imageUrl: _adImage.text,
                        linkUrl: _adLink.text,
                        active: true,
                        sortOrder: int.tryParse(_adSort.text) ?? 0,
                      );
                      if (!mounted) return;
                      _adTitle.clear();
                      _adImage.clear();
                      _adLink.clear();
                      _adSort.text = '0';
                      _refresh();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ad created')),
                      );
                    } catch (error) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create ad: $error')),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: CinemaTheme.accent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Save Ad'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<PromotionItem>>(
          future: _adsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: CinemaTheme.accent),
              );
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Failed to load ads',
                  style: TextStyle(color: CinemaTheme.textSecondary),
                ),
              );
            }
            final items = snapshot.data ?? const [];
            if (items.isEmpty) {
              return const Center(
                child: Text(
                  'No ads found',
                  style: TextStyle(color: CinemaTheme.textSecondary),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ad = items[index];
                return cinemaCard(
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          ad.imageUrl,
                          headers: const {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'},
                          width: 74,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad.title,
                              style: const TextStyle(
                                color: CinemaTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ad.linkUrl.isEmpty ? 'No link' : ad.linkUrl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: CinemaTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sort ${ad.sortOrder}',
                              style: const TextStyle(
                                color: CinemaTheme.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await deleteAdvertisement(ad.id);
                            if (!mounted) return;
                            _refresh();
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Ad deleted')),
                            );
                          } catch (error) {
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete ad: $error'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: CinemaTheme.danger,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  final String userName;
  const SettingsPage({super.key, required this.userName});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: cinemaBackdrop(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              cinemaSectionTitle('Settings', subtitle: userName),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                  style: FilledButton.styleFrom(
                    backgroundColor: CinemaTheme.danger,
                    foregroundColor: Colors.white,
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

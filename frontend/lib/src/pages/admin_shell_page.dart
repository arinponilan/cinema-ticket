import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/cinema_api.dart';
import '../models/cinema_models.dart';
import 'profile_pages.dart';
import '../theme/tc.dart';
import 'auth_pages.dart';

class AdminShellPage extends StatefulWidget {
  final int userId;
  final String userName;
  final String email;
  final String role;

  const AdminShellPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.email,
    required this.role,
  });

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  int _index = 0;
  int _adminDataVersion = 0;

  void _refreshAdminData() {
    setState(() => _adminDataVersion++);
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showTopSnack(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isError ? CinemaTheme.danger : CinemaTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isError ? CinemaTheme.danger : CinemaTheme.accent,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.32),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isError ? Colors.white : CinemaTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), entry.remove);
  }

  Future<void> _pickAndUpload(TextEditingController target) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null) return;

    try {
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
      _showTopSnack('Gambar berhasil diunggah');
    } catch (error) {
      if (!mounted) return;
      _showTopSnack('Gagal mengunggah: $error', isError: true);
    }
  }

  Future<dynamic> _showPopup(Widget child) async {
    return await showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _AdminMovieHub(
        refreshToken: _adminDataVersion,
        onAddMovie: () async {
          final result = await _showPopup(_MoviePopup(onPickImage: _pickAndUpload));
          if (result == true) {
            _refreshAdminData();
          }
        },
        onDataChanged: _refreshAdminData,
        onPickImage: _pickAndUpload,
      ),
      _AdminScheduleHub(
        refreshToken: _adminDataVersion,
        onDataChanged: _refreshAdminData,
      ),
      _AdminAdsNotifHub(
        onAddAds: () => _showPopup(_AdsPopup(onPickImage: _pickAndUpload)),
      ),
      _AdminProfileHub(
        userName: widget.userName,
        email: widget.email,
        onLogout: _logout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: CinemaTheme.panel,
          indicatorColor: CinemaTheme.accent.withValues(alpha: 0.16),
          labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.movie_creation_outlined),
              selectedIcon: Icon(Icons.movie_creation_rounded),
              label: 'Film',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Jadwal',
            ),
            NavigationDestination(
              icon: Icon(Icons.campaign_outlined),
              selectedIcon: Icon(Icons.campaign_rounded),
              label: 'Promo',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMovieHub extends StatefulWidget {
  final int refreshToken;
  final Future<void> Function() onAddMovie;
  final VoidCallback onDataChanged;
  final Future<void> Function(TextEditingController) onPickImage;
  const _AdminMovieHub({
    required this.refreshToken,
    required this.onAddMovie,
    required this.onDataChanged,
    required this.onPickImage,
  });

  @override
  State<_AdminMovieHub> createState() => _AdminMovieHubState();
}

class _AdminMovieHubState extends State<_AdminMovieHub> {
  late Future<List<MovieData>> _moviesFuture;

  @override
  void initState() {
    super.initState();

    _moviesFuture = fetchAdminMovies();
  }

  @override
  void didUpdateWidget(covariant _AdminMovieHub oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _moviesFuture = fetchAdminMovies();
    }
  }

  void _refresh() {
    setState(() {
      _moviesFuture = fetchAdminMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cinemaBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cinemaSectionTitle('Film', subtitle: 'Kelola katalog film'),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    await widget.onAddMovie();
                    widget.onDataChanged();
                    _refresh();
                  },
                  child: cinemaCard(
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: CinemaTheme.accent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: CinemaTheme.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tambah Film',
                                style: TextStyle(
                                  color: CinemaTheme.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Buka popup untuk membuat film baru',
                                style: TextStyle(
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
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<MovieData>>(
                    future: _moviesFuture,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: CinemaTheme.accent,
                          ),
                        );
                      }
                      if (snap.hasError) {
                        return Center(
                          child: Text(
                            'Gagal memuat film',
                            style: const TextStyle(
                              color: CinemaTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      final movies = snap.data ?? const <MovieData>[];
                      final nowShowing = movies
                          .where(
                            (movie) =>
                                movie.status.toLowerCase() == 'now showing',
                          )
                          .toList();
                      final comingSoon = movies
                          .where(
                            (movie) =>
                                movie.status.toLowerCase() == 'coming soon',
                          )
                          .toList();

                      if (movies.isEmpty) {
                        return const Center(
                          child: Text(
                            'Tidak ada film',
                            style: TextStyle(color: CinemaTheme.textSecondary),
                          ),
                        );
                      }

                      return ListView(
                        children: [
                          cinemaCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sedang Tayang',
                                  style: TextStyle(
                                    color: CinemaTheme.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 245,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: nowShowing.isEmpty
                                        ? movies.length
                                        : nowShowing.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      final movie = nowShowing.isEmpty
                                          ? movies[index]
                                          : nowShowing[index];
                                      return _AdminMovieCard(
                                        movie: movie,
                                        onEdit: () async {
                                          await showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (_) => _MoviePopup(
                                              movie: movie,
                                              onPickImage: widget.onPickImage,
                                            ),
                                          );
                                          widget.onDataChanged();
                                          _refresh();
                                        },
                                        onDelete: () async {
                                          try {
                                            await deleteAdminMovie(movie.id);
                                            widget.onDataChanged();
                                            _refresh();
                                          } catch (error) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Hapus film gagal: $error',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          cinemaCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Akan Datang',
                                  style: TextStyle(
                                    color: CinemaTheme.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 320,
                                  child: ListView.separated(
                                    itemCount: comingSoon.isEmpty
                                        ? 0
                                        : comingSoon.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) =>
                                        _AdminMovieListTile(
                                          movie: comingSoon[index],
                                          onEdit: () async {
                                            await showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (_) => _MoviePopup(
                                                movie: comingSoon[index],
                                                onPickImage: widget.onPickImage,
                                              ),
                                            );
                                            widget.onDataChanged();
                                            _refresh();
                                          },
                                          onDelete: () async {
                                            try {
                                              await deleteAdminMovie(
                                                comingSoon[index].id,
                                              );
                                              widget.onDataChanged();
                                              _refresh();
                                            } catch (error) {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Hapus film gagal: $error',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

class _AdminMovieCard extends StatelessWidget {
  final MovieData movie;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _AdminMovieCard({required this.movie, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: CinemaTheme.cardAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.network(
              movie.imgUrl,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 140,
                color: CinemaTheme.cardAlt,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported_rounded,
                  color: CinemaTheme.textSecondary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CinemaTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  movie.genre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CinemaTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: CinemaTheme.accent,
                        size: 18,
                      ),
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: CinemaTheme.danger,
                        size: 18,
                      ),
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      padding: EdgeInsets.zero,
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

class _AdminMovieListTile extends StatelessWidget {
  final MovieData movie;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _AdminMovieListTile({required this.movie, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: CinemaTheme.cardAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              movie.imgUrl,
              width: 56,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 56,
                height: 72,
                color: CinemaTheme.card,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported_rounded,
                  color: CinemaTheme.textSecondary,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CinemaTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  movie.genre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CinemaTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  movie.status,
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
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_rounded,
              color: CinemaTheme.accent,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: CinemaTheme.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminScheduleHub extends StatefulWidget {
  final int refreshToken;
  final VoidCallback onDataChanged;
  const _AdminScheduleHub({
    required this.refreshToken,
    required this.onDataChanged,
  });

  @override
  State<_AdminScheduleHub> createState() => _AdminScheduleHubState();
}

class _AdminScheduleHubState extends State<_AdminScheduleHub> {
  late Future<List<MovieData>> _moviesFuture;
  late Future<List<ScheduleSlot>> _schedulesFuture;

  MovieData? _selectedMovie;
  String _scheduleDate = DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0];
  String _scheduleTime = '10:00:00';
  String _hall = 'Studio 1';
  int? _editingScheduleId;

  final List<String> _timeOptions = ['10:00:00', '13:00:00', '16:00:00', '19:00:00', '22:00:00'];

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_scheduleDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 10)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _scheduleDate = picked.toString().split(' ')[0];
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _moviesFuture = fetchAdminMovies();
    _schedulesFuture = fetchAdminSchedules();
  }

  @override
  void didUpdateWidget(covariant _AdminScheduleHub oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _moviesFuture = fetchAdminMovies();
      _schedulesFuture = fetchAdminSchedules();
    }
  }

  void _refresh() {
    setState(() {
      _moviesFuture = fetchAdminMovies();
      _schedulesFuture = fetchAdminSchedules();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _editSchedule(ScheduleSlot schedule, List<MovieData> movies) {
    setState(() {
      _editingScheduleId = schedule.id;
      _scheduleDate = schedule.date;
      _scheduleTime = schedule.time;
      
      String parsedHall = schedule.hall.replaceAll('Hall', 'Studio');
      if (!List.generate(5, (i) => 'Studio ${i + 1}').contains(parsedHall)) {
        parsedHall = 'Studio 1';
      }
      _hall = parsedHall;
      _selectedMovie = movies.cast<MovieData?>().firstWhere(
            (m) => m?.title == schedule.type, 
            orElse: () => null,
          );
      // Wait, type stores movie title? No, type was used as movie title in backend? 
      // Actually we need to match movie title from the movie list based on some property.
      // Wait, backend Schedule doesn't return movie? Oh, it returns movie! But ScheduleSlot might just have 'type'.
      // Let me re-verify ScheduleSlot in models.
    });
  }

  Future<void> _deleteSchedule(int id) async {
    try {
      await deleteAdminSchedule(id);
      widget.onDataChanged();
      _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hapus jadwal gagal: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cinemaBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cinemaSectionTitle(
                  'Jadwal Tayang',
                  subtitle: 'Atur jadwal film ke studio dan jam tayang',
                ),
                const SizedBox(height: 16),
                cinemaCard(
                  child: FutureBuilder<List<MovieData>>(
                    future: _moviesFuture,
                    builder: (context, snap) {
                      final movies = snap.data ?? const <MovieData>[];
                      
                      // Pastikan referensi objek _selectedMovie sesuai dengan data terbaru dari API
                      MovieData? currentMovie = movies.cast<MovieData?>().firstWhere(
                            (m) => m?.id == _selectedMovie?.id,
                            orElse: () => null,
                          );

                      return Column(
                        children: [
                          DropdownButtonFormField<MovieData>(
                            key: ValueKey(widget.refreshToken),
                            value: currentMovie,
                            decoration: const InputDecoration(
                              labelText: 'Pilih film',
                            ),
                            items: movies
                                .map(
                                  (movie) => DropdownMenuItem<MovieData>(
                                    value: movie,
                                    child: Text(movie.title),
                                  ),
                                )
                                .toList(),
                            onChanged: (movie) =>
                                setState(() => _selectedMovie = movie),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Tanggal Tayang (YYYY-MM-DD)'),
                              child: Text(_scheduleDate, style: const TextStyle(fontWeight: FontWeight.bold, color: CinemaTheme.textPrimary)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _hall,
                            decoration: const InputDecoration(
                              labelText: 'Studio',
                            ),
                            items: List.generate(5, (index) => 'Studio ${index + 1}')
                                .map((studio) => DropdownMenuItem(
                                      value: studio,
                                      child: Text(studio),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _hall = value);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          const Text('Waktu Tayang', style: TextStyle(color: CinemaTheme.textSecondary, fontSize: 12)),
                          const SizedBox(height: 8),
                          FutureBuilder<List<ScheduleSlot>>(
                            future: _schedulesFuture,
                            builder: (context, scheduleSnap) {
                              final schedules = scheduleSnap.data ?? [];
                              // Temukan slot yang sudah terisi di tanggal dan studio ini
                              final takenTimes = schedules
                                  .where((s) => s.date == _scheduleDate && s.hall == _hall && s.id != _editingScheduleId)
                                  .map((s) => s.time)
                                  .toSet();

                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _timeOptions.map((time) {
                                  final isTaken = takenTimes.contains(time);
                                  final isSelected = _scheduleTime == time;
                                  return ChoiceChip(
                                    label: Text(time.substring(0, 5)),
                                    selected: isSelected,
                                    onSelected: isTaken ? null : (selected) {
                                      if (selected) setState(() => _scheduleTime = time);
                                    },
                                    selectedColor: CinemaTheme.accent,
                                    labelStyle: TextStyle(
                                      color: isTaken ? CinemaTheme.textSecondary : (isSelected ? Colors.black : CinemaTheme.textPrimary),
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    backgroundColor: isTaken ? CinemaTheme.cardAlt.withValues(alpha: 0.5) : CinemaTheme.bg,
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _hall,
                            decoration: const InputDecoration(
                              labelText: 'Studio',
                            ),
                            items: List.generate(5, (index) => 'Studio ${index + 1}')
                                .map((studio) => DropdownMenuItem(
                                      value: studio,
                                      child: Text(studio),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _hall = value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: () async {
                                    if (_selectedMovie == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Silakan pilih film'),
                                        ),
                                      );
                                      return;
                                    }
                                    try {
                                      await saveAdminSchedule(
                                        id: _editingScheduleId,
                                        movieId: _selectedMovie!.id,
                                        date: _scheduleDate,
                                        time: _scheduleTime,
                                        hall: _hall,
                                      );
                                      setState(() {
                                        _selectedMovie = null;
                                        _scheduleTime = '10:00:00';
                                        _hall = 'Studio 1';
                                        _editingScheduleId = null;
                                      });
                                      widget.onDataChanged();
                                      _refresh();
                                    } catch (error) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Gagal menyimpan jadwal: $error',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: CinemaTheme.accent,
                                    foregroundColor: Colors.black,
                                  ),
                                  child: Text(_editingScheduleId == null ? 'Simpan Jadwal' : 'Perbarui Jadwal'),
                                ),
                              ),
                              if (_editingScheduleId != null) ...[
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedMovie = null;
                                      // _date.clear();
                                      _scheduleTime = '10:00:00';
                                      _hall = 'Studio 1';
                                      _editingScheduleId = null;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: CinemaTheme.textPrimary,
                                  ),
                                  child: const Text('Batal'),
                                ),
                              ],
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: FutureBuilder<List<ScheduleSlot>>(
                    future: _schedulesFuture,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: CinemaTheme.accent,
                          ),
                        );
                      }
                      if (snap.hasError) {
                        return const Center(
                          child: Text(
                            'Gagal memuat jadwal',
                            style: TextStyle(color: CinemaTheme.textSecondary),
                          ),
                        );
                      }
                      var schedules = snap.data ?? const <ScheduleSlot>[];
                      
                      // Sort schedules chronologically
                      schedules = List.from(schedules)..sort((a, b) {
                        int dateCmp = a.date.compareTo(b.date);
                        if (dateCmp != 0) return dateCmp;
                        int hallCmp = a.hall.compareTo(b.hall);
                        if (hallCmp != 0) return hallCmp;
                        return a.time.compareTo(b.time);
                      });

                      if (schedules.isEmpty) {
                        return const Center(
                          child: Text(
                            'Tidak ada jadwal tayang',
                            style: TextStyle(color: CinemaTheme.textSecondary),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: schedules.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final schedule = schedules[index];
                          return cinemaCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        schedule.type.isNotEmpty ? schedule.type : 'Schedule #${schedule.id}',
                                        style: const TextStyle(
                                          color: CinemaTheme.textPrimary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${schedule.date} • ${schedule.time} - ${schedule.endTime ?? '??:??'}',
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
                                  onPressed: () {
                                    // Let's populate the edit form
                                    _moviesFuture.then((movies) {
                                      setState(() {
                                        _editingScheduleId = schedule.id;
                                        _scheduleDate = schedule.date;
                                        _scheduleTime = schedule.time;
                                        _hall = schedule.hall;
                                        _selectedMovie = movies.cast<MovieData?>().firstWhere(
                                              (m) => m?.title == schedule.type, 
                                              orElse: () => null,
                                            );
                                      });
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.edit_rounded,
                                    color: CinemaTheme.accent,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _deleteSchedule(schedule.id),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminAdsNotifHub extends StatelessWidget {
  final VoidCallback onAddAds;

  const _AdminAdsNotifHub({required this.onAddAds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cinemaBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cinemaSectionTitle('Ads', subtitle: 'Manage banners'),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: onAddAds,
                  child: cinemaCard(
                    child: const Column(
                      children: [
                        Icon(
                          Icons.campaign_rounded,
                          color: CinemaTheme.accent,
                          size: 34,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Ads',
                          style: TextStyle(
                            color: CinemaTheme.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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

Widget _profileAction(
  IconData icon,
  String title,
  String subtitle,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CinemaTheme.cardAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CinemaTheme.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: CinemaTheme.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: CinemaTheme.textPrimary,
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
  );
}

class _AdminProfileHub extends StatelessWidget {
  final String userName;
  final String email;
  final VoidCallback onLogout;

  const _AdminProfileHub({
    required this.userName,
    required this.email,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cinemaBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                decoration: BoxDecoration(
                  color: CinemaTheme.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: CinemaTheme.border),
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
                      style: const TextStyle(
                        color: CinemaTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      style: const TextStyle(
                        color: CinemaTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _roleChip('Admin'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              cinemaCard(
                child: Column(
                  children: [
                    _profileAction(
                      Icons.lock_reset_rounded,
                      'Change Password',
                      'Update auth password',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangePasswordPage(email: email),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onLogout,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _MoviePopup extends StatefulWidget {
  final Future<void> Function(TextEditingController target) onPickImage;
  final MovieData? movie;
  const _MoviePopup({required this.onPickImage, this.movie});
  @override
  State<_MoviePopup> createState() => _MoviePopupState();
}

class _MoviePopupState extends State<_MoviePopup> {
  final _title = TextEditingController();
  final _code = TextEditingController();
  final _genre = TextEditingController();
  final _duration = TextEditingController();
  final _synopsis = TextEditingController();
  final _price = TextEditingController();
  final _poster = TextEditingController();
  String _status = 'Now Showing';

  bool _enableAutoSchedule = true;
  String _startDate = DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0];
  String _endDate = DateTime.now().add(const Duration(days: 7)).toString().split(' ')[0];
  String _scheduleHall = 'Studio 1';
  final Set<String> _selectedTimes = {'10:00:00', '13:00:00', '16:00:00', '19:00:00', '22:00:00'};
  final List<String> _timeOptions = ['10:00:00', '13:00:00', '16:00:00', '19:00:00', '22:00:00'];

  Future<void> _pickDate(bool isStart) async {
    final initial = DateTime.tryParse(isStart ? _startDate : _endDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 10)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        final dateStr = picked.toString().split(' ')[0];
        if (isStart) _startDate = dateStr;
        else _endDate = dateStr;
        _schedulesFuture = fetchAdminSchedules();
      });
    }
  }

  late Future<List<ScheduleSlot>> _schedulesFuture;

  @override
  void initState() {
    super.initState();
    _schedulesFuture = fetchAdminSchedules();
    if (widget.movie != null) {
      _title.text = widget.movie!.title;
      _code.text = widget.movie!.code ?? '';
      _genre.text = widget.movie!.genre;
      _duration.text = widget.movie!.duration.toString();
      _synopsis.text = widget.movie!.synopsis;
      _price.text = widget.movie!.price.toInt().toString();
      _poster.text = widget.movie!.imgUrl;
      _status = widget.movie!.status.isNotEmpty ? widget.movie!.status : 'Now Showing';
    }
  }

  double _parseTicketPrice() {
    final normalized = _price.text.replaceAll(RegExp(r'[.,\s]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  @override
  void dispose() {
    _title.dispose();
    _code.dispose();
    _genre.dispose();
    _duration.dispose();
    _synopsis.dispose();
    _price.dispose();
    _poster.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: CinemaTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.movie == null ? 'Tambah Film' : 'Edit Film',
                    style: const TextStyle(
                      color: CinemaTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            cinemaCard(
              child: Column(
                children: [
                  TextField(
                    controller: _title,
                    decoration: const InputDecoration(
                      labelText: 'Judul Film',
                      hintText: 'Contoh: Avengers: Endgame',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _code,
                    decoration: const InputDecoration(
                      labelText: 'Kode Film',
                      hintText: 'Contoh: AVG001',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _genre,
                    decoration: const InputDecoration(
                      labelText: 'Genre',
                      hintText: 'Contoh: Action / Sci-Fi',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _duration,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Durasi (menit)',
                      hintText: 'Contoh: 120',
                      helperText: 'Isi angka menit saja',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _synopsis,
                    decoration: const InputDecoration(
                      labelText: 'Sinopsis',
                      hintText: 'Ringkasan pendek film',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga Tiket',
                      hintText: 'Contoh: 50000',
                      helperText: 'Harga disimpan sebagai angka bulat',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await widget.onPickImage(_poster);
                        if (mounted) setState(() {});
                      },
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Impor poster dari laptop'),
                    ),
                  ),
                  if (_poster.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _poster.text,
                        height: 180,
                        width: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180,
                          width: 120,
                          alignment: Alignment.center,
                          color: CinemaTheme.cardAlt,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: CinemaTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    items: const [
                      DropdownMenuItem(
                        value: 'Now Showing',
                        child: Text('Sedang Tayang'),
                      ),
                      DropdownMenuItem(
                        value: 'Coming Soon',
                        child: Text('Akan Datang'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _status = value ?? 'Now Showing'),
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                  const SizedBox(height: 16),
                  if (widget.movie == null) ...[
                    const Divider(color: CinemaTheme.border),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _enableAutoSchedule,
                          onChanged: (val) => setState(() => _enableAutoSchedule = val ?? false),
                          activeColor: CinemaTheme.accent,
                          checkColor: Colors.black,
                        ),
                        const Expanded(
                          child: Text(
                            'Buat Jadwal Otomatis (Opsi 1)',
                            style: TextStyle(color: CinemaTheme.textPrimary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    if (_enableAutoSchedule) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(true),
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Tanggal Mulai'),
                                child: Text(_startDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(false),
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Tanggal Selesai'),
                                child: Text(_endDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _scheduleHall,
                        items: List.generate(5, (i) => 'Studio ${i + 1}')
                            .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                            .toList(),
                        onChanged: (val) => setState(() {
                          _scheduleHall = val ?? 'Studio 1';
                          _schedulesFuture = fetchAdminSchedules();
                        }),
                        decoration: const InputDecoration(labelText: 'Pilih Studio'),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Pilih Jam Tayang:',
                        style: TextStyle(color: CinemaTheme.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<List<ScheduleSlot>>(
                        future: _schedulesFuture,
                        builder: (context, snap) {
                          final schedules = snap.data ?? [];
                          
                          // Cari jam yang sudah diambil di rentang tanggal dan studio ini
                          final takenTimes = <String>{};
                          try {
                            final start = DateTime.parse(_startDate);
                            final end = DateTime.parse(_endDate);
                            
                            for (var s in schedules) {
                              if (s.hall != _scheduleHall) continue;
                              
                              final sDate = DateTime.tryParse(s.date);
                              if (sDate != null) {
                                // Jika tanggalnya ada dalam rentang [start, end]
                                if (!sDate.isBefore(start) && !sDate.isAfter(end)) {
                                  final timePrefix = s.time.length >= 5 ? s.time.substring(0, 5) : s.time;
                                  takenTimes.add(timePrefix);
                                }
                              }
                            }
                          } catch (_) {}

                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _timeOptions.map((t) {
                              final tPrefix = t.length >= 5 ? t.substring(0, 5) : t;
                              final isTaken = takenTimes.contains(tPrefix);
                              final isSelected = _selectedTimes.contains(t);
                              
                              // Automatically remove from selected if taken
                              if (isTaken && isSelected) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) {
                                    setState(() => _selectedTimes.remove(t));
                                  }
                                });
                              }

                              return FilterChip(
                                label: Text(t.substring(0, 5)),
                                selected: isSelected,
                                onSelected: isTaken ? null : (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedTimes.add(t);
                                    } else {
                                      _selectedTimes.remove(t);
                                    }
                                  });
                                },
                                selectedColor: CinemaTheme.accent,
                                checkmarkColor: Colors.black,
                                labelStyle: TextStyle(
                                  color: isTaken ? CinemaTheme.textSecondary : (isSelected ? Colors.black : CinemaTheme.textPrimary),
                                ),
                                backgroundColor: isTaken ? CinemaTheme.cardAlt.withValues(alpha: 0.5) : CinemaTheme.bg,
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (_poster.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gambar poster wajib diisi'),
                            ),
                          );
                          return;
                        }
                        try {
                          // Validasi conflict sebelum simpan jika jadwal otomatis aktif
                          if (widget.movie == null && _enableAutoSchedule && _selectedTimes.isNotEmpty) {
                            final latestSchedules = await fetchAdminSchedules();
                            final start = DateTime.tryParse(_startDate) ?? DateTime.now();
                            final end = DateTime.tryParse(_endDate) ?? start;
                            final conflicts = <String>[];

                            for (final s in latestSchedules) {
                              if (s.hall != _scheduleHall) continue;
                              final sDate = DateTime.tryParse(s.date);
                              if (sDate != null && !sDate.isBefore(start) && !sDate.isAfter(end)) {
                                final sTimePrefix = s.time.length >= 5 ? s.time.substring(0, 5) : s.time;
                                if (_selectedTimes.any((t) => t.startsWith(sTimePrefix))) {
                                  conflicts.add('${s.date} jam $sTimePrefix');
                                }
                              }
                            }

                            if (conflicts.isNotEmpty) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bioskop dan waktu tidak bisa ditambahkan, jadwal sudah terisi!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                          }

                          final savedMovie = await saveAdminMovie(
                            id: widget.movie?.id,
                            title: _title.text,
                            code: _code.text,
                            genre: _genre.text,
                            duration: int.tryParse(_duration.text) ?? 0,
                            synopsis: _synopsis.text,
                            price: _parseTicketPrice(),
                            imageUrl: _poster.text,
                            status: _status,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Film berhasil disimpan')),
                            );
                            Navigator.pop(context, true);
                          }

                          // Jalankan pembuatan jadwal di background setelah popup ditutup
                          if (widget.movie == null && _enableAutoSchedule && _selectedTimes.isNotEmpty) {
                            final movieId = savedMovie.id;
                            final hall = _scheduleHall;
                            final times = List<String>.from(_selectedTimes);
                            final startDate = DateTime.tryParse(_startDate) ?? DateTime.now();
                            final endDate = DateTime.tryParse(_endDate) ?? startDate;

                            Future(() async {
                              for (DateTime d = startDate; d.isBefore(endDate.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
                                final dateStr = d.toString().split(' ')[0];
                                for (final time in times) {
                                  try {
                                    await saveAdminSchedule(
                                      movieId: movieId,
                                      date: dateStr,
                                      time: time,
                                      hall: hall,
                                    );
                                  } catch (e) {
                                    debugPrint('Gagal buat jadwal otomatis: $e');
                                  }
                                }
                              }
                            });
                          }
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal menyimpan film: $error'),
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: CinemaTheme.accent,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Simpan Film'),
                    ),
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

class _AdsPopup extends StatefulWidget {
  final Future<void> Function(TextEditingController target) onPickImage;
  const _AdsPopup({required this.onPickImage});
  @override
  State<_AdsPopup> createState() => _AdsPopupState();
}

class _AdsPopupState extends State<_AdsPopup> {
  final _title = TextEditingController();
  final _image = TextEditingController();
  final _link = TextEditingController();
  final _sort = TextEditingController(text: '0');

  @override
  void dispose() {
    _title.dispose();
    _image.dispose();
    _link.dispose();
    _sort.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: CinemaTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Add Ad',
                    style: TextStyle(
                      color: CinemaTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            cinemaCard(
              child: Column(
                children: [
                  TextField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await widget.onPickImage(_image);
                        if (mounted) setState(() {});
                      },
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Import banner from laptop'),
                    ),
                  ),
                  if (_image.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _image.text,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 120,
                          alignment: Alignment.center,
                          color: CinemaTheme.cardAlt,
                          child: const Text(
                            'Preview unavailable',
                            style: TextStyle(color: CinemaTheme.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: _link,
                    decoration: const InputDecoration(labelText: 'Link URL'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _sort,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Sort order'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (_image.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Banner image is required'),
                            ),
                          );
                          return;
                        }
                        try {
                          await saveAdvertisement(
                            title: _title.text,
                            imageUrl: _image.text,
                            linkUrl: _link.text,
                            active: true,
                            sortOrder: int.tryParse(_sort.text) ?? 0,
                          );
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Save ad failed: $error')),
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
          ],
        ),
      ),
    );
  }
}

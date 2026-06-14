import 'package:file_picker/file_picker.dart';
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

  Future<void> _pickAndUpload(TextEditingController target) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: false);
    if (result == null || result.files.single.path == null) return;

    try {
      final url = await uploadImageFile(result.files.single.path!);
      if (!mounted) return;
      setState(() => target.text = url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $error')),
      );
    }
  }

  Future<void> _showPopup(Widget child) async {
    await showDialog<void>(
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
      _AdminMovieHub(refreshToken: _adminDataVersion, onAddMovie: () async => _showPopup(_MoviePopup(onPickImage: _pickAndUpload)), onDataChanged: _refreshAdminData),
      _AdminScheduleHub(
        refreshToken: _adminDataVersion,
        onDataChanged: _refreshAdminData,
      ),
      _AdminAdsNotifHub(
        onAddAds: () => _showPopup(_AdsPopup(onPickImage: _pickAndUpload)),
        onAddNotif: () => _showPopup(const _NotifPopup()),
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
          labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.movie_creation_outlined), selectedIcon: Icon(Icons.movie_creation_rounded), label: 'Movie'),
            NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Schedule'),
            NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign_rounded), label: 'Ads'),
            NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
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
  const _AdminMovieHub({required this.refreshToken, required this.onAddMovie, required this.onDataChanged});

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
                cinemaSectionTitle('Movies', subtitle: 'Manage film catalog'),
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
                          child: const Icon(Icons.add_rounded, color: CinemaTheme.accent),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add Movie', style: TextStyle(color: CinemaTheme.textPrimary, fontWeight: FontWeight.w800)),
                              SizedBox(height: 4),
                              Text('Open popup to create a new movie', style: TextStyle(color: CinemaTheme.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: CinemaTheme.textSecondary),
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
                        return const Center(child: CircularProgressIndicator(color: CinemaTheme.accent));
                      }
                      if (snap.hasError) {
                        return Center(
                          child: Text(
                            'Failed to load movies',
                            style: const TextStyle(color: CinemaTheme.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      final movies = snap.data ?? const <MovieData>[];
                      final nowShowing = movies.where((movie) => movie.status.toLowerCase() == 'now showing').toList();
                      final comingSoon = movies.where((movie) => movie.status.toLowerCase() == 'coming soon').toList();

                      if (movies.isEmpty) {
                        return const Center(
                          child: Text('No movies found', style: TextStyle(color: CinemaTheme.textSecondary)),
                        );
                      }

                      return ListView(
                        children: [
                          cinemaCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Now Showing', style: TextStyle(color: CinemaTheme.textPrimary, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 245,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: nowShowing.isEmpty ? movies.length : nowShowing.length,
                                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      final movie = nowShowing.isEmpty ? movies[index] : nowShowing[index];
                                      return _AdminMovieCard(
                                        movie: movie,
                                        onDelete: () async {
                                          try {
                                            await deleteAdminMovie(movie.id);
                                            widget.onDataChanged();
                                            _refresh();
                                          } catch (error) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Delete movie failed: $error')),
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
                                const Text('Coming Soon', style: TextStyle(color: CinemaTheme.textPrimary, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 320,
                                  child: ListView.separated(
                                    itemCount: comingSoon.isEmpty ? 0 : comingSoon.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) => _AdminMovieListTile(
                                      movie: comingSoon[index],
                                      onDelete: () async {
                                        try {
                                          await deleteAdminMovie(comingSoon[index].id);
                                          widget.onDataChanged();
                                          _refresh();
                                        } catch (error) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Delete movie failed: $error')),
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

  const _AdminMovieCard({required this.movie, required this.onDelete});

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
                child: const Icon(Icons.image_not_supported_rounded, color: CinemaTheme.textSecondary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: CinemaTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 4),
                Text(movie.genre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: CinemaTheme.textSecondary, fontSize: 11)),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, color: CinemaTheme.danger, size: 18),
                    constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                    padding: EdgeInsets.zero,
                  ),
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

  const _AdminMovieListTile({required this.movie, required this.onDelete});

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
                child: const Icon(Icons.image_not_supported_rounded, color: CinemaTheme.textSecondary, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: CinemaTheme.textPrimary, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(movie.genre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: CinemaTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(movie.status, style: const TextStyle(color: CinemaTheme.accent, fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, color: CinemaTheme.danger),
          ),
        ],
      ),
    );
  }
}

class _AdminScheduleHub extends StatefulWidget {
  final int refreshToken;
  final VoidCallback onDataChanged;
  const _AdminScheduleHub({required this.refreshToken, required this.onDataChanged});

  @override
  State<_AdminScheduleHub> createState() => _AdminScheduleHubState();
}

class _AdminScheduleHubState extends State<_AdminScheduleHub> {
  late Future<List<MovieData>> _moviesFuture;
  late Future<List<ScheduleSlot>> _schedulesFuture;

  MovieData? _selectedMovie;
  final _date = TextEditingController();
  final _time = TextEditingController();
  final _hall = TextEditingController();

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
    _date.dispose();
    _time.dispose();
    _hall.dispose();
    super.dispose();
  }

  Future<void> _deleteSchedule(int id) async {
    try {
      await deleteAdminSchedule(id);
      widget.onDataChanged();
      _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete schedule failed: $error')),
      );
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
                cinemaSectionTitle('Schedule', subtitle: 'Assign movies to halls and time slots'),
                const SizedBox(height: 16),
                cinemaCard(
                  child: FutureBuilder<List<MovieData>>(
                    future: _moviesFuture,
                    builder: (context, snap) {
                      final movies = snap.data ?? const <MovieData>[];
                      return Column(
                        children: [
                          DropdownButtonFormField<MovieData>(
                            key: ValueKey(widget.refreshToken),
                            initialValue: _selectedMovie,
                            decoration: const InputDecoration(labelText: 'Select movie'),
                            items: movies
                                .map((movie) => DropdownMenuItem<MovieData>(
                                      value: movie,
                                      child: Text(movie.title),
                                    ))
                                .toList(),
                            onChanged: (movie) => setState(() => _selectedMovie = movie),
                          ),
                          const SizedBox(height: 12),
                          TextField(controller: _date, decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)')),
                          const SizedBox(height: 12),
                          TextField(controller: _time, decoration: const InputDecoration(labelText: 'Time (HH:MM)')),
                          const SizedBox(height: 12),
                          TextField(controller: _hall, decoration: const InputDecoration(labelText: 'Hall / Studio')),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () async {
                                if (_selectedMovie == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please select a movie')),
                                  );
                                  return;
                                }
                                try {
                                  await saveAdminSchedule(
                                    movieId: _selectedMovie!.id,
                                    date: _date.text,
                                    time: _time.text,
                                    hall: _hall.text,
                                  );
                                  _selectedMovie = null;
                                  _date.clear();
                                  _time.clear();
                                  _hall.clear();
                                  widget.onDataChanged();
                                  _refresh();
                                } catch (error) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Save schedule failed: $error')),
                                  );
                                }
                              },
                              style: FilledButton.styleFrom(backgroundColor: CinemaTheme.accent, foregroundColor: Colors.black),
                              child: const Text('Save Schedule'),
                            ),
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
                        return const Center(child: CircularProgressIndicator(color: CinemaTheme.accent));
                      }
                      if (snap.hasError) {
                        return const Center(child: Text('Failed to load schedules', style: TextStyle(color: CinemaTheme.textSecondary)));
                      }
                      final schedules = snap.data ?? const <ScheduleSlot>[];
                      if (schedules.isEmpty) {
                        return const Center(child: Text('No schedules found', style: TextStyle(color: CinemaTheme.textSecondary)));
                      }
                      return ListView.separated(
                        itemCount: schedules.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final schedule = schedules[index];
                          return cinemaCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Schedule #${schedule.id}', style: const TextStyle(color: CinemaTheme.textPrimary, fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 4),
                                      Text('${schedule.date} • ${schedule.time}', style: const TextStyle(color: CinemaTheme.textSecondary)),
                                      const SizedBox(height: 4),
                                      Text(schedule.hall, style: const TextStyle(color: CinemaTheme.accent, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _deleteSchedule(schedule.id),
                                  icon: const Icon(Icons.delete_outline_rounded, color: CinemaTheme.danger),
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
  final VoidCallback onAddNotif;

  const _AdminAdsNotifHub({required this.onAddAds, required this.onAddNotif});

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
                cinemaSectionTitle('Ads & Notifications', subtitle: 'Manage banners and announcements'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onAddAds,
                        child: cinemaCard(
                          child: Column(
                            children: [
                              const Icon(Icons.campaign_rounded, color: CinemaTheme.accent, size: 34),
                              const SizedBox(height: 10),
                              const Text('Ads', style: TextStyle(color: CinemaTheme.textPrimary, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: onAddNotif,
                        child: cinemaCard(
                          child: Column(
                            children: [
                              const Icon(Icons.notifications_active_rounded, color: CinemaTheme.accent, size: 34),
                              const SizedBox(height: 10),
                              const Text('Notifications', style: TextStyle(color: CinemaTheme.textPrimary, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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

  Widget _profileAction(IconData icon, String title, String subtitle, VoidCallback onTap) {
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
                  Text(title, style: const TextStyle(color: CinemaTheme.textPrimary, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: CinemaTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: CinemaTheme.textSecondary),
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
                        gradient: LinearGradient(colors: [CinemaTheme.accent, CinemaTheme.purple]),
                      ),
                      child: const Icon(Icons.person_rounded, color: Colors.black, size: 42),
                    ),
                    const SizedBox(height: 14),
                    Text(userName, style: const TextStyle(color: CinemaTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Text(email, style: const TextStyle(color: CinemaTheme.textSecondary, fontSize: 12)),
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
                        label: const Text('Logout'),
                        style: FilledButton.styleFrom(backgroundColor: CinemaTheme.danger, foregroundColor: Colors.white),
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
  const _MoviePopup({required this.onPickImage});
  @override State<_MoviePopup> createState() => _MoviePopupState();
}

class _MoviePopupState extends State<_MoviePopup> {
  final _title = TextEditingController();
  final _genre = TextEditingController();
  final _duration = TextEditingController();
  final _synopsis = TextEditingController();
  final _price = TextEditingController();
  final _poster = TextEditingController();
  String _status = 'Now Showing';

  @override
  void dispose() {
    _title.dispose();
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
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                const Expanded(child: Text('Add Movie', style: TextStyle(color: CinemaTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w800))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            cinemaCard(
              child: Column(
                children: [
                  TextField(controller: _title, decoration: const InputDecoration(labelText: 'Movie title')),
                  const SizedBox(height: 12),
                  TextField(controller: _genre, decoration: const InputDecoration(labelText: 'Genre')),
                  const SizedBox(height: 12),
                  TextField(controller: _duration, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration minutes')),
                  const SizedBox(height: 12),
                  TextField(controller: _synopsis, decoration: const InputDecoration(labelText: 'Synopsis'), maxLines: 3),
                  const SizedBox(height: 12),
                  TextField(controller: _price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ticket price')),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => widget.onPickImage(_poster),
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Import poster from laptop'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    items: const [
                      DropdownMenuItem(value: 'Now Showing', child: Text('Now Showing')),
                      DropdownMenuItem(value: 'Coming Soon', child: Text('Coming Soon')),
                    ],
                    onChanged: (value) => setState(() => _status = value ?? 'Now Showing'),
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (_poster.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Poster image is required')),
                          );
                          return;
                        }
                        try {
                          await saveAdminMovie(
                            title: _title.text,
                            genre: _genre.text,
                            duration: int.tryParse(_duration.text) ?? 0,
                            synopsis: _synopsis.text,
                            price: double.tryParse(_price.text) ?? 0,
                            imageUrl: _poster.text,
                            status: _status,
                          );
                          if (context.mounted) Navigator.pop(context);
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Save movie failed: $error')),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(backgroundColor: CinemaTheme.accent, foregroundColor: Colors.black),
                      child: const Text('Save Movie'),
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
  @override State<_AdsPopup> createState() => _AdsPopupState();
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
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                const Expanded(child: Text('Add Ad', style: TextStyle(color: CinemaTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w800))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            cinemaCard(
              child: Column(
                children: [
                  TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => widget.onPickImage(_image),
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Import banner from laptop'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: _link, decoration: const InputDecoration(labelText: 'Link URL')),
                  const SizedBox(height: 12),
                  TextField(controller: _sort, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sort order')),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (_image.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Banner image is required')),
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
                      style: FilledButton.styleFrom(backgroundColor: CinemaTheme.accent, foregroundColor: Colors.black),
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

class _NotifPopup extends StatefulWidget {
  const _NotifPopup();
  @override State<_NotifPopup> createState() => _NotifPopupState();
}

class _NotifPopupState extends State<_NotifPopup> {
  final _title = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
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
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                const Expanded(child: Text('Add Notification', style: TextStyle(color: CinemaTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w800))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            cinemaCard(
              child: Column(
                children: [
                  TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 12),
                  TextField(controller: _message, decoration: const InputDecoration(labelText: 'Message'), maxLines: 4),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        try {
                          await createNotification(
                            title: _title.text,
                            message: _message.text,
                            adminOnly: false,
                          );
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Send notification failed: $error')),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(backgroundColor: CinemaTheme.accent, foregroundColor: Colors.black),
                      child: const Text('Send Notification'),
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



















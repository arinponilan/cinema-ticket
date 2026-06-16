import re

file_path = '/Users/irziarinta/Downloads/cinema-ticket/frontend/lib/src/pages/admin_shell_page.dart'

with open(file_path, 'r') as f:
    content = f.read()

# Replace _AdminScheduleHubState
replacement = """class _AdminScheduleHubState extends State<_AdminScheduleHub> {
  late Future<List<MovieData>> _moviesFuture;
  late Future<List<ScheduleSlot>> _schedulesFuture;

  MovieData? _selectedMovie;
  String _scheduleDate = DateTime.now().toString().split(' ')[0];
  String _scheduleTime = '16:00:00';
  final _hall = TextEditingController(text: 'Studio 1');
  
  final List<String> _timeOptions = ['10:00:00', '13:00:00', '16:00:00', '19:00:00', '22:00:00'];

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete schedule failed: $error')));
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
                  'Jadwal Film',
                  subtitle: 'Atur jadwal tayang film di setiap studio',
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      cinemaCard(
                        child: FutureBuilder<List<MovieData>>(
                          future: _moviesFuture,
                          builder: (context, snap) {
                            final movies = snap.data ?? const <MovieData>[];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<MovieData>(
                                  isExpanded: true,
                                  key: ValueKey(widget.refreshToken),
                                  value: _selectedMovie,
                                  decoration: const InputDecoration(labelText: 'Pilih Film'),
                                  items: movies.map((movie) => DropdownMenuItem<MovieData>(
                                    value: movie,
                                    child: Text(movie.title),
                                  )).toList(),
                                  onChanged: (movie) => setState(() => _selectedMovie = movie),
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.tryParse(_scheduleDate) ?? DateTime.now(),
                                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                    );
                                    if (date != null) {
                                      setState(() => _scheduleDate = date.toString().split(' ')[0]);
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: const InputDecoration(labelText: 'Pilih Tanggal', border: InputBorder.none),
                                    child: Text(_scheduleDate, style: const TextStyle(fontWeight: FontWeight.bold, color: CinemaTheme.textPrimary)),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: _hall.text,
                                  decoration: const InputDecoration(labelText: 'Pilih Studio'),
                                  items: List.generate(5, (index) => 'Studio ${index + 1}')
                                      .map((studio) => DropdownMenuItem(value: studio, child: Text(studio)))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _hall.text = val);
                                  },
                                ),
                                const SizedBox(height: 16),
                                const Text('Pilih Jam Tayang:', style: TextStyle(color: CinemaTheme.textSecondary, fontSize: 12)),
                                const SizedBox(height: 8),
                                FutureBuilder<List<ScheduleSlot>>(
                                  future: _schedulesFuture,
                                  builder: (context, scheduleSnap) {
                                    final schedules = scheduleSnap.data ?? [];
                                    final takenTimes = schedules
                                        .where((s) => s.date == _scheduleDate && s.hall == _hall.text)
                                        .map((s) => s.time)
                                        .toSet();
                                    
                                    return Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _timeOptions.map((t) {
                                        final isTaken = takenTimes.contains(t);
                                        return FilterChip(
                                          label: Text(t.substring(0, 5)),
                                          selected: _scheduleTime == t,
                                          onSelected: isTaken ? null : (selected) {
                                            if (selected) setState(() => _scheduleTime = t);
                                          },
                                          selectedColor: CinemaTheme.accent,
                                          checkmarkColor: Colors.black,
                                          labelStyle: TextStyle(color: isTaken ? CinemaTheme.textSecondary : (_scheduleTime == t ? Colors.black : CinemaTheme.textPrimary)),
                                          backgroundColor: isTaken ? CinemaTheme.cardAlt.withValues(alpha: 0.5) : CinemaTheme.bg,
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
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
                                          date: _scheduleDate,
                                          time: _scheduleTime,
                                          hall: _hall.text,
                                        );
                                        _selectedMovie = null;
                                        widget.onDataChanged();
                                        _refresh();
                                      } catch (error) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Save schedule failed: $error')),
                                        );
                                      }
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: CinemaTheme.accent,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text('Tambah Jadwal (Opsi 2)'),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<ScheduleSlot>>(
                        future: _schedulesFuture,
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: CinemaTheme.accent));
                          }
                          final schedules = snap.data ?? const <ScheduleSlot>[];
                          if (schedules.isEmpty) {
                            return const Center(child: Text('Tidak ada jadwal tayang', style: TextStyle(color: CinemaTheme.textSecondary)));
                          }
                          
                          // Sort schedules
                          final sortedSchedules = List<ScheduleSlot>.from(schedules)..sort((a, b) {
                            int dateCmp = a.date.compareTo(b.date);
                            if (dateCmp != 0) return dateCmp;
                            int hallCmp = a.hall.compareTo(b.hall);
                            if (hallCmp != 0) return hallCmp;
                            return a.time.compareTo(b.time);
                          });

                          return Column(
                            children: sortedSchedules.map((schedule) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: cinemaCard(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Jadwal #${schedule.id} - ${moviesMap[schedule.movieId] ?? "Loading..."}',
                                            style: const TextStyle(color: CinemaTheme.textPrimary, fontWeight: FontWeight.w800),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${schedule.date} • ${schedule.time}',
                                            style: const TextStyle(color: CinemaTheme.textSecondary),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            schedule.hall,
                                            style: const TextStyle(color: CinemaTheme.accent, fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _deleteSchedule(schedule.id),
                                      icon: const Icon(Icons.delete_outline_rounded, color: CinemaTheme.danger),
                                    ),
                                  ],
                                ),
                              ),
                            )).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}"""

pattern = r'class _AdminScheduleHubState extends State<_AdminScheduleHub> \{.*?\n\}\n(?=class _AdminAdsNotifHub|$)'
new_content = re.sub(pattern, replacement + '\n', content, flags=re.DOTALL)

with open(file_path, 'w') as f:
    f.write(new_content)

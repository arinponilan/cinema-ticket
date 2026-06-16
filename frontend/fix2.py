import re

file_path = '/Users/irziarinta/Downloads/cinema-ticket/frontend/lib/src/pages/admin_shell_page.dart'

with open(file_path, 'r') as f:
    content = f.read()

# Replace _AdminScheduleHubState
replacement1 = """class _AdminScheduleHubState extends State<_AdminScheduleHub> {
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

                          final movies = (snap.connectionState == ConnectionState.waiting) 
                              ? const <MovieData>[] 
                              : (_moviesFuture != null ? [] : []); // We need movies to map names.

                          return FutureBuilder<List<MovieData>>(
                            future: _moviesFuture,
                            builder: (context, movieSnap) {
                              final moviesList = movieSnap.data ?? [];
                              final moviesMap = {for (var m in moviesList) m.id: m.title};

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
                            }
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

# Replace _MoviePopupState
replacement2 = """class _MoviePopupState extends State<_MoviePopup> {
  final _title = TextEditingController();
  final _genre = TextEditingController();
  final _duration = TextEditingController();
  final _synopsis = TextEditingController();
  final _price = TextEditingController();
  final _poster = TextEditingController();
  String _status = 'Now Showing';
  bool _isSaving = false;

  bool _enableAutoSchedule = true;
  String _startDate = DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0];
  String _endDate = DateTime.now().add(const Duration(days: 7)).toString().split(' ')[0];
  String _scheduleHall = 'Studio 1';
  final List<String> _selectedTimes = ['16:00:00', '19:00:00', '22:00:00'];

  double _parseTicketPrice() {
    final normalized = _price.text.replaceAll(RegExp(r'[.,\\s]'), '');
    return double.tryParse(normalized) ?? 0;
  }

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
                    'Simpan Film',
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
                  TextField(
                    controller: _genre,
                    decoration: const InputDecoration(labelText: 'Genre'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _duration,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _synopsis,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Synopsis'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Ticket Price'),
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
                      label: const Text('Import poster from laptop'),
                    ),
                  ),
                  if (_poster.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _poster.text,
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
                  DropdownButtonFormField<String>(
                    value: _status,
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
                  const SizedBox(height: 24),
                  const Divider(color: CinemaTheme.cardAlt),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Buat Jadwal Otomatis (Opsi 1)', style: TextStyle(fontWeight: FontWeight.bold, color: CinemaTheme.textPrimary)),
                    value: _enableAutoSchedule,
                    onChanged: (val) => setState(() => _enableAutoSchedule = val == true),
                    activeColor: CinemaTheme.accent,
                    checkColor: Colors.black,
                  ),
                  if (_enableAutoSchedule) ...[
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.tryParse(_startDate) ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() => _startDate = date.toString().split(' ')[0]);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Tanggal Mulai', border: InputBorder.none),
                              child: Text(_startDate, style: const TextStyle(fontWeight: FontWeight.bold, color: CinemaTheme.textPrimary)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.tryParse(_endDate) ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() => _endDate = date.toString().split(' ')[0]);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Tanggal Selesai', border: InputBorder.none),
                              child: Text(_endDate, style: const TextStyle(fontWeight: FontWeight.bold, color: CinemaTheme.textPrimary)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _scheduleHall,
                      decoration: const InputDecoration(labelText: 'Pilih Studio'),
                      items: List.generate(5, (index) => 'Studio ${index + 1}')
                          .map((studio) => DropdownMenuItem(value: studio, child: Text(studio)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _scheduleHall = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Pilih Jam Tayang:', style: TextStyle(color: CinemaTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    FutureBuilder<List<ScheduleSlot>>(
                      future: fetchAdminSchedules(),
                      builder: (context, snap) {
                        final schedules = snap.data ?? [];
                        final takenTimes = schedules
                            .where((s) => s.date == _startDate && s.hall == _scheduleHall)
                            .map((s) => s.time)
                            .toSet();
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['10:00:00', '13:00:00', '16:00:00', '19:00:00', '22:00:00'].map((t) {
                            final isTaken = takenTimes.contains(t);
                            final isSelected = _selectedTimes.contains(t);
                            return FilterChip(
                              label: Text(t.substring(0, 5)),
                              selected: isSelected,
                              onSelected: isTaken ? null : (selected) {
                                setState(() {
                                  if (selected) _selectedTimes.add(t);
                                  else _selectedTimes.remove(t);
                                });
                              },
                              selectedColor: CinemaTheme.accent,
                              checkmarkColor: Colors.black,
                              labelStyle: TextStyle(color: isTaken ? CinemaTheme.textSecondary : (isSelected ? Colors.black : CinemaTheme.textPrimary)),
                              backgroundColor: isTaken ? CinemaTheme.cardAlt.withValues(alpha: 0.5) : CinemaTheme.bg,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSaving ? null : () async {
                        if (_poster.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Poster image is required')),
                          );
                          return;
                        }
                        setState(() => _isSaving = true);
                        try {
                          final savedMovie = await saveAdminMovie(
                            title: _title.text,
                            code: _title.text.replaceAll(' ', '_').toUpperCase(),
                            genre: _genre.text,
                            duration: int.tryParse(_duration.text) ?? 0,
                            synopsis: _synopsis.text,
                            price: _parseTicketPrice(),
                            imageUrl: _poster.text,
                            status: _status,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_enableAutoSchedule && _selectedTimes.isNotEmpty ? 'Film disimpan. Membuat jadwal di latar belakang...' : 'Film berhasil disimpan')),
                            );
                            Navigator.pop(context, true);
                          }

                          if (_enableAutoSchedule && _selectedTimes.isNotEmpty) {
                            DateTime start = DateTime.tryParse(_startDate) ?? DateTime.now();
                            DateTime end = DateTime.tryParse(_endDate) ?? start;
                            
                            Future(() async {
                              for (DateTime d = start; d.isBefore(end.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
                                final dateStr = d.toString().split(' ')[0];
                                for (final time in _selectedTimes) {
                                  try {
                                    await saveAdminSchedule(
                                      movieId: savedMovie.id,
                                      date: dateStr,
                                      time: time,
                                      hall: _scheduleHall,
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
                          setState(() => _isSaving = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Save movie failed: $error')),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: CinemaTheme.accent,
                        foregroundColor: Colors.black,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Text('Simpan Film'),
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
}"""

pattern1 = r'class _AdminScheduleHubState extends State<_AdminScheduleHub> \{.*?\n\}\n(?=class _AdminAdsNotifHub)'
new_content = re.sub(pattern1, lambda _: replacement1 + '\n', content, flags=re.DOTALL)

pattern2 = r'class _MoviePopupState extends State<_MoviePopup> \{.*?\n\}\n(?=class _AdsPopup)'
new_content = re.sub(pattern2, lambda _: replacement2 + '\n', new_content, flags=re.DOTALL)

with open(file_path, 'w') as f:
    f.write(new_content)

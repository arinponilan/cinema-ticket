import 'package:flutter/material.dart';

import '../models/cinema_models.dart';
import '../theme/tc.dart';

class SearchPage extends StatefulWidget {
  final int userId;
  final List<MovieData> movies;
  final void Function(MovieData) onBookMovie;

  const SearchPage({
    super.key,
    required this.userId,
    required this.movies,
    required this.onBookMovie,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _q = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final items = widget.movies.where((movie) {
      final query = _q.toLowerCase();
      final matchesQuery = movie.title.toLowerCase().contains(query) || movie.genre.toLowerCase().contains(query);
      final matchesFilter = _filter == 'All' || movie.status.toLowerCase().contains(_filter.toLowerCase());
      return matchesQuery && matchesFilter;
    }).toList();

    return Scaffold(
      body: cinemaBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cinemaSectionTitle('Jelajahi Film', subtitle: 'Cari film dari server'),
                const SizedBox(height: 14),
                TextField(
                  onChanged: (value) => setState(() => _q = value),
                  decoration: const InputDecoration(
                    hintText: 'Cari judul atau genre',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['All', 'Now Showing', 'Coming Soon'].map((label) {
                      final selected = _filter == label;
                      final String uiLabel = label == 'All' ? 'Semua' : (label == 'Now Showing' ? 'Sedang Tayang' : 'Akan Datang');
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(uiLabel),
                          selected: selected,
                          onSelected: (bool selected) => setState(() => _filter = label),
                          selectedColor: CinemaTheme.accent.withValues(alpha: 0.16),
                          labelStyle: TextStyle(
                            color: selected ? CinemaTheme.accent : CinemaTheme.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text('Tidak ada film', style: TextStyle(color: CinemaTheme.textSecondary)))
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) => _MovieTile(movie: items[index], onBook: widget.onBookMovie),
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

class _MovieTile extends StatelessWidget {
  final MovieData movie;
  final ValueChanged<MovieData> onBook;

  const _MovieTile({required this.movie, required this.onBook});

  @override
  Widget build(BuildContext context) {
    final isComing = movie.status.toLowerCase().contains('coming');
    return cinemaCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              movie.imgUrl,
              width: 78,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 78,
                height: 110,
                color: CinemaTheme.cardAlt,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: CinemaTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(movie.genre, style: const TextStyle(color: CinemaTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                Text(movie.synopsis, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: CinemaTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 10),
                Row(children: [_chip(movie.status, isComing ? CinemaTheme.purple : CinemaTheme.accent), const SizedBox(width: 8), _chip('${movie.duration}m', CinemaTheme.textSecondary)]),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: isComing 
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                          child: Text('Belum Rilis', style: TextStyle(color: CinemaTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      : FilledButton(
                          onPressed: () => onBook(movie),
                          style: FilledButton.styleFrom(backgroundColor: CinemaTheme.accent, foregroundColor: Colors.black),
                          child: const Text('Pesan Tiket'),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
      );
}

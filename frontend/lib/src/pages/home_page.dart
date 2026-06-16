import 'dart:async';

import 'package:flutter/material.dart';

import '../models/cinema_models.dart';
import '../theme/tc.dart';

class HomePage extends StatelessWidget {
  final int userId;
  final String userName;
  final String role;
  final List<MovieData> movies;
  final List<PromotionItem> promotions;
  final bool isLoadingMovies;
  final String? movieError;
  final VoidCallback onRetryMovies;
  final Function(MovieData) onBookNow;

  const HomePage({
    super.key,
    required this.userId,
    required this.userName,
    required this.role,
    required this.movies,
    required this.promotions,
    required this.isLoadingMovies,
    required this.movieError,
    required this.onRetryMovies,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    final nowShowing = movies
        .where((movie) => !movie.status.toLowerCase().contains('coming'))
        .toList();
    final comingSoon = movies
        .where((movie) => movie.status.toLowerCase().contains('coming'))
        .toList();

    return Scaffold(
      body: cinemaBackdrop(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => onRetryMovies(),
            color: CinemaTheme.accent,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [CinemaTheme.accent, CinemaTheme.purple],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: CinemaTheme.accent.withValues(
                                  alpha: 0.24,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_movies_rounded,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat datang, $userName',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: CinemaTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                role.toLowerCase() == 'admin'
                                    ? 'Akses studio admin'
                                    : 'Pengalaman bioskop premium',
                                style: const TextStyle(
                                  color: CinemaTheme.textSecondary,
                                  fontSize: 12,
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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: _PromotionBanner(promotions: promotions),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Sedang Tayang',
                            style: const TextStyle(
                              color: CinemaTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          '${nowShowing.length} film',
                          style: const TextStyle(
                            color: CinemaTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 370,
                    child: isLoadingMovies
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: CinemaTheme.accent,
                            ),
                          )
                        : movieError != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _emptyCard(
                              icon: Icons.wifi_off_rounded,
                              title: 'Gagal memuat film',
                              message: 'Periksa koneksi backend.',
                              actionLabel: 'Coba Lagi',
                              onAction: onRetryMovies,
                            ),
                          )
                        : nowShowing.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _emptyCard(
                              icon: Icons.movie_outlined,
                              title: 'Tidak ada film yang sedang tayang',
                              message:
                                  'Tunggu admin mempublikasikan jadwal.',
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                            scrollDirection: Axis.horizontal,
                            itemCount: nowShowing.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final movie = nowShowing[index];
                              return _NowShowingCard(
                                movie: movie,
                                onBookNow: onBookNow,
                              );
                            },
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Akan Datang',
                            style: const TextStyle(
                              color: CinemaTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          '${comingSoon.length} film',
                          style: const TextStyle(
                            color: CinemaTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: isLoadingMovies
                      ? const SliverToBoxAdapter(child: SizedBox.shrink())
                      : comingSoon.isEmpty
                      ? SliverToBoxAdapter(
                          child: _emptyCard(
                            icon: Icons.upcoming_rounded,
                            title: 'Tidak ada film yang akan datang',
                            message: 'Rilisan baru akan muncul di sini.',
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final movie = comingSoon[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ComingSoonCard(movie: movie),
                            );
                          }, childCount: comingSoon.length),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyCard({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return cinemaCard(
      child: Column(
        children: [
          Icon(icon, color: CinemaTheme.accent, size: 34),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CinemaTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: CinemaTheme.accent,
                foregroundColor: Colors.black,
              ),
              child: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }
}

class _PromotionBanner extends StatefulWidget {
  final List<PromotionItem> promotions;

  const _PromotionBanner({required this.promotions});

  @override
  State<_PromotionBanner> createState() => _PromotionBannerState();
}

class _PromotionBannerState extends State<_PromotionBanner> {
  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _PromotionBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.promotions.length != widget.promotions.length) {
      _restartTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.promotions.length <= 1) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || widget.promotions.isEmpty) return;
      final next = (_index + 1) % widget.promotions.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
      setState(() => _index = next);
    });
  }

  void _restartTimer() {
    _timer?.cancel();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promos = widget.promotions.take(5).toList();
    if (promos.isEmpty) {
      return cinemaCard(
        padding: const EdgeInsets.all(0),
        child: Container(
          height: 180,
          alignment: Alignment.center,
          child: const Text(
            'No promotions yet',
            style: TextStyle(color: CinemaTheme.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: promos.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, index) {
              final promo = promos[index];
              return Padding(
                padding: const EdgeInsets.only(right: 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        promo.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: CinemaTheme.cardAlt,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: CinemaTheme.textSecondary,
                            size: 40,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.08),
                              Colors.black.withValues(alpha: 0.68),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              promo.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 56,
                              height: 4,
                              decoration: BoxDecoration(
                                color: CinemaTheme.accent,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 14,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: CinemaTheme.accent.withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                '${_index + 1}/${promos.length}',
                style: const TextStyle(
                  color: CinemaTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NowShowingCard extends StatelessWidget {
  final MovieData movie;
  final ValueChanged<MovieData> onBookNow;

  const _NowShowingCard({required this.movie, required this.onBookNow});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onBookNow(movie),
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Image.network(
                  movie.imgUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: CinemaTheme.cardAlt,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: CinemaTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CinemaTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w900,
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => onBookNow(movie),
                style: FilledButton.styleFrom(
                  backgroundColor: CinemaTheme.accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Book',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  final MovieData movie;

  const _ComingSoonCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return cinemaCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 86,
              height: 120,
              child: Image.network(
                movie.imgUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: CinemaTheme.cardAlt,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: CinemaTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CinemaTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _badge('Coming Soon', CinemaTheme.purple),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  movie.genre,
                  style: const TextStyle(
                    color: CinemaTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.synopsis.isEmpty
                      ? 'Synopsis not available.'
                      : movie.synopsis,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CinemaTheme.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                _meta(Icons.schedule_rounded, '${movie.duration} min'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: color.withValues(alpha: 0.28)),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
    ),
  );

  Widget _meta(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: CinemaTheme.cardAlt,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: CinemaTheme.accent),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: CinemaTheme.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

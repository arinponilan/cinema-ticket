import 'package:flutter/material.dart';

import '../models/cinema_models.dart';
import '../services/cinema_api.dart';
import '../theme/tc.dart';
import 'booking_flow_pages.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'profile_pages.dart';
import 'ticket_page.dart';

class MainContainer extends StatefulWidget {
  final int userId;
  final String userName;
  final String email;
  final String role;

  const MainContainer({
    super.key,
    required this.userId,
    required this.userName,
    required this.email,
    required this.role,
  });

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _idx = 0;
  final _ticketKey = GlobalKey<TicketPageState>();
  List<MovieData> _movies = [];
  List<PromotionItem> _promotions = [];
  bool _isLoadingMovies = true;
  String? _movieError;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoadingMovies = true;
      _movieError = null;
    });

    try {
      final movies = await fetchMovies();
      final scheduleFlags = await Future.wait(
        movies.map((movie) async {
          try {
            final schedules = await fetchSchedulesForMovie(movie.id);
            return schedules.isNotEmpty;
          } catch (_) {
            return false;
          }
        }),
      );
      final visibleMovies = <MovieData>[];
      for (var i = 0; i < movies.length; i++) {
        if (scheduleFlags[i]) {
          visibleMovies.add(movies[i]);
        }
      }
      List<PromotionItem> promotions = const [];
      try {
        promotions = await fetchPromotions();
      } catch (_) {
        promotions = const [];
      }
      if (!mounted) return;
      setState(() {
        _movies = visibleMovies;
        _promotions = promotions.take(5).toList();
        _isLoadingMovies = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _movieError = e.toString();
        _isLoadingMovies = false;
      });
    }
  }
  void _goToTicket() {
    setState(() => _idx = 2);
    _ticketKey.currentState?.refresh();
  }

  void _openBooking(MovieData movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleSelectionPage(
          movie: movie,
          onSelectSchedule: (slot) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SeatSelectionPage(
                userId: widget.userId,
                movie: movie,
                schedule: slot,
                onConfirm: _goToTicket,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        userId: widget.userId,
        userName: widget.userName,
        role: widget.role,
        movies: _movies,
        promotions: _promotions,
        isLoadingMovies: _isLoadingMovies,
        movieError: _movieError,
        onRetryMovies: _loadMovies,
        onBookNow: _openBooking,
        onOpenNotifications: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationsPage(
              userId: widget.userId,
              role: widget.role,
            ),
          ),
        ),
      ),
      SearchPage(
        userId: widget.userId,
        movies: _movies,
        onBookMovie: _openBooking,
      ),
      TicketPage(userId: widget.userId, key: _ticketKey),
      ProfilePage(
        userId: widget.userId,
        userName: widget.userName,
        email: widget.email,
        role: widget.role,
        onOpenNotifications: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationsPage(
              userId: widget.userId,
              role: widget.role,
            ),
          ),
        ),
        onOpenHistory: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionHistoryPage(userId: widget.userId),
          ),
        ),
        onOpenChangePassword: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangePasswordPage(email: widget.email),
          ),
        ),
        onOpenAdmin: widget.role.toLowerCase() == 'admin'
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminPanelPage(userId: widget.userId),
                  ),
                )
            : null,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _idx, children: pages),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: CinemaTheme.panel,
          indicatorColor: CinemaTheme.accent.withValues(alpha: 0.16),
          labelTextStyle: WidgetStatePropertyAll(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _idx,
          onDestinationSelected: (i) => setState(() {
            _idx = i;
            if (i == 2) {
              _ticketKey.currentState?.refresh();
            }
          }),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_rounded),
              selectedIcon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.confirmation_number_outlined),
              selectedIcon: Icon(Icons.confirmation_number),
              label: 'Tickets',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}




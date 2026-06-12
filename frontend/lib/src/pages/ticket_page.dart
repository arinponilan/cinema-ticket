import 'package:flutter/material.dart';

import 'package:cinema_mobile/src/models/cinema_models.dart';
import 'package:cinema_mobile/src/services/cinema_api.dart';
import 'package:cinema_mobile/src/theme/tc.dart';

class TicketPage extends StatefulWidget {
  final int userId;
  const TicketPage({super.key, required this.userId});

  @override
  State<TicketPage> createState() => TicketPageState();
}

class TicketPageState extends State<TicketPage> with AutomaticKeepAliveClientMixin {
  late Future<List<BookingHistoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchBookingHistory(widget.userId);
  }

  void refresh() {
    setState(() {
      _future = fetchBookingHistory(widget.userId);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: cinemaBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tickets',
                        style: TextStyle(
                          color: CinemaTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: refresh,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<BookingHistoryItem>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: CinemaTheme.accent),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load tickets',
                          style: const TextStyle(color: CinemaTheme.textSecondary),
                        ),
                      );
                    }
                    final items = snapshot.data ?? const <BookingHistoryItem>[];
                    if (items.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.confirmation_number_outlined, color: CinemaTheme.textSecondary, size: 64),
                            SizedBox(height: 16),
                            Text('No Tickets Yet', style: TextStyle(color: CinemaTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                            SizedBox(height: 6),
                            Text('Book a movie to get your tickets here.', style: TextStyle(color: CinemaTheme.textSecondary, fontSize: 13)),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final ticket = items[index];
                        return cinemaCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(ticket.movieTitle, style: const TextStyle(color: CinemaTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
                                        const SizedBox(height: 4),
                                        Text('${ticket.bookingDate} • ${ticket.showTime}', style: const TextStyle(color: CinemaTheme.textSecondary, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: CinemaTheme.accent.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(ticket.bookingCode, style: const TextStyle(color: CinemaTheme.accent, fontSize: 10, fontWeight: FontWeight.w800)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: ticket.seatNumbers.map((seat) => _chip(seat)).toList(),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total', style: const TextStyle(color: CinemaTheme.textSecondary, fontSize: 12)),
                                  Text(money(ticket.totalPrice), style: const TextStyle(color: CinemaTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
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
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: CinemaTheme.cardAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(color: CinemaTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

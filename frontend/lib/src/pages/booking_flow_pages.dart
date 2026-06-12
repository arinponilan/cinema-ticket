import 'package:flutter/material.dart';

import 'package:cinema_mobile/src/app_config.dart';
import 'package:cinema_mobile/src/models/cinema_models.dart';
import 'package:cinema_mobile/src/services/cinema_api.dart';
import 'package:cinema_mobile/src/utils/booking_utils.dart';
import 'package:cinema_mobile/src/theme/tc.dart';


// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// SCREEN 1 â€” SEAT SELECTION
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class ScheduleSelectionPage extends StatefulWidget {
  final MovieData movie;
  final void Function(ScheduleSlot) onSelectSchedule;

  const ScheduleSelectionPage({
    super.key,
    required this.movie,
    required this.onSelectSchedule,
  });

  @override
  State<ScheduleSelectionPage> createState() => _ScheduleSelectionPageState();
}

class _ScheduleSelectionPageState extends State<ScheduleSelectionPage> {
  late Future<List<ScheduleSlot>> _schedulesFuture;

  @override
  void initState() {
    super.initState();
    _schedulesFuture = fetchSchedulesForMovie(widget.movie.id);
  }

  void _retry() {
    setState(() {
      _schedulesFuture = fetchSchedulesForMovie(widget.movie.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TC.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: TC.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Choose Schedule'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.movie.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: TC.textPri,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.movie.genre,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 25),
            const Text(
              'Available sessions',
              style: TextStyle(
                color: TC.textSec,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            FutureBuilder<List<ScheduleSlot>>(
              future: _schedulesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(color: TC.accent),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _messageCard(
                    icon: Icons.wifi_off,
                    title: 'Gagal memuat jadwal',
                    message: 'Pastikan backend berjalan di $apiBaseUrl.',
                    actionLabel: 'COBA LAGI',
                    onAction: _retry,
                  );
                }

                final schedules = snapshot.data ?? [];
                if (schedules.isEmpty) {
                  return _messageCard(
                    icon: Icons.event_busy,
                    title: 'Jadwal belum tersedia',
                    message: 'Tambahkan schedule untuk movie ini di database.',
                  );
                }

                return Column(
                  children: schedules
                      .map(
                        (slot) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () => widget.onSelectSchedule(slot),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: TC.card,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: TC.accent.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          slot.time,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: TC.textPri,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          slot.type,
                                          style: const TextStyle(
                                            color: TC.textSec,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: TC.accent,
                                  ),
                                ],
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
        ),
      ),
    );
  }

  Widget _messageCard({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TC.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TC.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: TC.accent, size: 34),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: TC.textSec, fontSize: 12),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: TC.accent,
                foregroundColor: Colors.black,
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SeatSelectionPage extends StatefulWidget {
  final int userId;
  final MovieData movie;
  final ScheduleSlot schedule;
  final VoidCallback onConfirm;

  const SeatSelectionPage({
    super.key,
    required this.userId,
    required this.movie,
    required this.schedule,
    required this.onConfirm,
  });
  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  static const _rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  static const _cols = 10;
  static const _convFee = 5000.0;
  List<List<SeatModel>> _seats = [];
  bool _isLoadingSeats = true;
  String? _seatError;

  double get _pricePerSeat => widget.movie.price > 0 ? widget.movie.price : 0;

  @override
  void initState() {
    super.initState();
    _loadSeats();
  }

  Future<void> _loadSeats() async {
    setState(() {
      _isLoadingSeats = true;
      _seatError = null;
    });

    try {
      final seats = await fetchSeatsForSchedule(widget.schedule.id);
      if (!mounted) return;
      setState(() {
        _seats = _buildSeatGrid(seats);
        _isLoadingSeats = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _seatError = e.toString();
        _isLoadingSeats = false;
      });
    }
  }

  List<List<SeatModel>> _buildSeatGrid(List<SeatModel> seats) {
    final byNumber = {for (final seat in seats) seat.id: seat};
    return List.generate(
      _rows.length,
      (r) => List.generate(_cols, (c) {
        final id = '${_rows[r]}${c + 1}';
        return byNumber[id] ??
            SeatModel(id: id, status: SeatStatus.booked, dbId: 0);
      }),
    );
  }

  List<SeatModel> get _selected => _seats
      .expand((r) => r)
      .where((s) => s.status == SeatStatus.selected)
      .toList();
  String get _seatLabel =>
      _selected.isEmpty ? '-' : _selected.map((s) => s.id).join(', ');
  double get _total =>
      _selected.length * _pricePerSeat + (_selected.isEmpty ? 0 : _convFee);

  void _toggle(SeatModel s) {
    if (s.status == SeatStatus.booked) return;
    setState(
      () => s.status = s.status == SeatStatus.selected
          ? SeatStatus.available
          : SeatStatus.selected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TC.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: TC.accent.withValues(alpha: 0.15)),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: TC.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: TC.accent),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: TC.accent,
                        size: 16,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'SELECT SEATS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TC.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: TC.card,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: TC.accent,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      widget.movie.title,
                      style: const TextStyle(
                        color: TC.textPri,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.schedule.date.isEmpty ? 'Today' : widget.schedule.date}, ${widget.schedule.time}',
                      style: const TextStyle(color: TC.textSec, fontSize: 13),
                    ),
                    const SizedBox(height: 28),
                    // Layar
                    Column(
                      children: [
                        const Text(
                          'SCREEN',
                          style: TextStyle(
                            color: TC.textSec,
                            fontSize: 9,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                TC.accent,
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: TC.accent.withValues(alpha: 0.7),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    // Grid kursi
                    if (_isLoadingSeats)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 44),
                        child: CircularProgressIndicator(color: TC.accent),
                      )
                    else if (_seatError != null)
                      _seatMessageCard(
                        icon: Icons.wifi_off,
                        title: 'Gagal memuat kursi',
                        message: 'Pastikan backend berjalan di $apiBaseUrl.',
                        actionLabel: 'COBA LAGI',
                        onAction: _loadSeats,
                      )
                    else
                      Column(
                        children: List.generate(
                          _rows.length,
                          (r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  child: Text(
                                    _rows[r],
                                    style: const TextStyle(
                                      color: TC.textSec,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      _cols,
                                      (c) => Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _seatWidget(_seats[r][c]),
                                          if (c == 4) const SizedBox(width: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Legenda
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _leg(TC.seatAvail, 'Available'),
                        const SizedBox(width: 20),
                        _leg(TC.seatSel, 'Selected'),
                        const SizedBox(width: 20),
                        _leg(TC.seatBook, 'Booked'),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Bottom bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: TC.bg,
                border: Border(
                  top: BorderSide(color: TC.accent.withValues(alpha: 0.15)),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL PRICE',
                            style: TextStyle(
                              color: TC.textSec,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            formatRupiah(_total),
                            style: const TextStyle(
                              color: TC.accent,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'SEATS',
                            style: TextStyle(
                              color: TC.textSec,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            _seatLabel,
                            style: const TextStyle(
                              color: TC.textPri,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selected.isEmpty
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewOrderPage(
                                  userId: widget.userId,
                                  movie: widget.movie,
                                  schedule: widget.schedule,
                                  selectedSeats: _selected,
                                  ticketPrice: _pricePerSeat,
                                  convFee: _convFee,
                                  onConfirm: widget.onConfirm,
                                ),
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TC.accent,
                        disabledBackgroundColor: const Color(0xFF3A3A3A),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'CONFIRM SELECTION',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
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

  Widget _seatWidget(SeatModel seat) {
    Color color;
    switch (seat.status) {
      case SeatStatus.available:
        color = TC.seatAvail;
        break;
      case SeatStatus.selected:
        color = TC.seatSel;
        break;
      case SeatStatus.booked:
        color = TC.seatBook;
        break;
    }
    return GestureDetector(
      onTap: () => _toggle(seat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 26,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
            bottomLeft: Radius.circular(2),
            bottomRight: Radius.circular(2),
          ),
          boxShadow: seat.status == SeatStatus.selected
              ? [
                  BoxShadow(
                    color: TC.accent.withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _seatMessageCard({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TC.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TC.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: TC.accent, size: 32),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: TC.textSec, fontSize: 12),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: TC.accent,
                foregroundColor: Colors.black,
              ),
              child: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }

  Widget _leg(Color c, String label) => Row(
    children: [
      Container(
        width: 18,
        height: 14,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(color: TC.textSec, fontSize: 11)),
    ],
  );
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// SCREEN 2 â€” REVIEW ORDER
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class ReviewOrderPage extends StatefulWidget {
  final int userId;
  final MovieData movie;
  final ScheduleSlot schedule;
  final List<SeatModel> selectedSeats;
  final double ticketPrice;
  final double convFee;
  final VoidCallback onConfirm;

  const ReviewOrderPage({
    super.key,
    required this.userId,
    required this.movie,
    required this.schedule,
    required this.selectedSeats,
    required this.ticketPrice,
    required this.convFee,
    required this.onConfirm,
  });

  @override
  State<ReviewOrderPage> createState() => _ReviewOrderPageState();
}

class _ReviewOrderPageState extends State<ReviewOrderPage> {
  bool _isSubmitting = false;

  String get _seatLabel => widget.selectedSeats.map((s) => s.id).join(', ');
  double get _subtotal => widget.selectedSeats.length * widget.ticketPrice;
  double get _grandTotal => _subtotal + widget.convFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TC.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: TC.accent.withValues(alpha: 0.15)),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: TC.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: TC.accent),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: TC.accent,
                        size: 16,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'REVIEW ORDER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TC.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TC.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: TC.accent.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.movie.imgUrl,
                              width: 72,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 72,
                                height: 96,
                                color: TC.surface,
                                child: Center(
                                  child: Text(
                                    widget.movie.title[0],
                                    style: const TextStyle(
                                      color: TC.accent,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.movie.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: TC.textPri,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.movie.genre,
                                  style: const TextStyle(
                                    color: TC.textSec,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule,
                                      color: TC.accent,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${widget.schedule.date.isEmpty ? 'Today' : widget.schedule.date}, ${widget.schedule.time}',
                                      style: const TextStyle(
                                        color: TC.textSec,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'PAYMENT METHOD',
                      style: TextStyle(
                        color: TC.textSec,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _payOpt(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'E-Wallet',
                      sub: 'Bayar dengan dompet digital',
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TC.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: TC.accent.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Column(
                        children: [
                          _feeRow('Seats', _seatLabel),
                          const SizedBox(height: 10),
                          _feeRow(
                            'Tickets',
                            '${widget.selectedSeats.length} x ${formatRupiah(widget.ticketPrice)}',
                          ),
                          const SizedBox(height: 10),
                          _feeRow('Subtotal', formatRupiah(_subtotal)),
                          const SizedBox(height: 10),
                          _feeRow(
                            'Convenience Fee',
                            formatRupiah(widget.convFee),
                          ),
                          const SizedBox(height: 14),
                          Container(height: 1, color: TC.surface),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Grand Total',
                                style: TextStyle(
                                  color: TC.textPri,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                formatRupiah(_grandTotal),
                                style: const TextStyle(
                                  color: TC.accent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              decoration: BoxDecoration(
                color: TC.bg,
                border: Border(
                  top: BorderSide(color: TC.accent.withValues(alpha: 0.15)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _confirmAndSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TC.accent,
                    disabledBackgroundColor: const Color(0xFF3A3A3A),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'PAY & CONFIRM',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _payOpt({
    required IconData icon,
    required String title,
    required String sub,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TC.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TC.accent, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: TC.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: TC.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: TC.textPri,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(color: TC.textHint, fontSize: 12),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TC.accent,
              border: Border.all(color: TC.accent, width: 1.5),
            ),
            child: const Icon(Icons.check, color: Colors.black, size: 13),
          ),
        ],
      ),
    );
  }

  Widget _feeRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: TC.textSec, fontSize: 13)),
      Text(
        value,
        style: const TextStyle(
          color: TC.textPri,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Future<void> _confirmAndSave() async {
    final selectedSeatIds = widget.selectedSeats
        .where((seat) => seat.dbId > 0)
        .map((seat) => seat.dbId)
        .toList();

    if (selectedSeatIds.length != widget.selectedSeats.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data kursi belum valid dari database.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await createBooking(
        userId: widget.userId,
        scheduleId: widget.schedule.id,
        seatIds: selectedSeatIds,
        walletBalance: _grandTotal,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Booking gagal: ${e.toString()}')));
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    const methodLabel = 'E-Wallet';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: TC.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: TC.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: TC.success,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  color: TC.textPri,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tiket ${widget.movie.title} berhasil dipesan!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: TC.textSec, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TC.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _dRow('Seats', _seatLabel, TC.accent),
                    const SizedBox(height: 8),
                    _dRow('Metode', methodLabel, TC.textPri),
                    const SizedBox(height: 8),
                    _dRow(
                      'Total',
                      formatRupiah(_grandTotal),
                      TC.accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Tombol lihat tiket
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                    widget.onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TC.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'LIHAT TIKET SAYA',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TC.accent,
                    side: const BorderSide(color: TC.accent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'KEMBALI KE HOME',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dRow(String label, String value, Color color) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: TC.textSec, fontSize: 12)),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}




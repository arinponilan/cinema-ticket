import '../models/cinema_models.dart';

// ═══════════════════════════════════════════════════════════════
// GLOBAL TICKET LIST — tidak akan reset
// ═══════════════════════════════════════════════════════════════
final List<BookedTicket> globalTickets = [];

String generateBookingCode() {
  final now = DateTime.now();
  return "BKG-${now.millisecondsSinceEpoch % 100000}";
}

String formatRupiah(double value) {
  final amount = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < amount.length; i++) {
    final remaining = amount.length - i;
    buffer.write(amount[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write('.');
    }
  }
  return 'Rp $buffer';
}

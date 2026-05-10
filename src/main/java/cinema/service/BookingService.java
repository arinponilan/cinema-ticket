package cinema.service;

import cinema.dto.BookingRequest;
import cinema.model.*;
import cinema.payment.EWalletPayment;
import cinema.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class BookingService {

    @Autowired private UserRepository userRepository;
    @Autowired private ScheduleRepository scheduleRepository;
    @Autowired private SeatRepository seatRepository;
    @Autowired private BookingRepository bookingRepository;
    @Autowired private TransactionRepository transactionRepository;
    @Autowired private TicketRepository ticketRepository;

    public Ticket processBooking(BookingRequest request) {
        // 1. Validasi User
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new RuntimeException("User tidak ditemukan"));

        // 2. Validasi Schedule
        Schedule schedule = scheduleRepository.findById(request.getScheduleId())
                .orElseThrow(() -> new RuntimeException("Jadwal tidak ditemukan"));

        // 3. Validasi Kursi
        List<Seat> seats = seatRepository.findAllById(request.getSeatIds());
        if (seats.size() != request.getSeatIds().size()) {
            throw new RuntimeException("Beberapa kursi tidak valid");
        }
        for (Seat seat : seats) {
            if (!seat.isAvailable()) {
                throw new RuntimeException("Kursi " + seat.getSeatNumber() + " sudah dipesan!");
            }
        }

        // 4. Hitung Harga
        double moviePrice = schedule.getMovie().getPrice();
        double totalPrice = moviePrice * seats.size();

        // 5. Proses Pembayaran
        EWalletPayment payment = new EWalletPayment(
                request.getEWalletType(), 
                request.getEWalletPhone(), 
                request.getEWalletBalance()
        );
        
        if (!payment.validate()) {
            throw new RuntimeException("Validasi E-Wallet gagal");
        }
        
        if (!payment.pay(totalPrice)) {
            throw new RuntimeException("Saldo tidak cukup! Total: " + totalPrice);
        }

        // 6. Buat Booking
        Booking booking = new Booking();
        booking.setBookingCode("BKG-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        booking.setUser(user);
        booking.setSchedule(schedule);
        booking.setSeats(seats);
        booking.setTotalPrice(totalPrice);
        booking = bookingRepository.save(booking);

        // 7. Update status kursi
        for (Seat seat : seats) {
            seat.bookSeat();
        }
        seatRepository.saveAll(seats);

        // 8. Buat Transaksi
        Transaction transaction = new Transaction();
        transaction.setBooking(booking);
        transaction.setTotal(totalPrice);
        transaction.createTransaction();
        transaction.updateStatus("SUCCESS");
        transactionRepository.save(transaction);

        // 9. Buat Tiket
        Ticket ticket = new Ticket();
        ticket.setBooking(booking);
        return ticketRepository.save(ticket);

    }
}

package cinema.service;

import cinema.dto.BookingRequest;
import cinema.model.*;
import cinema.payment.EWalletPayment;
import cinema.payment.Payment;
import cinema.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.ArrayList;
import java.util.UUID;

@Service
public class BookingService {

    @Autowired private UserRepository userRepository;
    @Autowired private ScheduleRepository scheduleRepository;
    @Autowired private SeatRepository seatRepository;
    @Autowired private BookingRepository bookingRepository;
    @Autowired private TicketRepository ticketRepository;
    @Autowired private TransactionRepository transactionRepository;

    @Transactional
    public Ticket processBooking(BookingRequest request) {
        // 1. Validasi User
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new RuntimeException("User tidak ditemukan"));

        // 2. Validasi Schedule
        Schedule schedule = scheduleRepository.findById(request.getScheduleId())
                .orElseThrow(() -> new RuntimeException("Jadwal tidak ditemukan"));

        // 3. Validasi Kursi berdasarkan seatIds, fallback ke seatNumber + schedule.
        List<Seat> seats = new ArrayList<>();
        if (request.getSeatIds() != null && !request.getSeatIds().isEmpty()) {
            for (Integer seatId : request.getSeatIds()) {
                Seat seat = seatRepository.findById(seatId)
                        .orElseThrow(() -> new RuntimeException("Kursi ID " + seatId + " tidak ditemukan"));
                if (seat.getSchedule() == null || seat.getSchedule().getScheduleId() != schedule.getScheduleId()) {
                    throw new RuntimeException("Kursi " + seat.getSeatNumber() + " bukan bagian dari jadwal ini");
                }
                if (!seat.isAvailable()) {
                    throw new RuntimeException("Kursi " + seat.getSeatNumber() + " sudah dipesan!");
                }
                seats.add(seat);
            }
        } else if (request.getSeatNumbers() != null && !request.getSeatNumbers().isEmpty()) {
            for (String seatNumber : request.getSeatNumbers()) {
                Seat seat = seatRepository.findByScheduleAndSeatNumber(schedule, seatNumber);
                if (seat == null) {
                    throw new RuntimeException("Kursi " + seatNumber + " tidak ditemukan untuk jadwal ini");
                }
                if (!seat.isAvailable()) {
                    throw new RuntimeException("Kursi " + seat.getSeatNumber() + " sudah dipesan!");
                }
                seats.add(seat);
            }
        } else {
            throw new RuntimeException("Pilih minimal satu kursi");
        }

        // 4. Hitung Harga
        double moviePrice = schedule.getMovie().getPrice();
        double totalPrice = moviePrice * seats.size();

        String walletType = request.getWalletType() != null && !request.getWalletType().isBlank()
                ? request.getWalletType()
                : "E-Wallet";
        String phoneNumber = request.getPhoneNumber() != null && !request.getPhoneNumber().isBlank()
                ? request.getPhoneNumber()
                : user.getEmail();
        double walletBalance = request.getWalletBalance() != null
                ? request.getWalletBalance()
                : totalPrice;

        Payment payment = new EWalletPayment(walletType, phoneNumber, walletBalance);
        if (!payment.validate()) {
            throw new RuntimeException("Data e-wallet tidak valid");
        }
        if (!payment.pay(totalPrice)) {
            throw new RuntimeException("Saldo e-wallet tidak cukup");
        }

        // 5. Buat Booking
        Booking booking = new Booking();
        booking.setBookingCode("BKG-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        booking.setUser(user);
        booking.setSchedule(schedule);
        booking.setSeats(seats);
        booking.setTotalPrice(booking.calculateTotal());
        booking.createBooking();
        booking = bookingRepository.save(booking);

        // 6. Update status kursi
        for (Seat seat : seats) {
            seat.bookSeat();
        }
        seatRepository.saveAll(seats);

        // 7. Buat transaksi sesuai relasi 1 booking memiliki 1 transaction.
        Transaction transaction = new Transaction();
        transaction.setBooking(booking);
        transaction.setTotal(booking.getTotalPrice());
        transaction.createTransaction();
        transaction.updateStatus("SUCCESS");
        transactionRepository.save(transaction);

        // 8. Buat tiket per kursi sesuai struktur tickets(booking_id, seat_id, ticket_code).
        List<Ticket> tickets = new ArrayList<>();
        for (Seat seat : seats) {
            Ticket ticket = new Ticket();
            ticket.setBooking(booking);
            ticket.setSeat(seat);
            ticket.setTicketCode("TIX-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
            tickets.add(ticket);
        }
        return ticketRepository.saveAll(tickets).get(0);

    }
}

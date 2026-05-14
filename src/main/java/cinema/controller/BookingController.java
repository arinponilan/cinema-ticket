package cinema.controller;

import cinema.dto.BookingHistoryDto;
import cinema.dto.BookingRequest;
import cinema.dto.ProfileSummaryDto;
import cinema.model.Booking;
import cinema.model.Ticket;
import cinema.service.BookingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/bookings")
@CrossOrigin(origins = "*")
public class BookingController {

    @Autowired
    private BookingService bookingService;

    @Autowired
    private cinema.repository.BookingRepository bookingRepository;

    @PostMapping
    public ResponseEntity<?> bookTicket(@RequestBody BookingRequest request) {
        try {
            Ticket ticket = bookingService.processBooking(request);
            return ResponseEntity.ok(toBookingHistoryDto(ticket.getBooking()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/user/{userId}")
    @Transactional(readOnly = true)
    public ResponseEntity<?> getUserBookings(@PathVariable int userId) {
        List<Booking> bookings = bookingRepository.findByUserUserIdOrderByIdDesc(userId);
        List<BookingHistoryDto> history = bookings.stream()
                .map(this::toBookingHistoryDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(history);
    }

    @GetMapping("/user/{userId}/profile")
    @Transactional(readOnly = true)
    public ResponseEntity<?> getUserProfileSummary(@PathVariable int userId) {
        List<Booking> bookings = bookingRepository.findByUserUserIdOrderByIdDesc(userId);
        List<BookingHistoryDto> history = bookings.stream()
                .map(this::toBookingHistoryDto)
                .collect(Collectors.toList());

        ProfileSummaryDto summary = new ProfileSummaryDto();
        summary.setMoviesWatched(bookings.size());
        summary.setTransactionHistory(history);
        return ResponseEntity.ok(summary);
    }

    private BookingHistoryDto toBookingHistoryDto(Booking booking) {
        BookingHistoryDto dto = new BookingHistoryDto();
        dto.setBookingCode(booking.getBookingCode());
        dto.setMovieTitle(booking.getSchedule() != null && booking.getSchedule().getMovie() != null
                ? booking.getSchedule().getMovie().getTitle()
                : "Unknown Movie");
        dto.setShowTime(booking.getSchedule() != null
                ? booking.getSchedule().getTime()
                : "Unknown Time");
        dto.setBookingDate(booking.getSchedule() != null && booking.getSchedule().getDate() != null
                ? booking.getSchedule().getDate()
                : "Unknown Date");
        dto.setSeatNumbers(booking.getSeats() != null
                ? booking.getSeats().stream().map(seat -> seat.getSeatNumber()).collect(Collectors.toList())
                : List.of());
        dto.setTotalPrice(booking.getTotalPrice());
        return dto;
    }
}

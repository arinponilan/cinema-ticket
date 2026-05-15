package cinema.dto;

import java.util.List;

public class BookingRequest {
    private int userId;
    private int scheduleId;
    private List<Integer> seatIds;
    private List<String> seatNumbers;

    public BookingRequest() {}

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getScheduleId() { return scheduleId; }
    public void setScheduleId(int scheduleId) { this.scheduleId = scheduleId; }

    public List<Integer> getSeatIds() { return seatIds; }
    public void setSeatIds(List<Integer> seatIds) { this.seatIds = seatIds; }

    public List<String> getSeatNumbers() { return seatNumbers; }
    public void setSeatNumbers(List<String> seatNumbers) { this.seatNumbers = seatNumbers; }

}

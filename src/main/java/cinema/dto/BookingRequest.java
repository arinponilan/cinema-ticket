package cinema.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public class BookingRequest {
    private int userId;
    private int scheduleId;
    private List<Integer> seatIds;

    @JsonProperty("eWalletType")
    private String eWalletType;

    @JsonProperty("eWalletPhone")
    private String eWalletPhone;

    @JsonProperty("eWalletBalance")
    private double eWalletBalance;

    public BookingRequest() {}

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getScheduleId() { return scheduleId; }
    public void setScheduleId(int scheduleId) { this.scheduleId = scheduleId; }

    public List<Integer> getSeatIds() { return seatIds; }
    public void setSeatIds(List<Integer> seatIds) { this.seatIds = seatIds; }

    public String getEWalletType() { return eWalletType; }
    public void setEWalletType(String eWalletType) { this.eWalletType = eWalletType; }

    public String getEWalletPhone() { return eWalletPhone; }
    public void setEWalletPhone(String eWalletPhone) { this.eWalletPhone = eWalletPhone; }

    public double getEWalletBalance() { return eWalletBalance; }
    public void setEWalletBalance(double eWalletBalance) { this.eWalletBalance = eWalletBalance; }
}

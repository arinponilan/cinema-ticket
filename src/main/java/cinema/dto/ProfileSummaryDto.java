package cinema.dto;

import java.util.List;

public class ProfileSummaryDto {
    private int moviesWatched;
    private List<BookingHistoryDto> transactionHistory;

    public ProfileSummaryDto() {}

    public int getMoviesWatched() {
        return moviesWatched;
    }

    public void setMoviesWatched(int moviesWatched) {
        this.moviesWatched = moviesWatched;
    }

    public List<BookingHistoryDto> getTransactionHistory() {
        return transactionHistory;
    }

    public void setTransactionHistory(List<BookingHistoryDto> transactionHistory) {
        this.transactionHistory = transactionHistory;
    }
}

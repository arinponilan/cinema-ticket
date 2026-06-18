import java.sql.*;
import java.util.*;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

public class Seed {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres?sslmode=require";
        String user = "postgres.argmelfpcmtjgdvunjqq";
        String pass = "xuphuc-3byjzo-Vepnoc";

        try (Connection conn = DriverManager.getConnection(url, user, pass)) {
            System.out.println("Connected!");
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("TRUNCATE TABLE bookings CASCADE");
                stmt.execute("TRUNCATE TABLE schedules CASCADE");
                System.out.println("Truncated schedules and bookings");

                ResultSet rs = stmt.executeQuery("SELECT id, duration FROM movies");
                List<int[]> movies = new ArrayList<>();
                while (rs.next()) {
                    movies.add(new int[]{rs.getInt("id"), rs.getInt("duration")});
                }

                String date = java.time.LocalDate.now().plusDays(1).toString();
                String[] standardTimes = {"10:00:00", "13:00:00", "16:00:00", "19:00:00"};
                
                PreparedStatement ps = conn.prepareStatement("INSERT INTO schedules (movie_id, date, hall, time, end_time) VALUES (?, ?, ?, ?, ?)");
                
                int studioCounter = 1;
                for (int[] m : movies) {
                    int movieId = m[0];
                    int duration = m[1];
                    String hall = "Studio " + studioCounter;

                    for (String timeStr : standardTimes) {
                        LocalTime startTime = LocalTime.parse(timeStr);
                        int totalMins = duration + 15;
                        LocalTime endTime = startTime.plusMinutes(totalMins);
                        
                        ps.setInt(1, movieId);
                        ps.setString(2, date);
                        ps.setString(3, hall);
                        ps.setString(4, timeStr);
                        ps.setString(5, endTime.format(DateTimeFormatter.ofPattern("HH:mm:ss")));
                        ps.executeUpdate();
                    }
                    studioCounter++;
                    if (studioCounter > 5) studioCounter = 1;
                }
                System.out.println("Seeded schedules successfully.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

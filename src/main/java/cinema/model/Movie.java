package cinema.model;

import jakarta.persistence.*;

@Entity
@Table(name = "movies")
public class Movie {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String title;
    private String genre;
    private int duration;
    private String synopsis;
    private double price;
    private String imageUrl;

    public Movie() {}

    public Movie(String title, String genre, int duration, String synopsis, double price) {
        this.title = title;
        this.genre = genre;
        this.duration = duration;
        this.synopsis = synopsis;
        this.price = price;
    }

    public String getInfo() {
        return title + " (" + genre + ") - " + duration + " mins";
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getGenre() { return genre; }
    public void setGenre(String genre) { this.genre = genre; }

    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }

    public String getSynopsis() { return synopsis; }
    public void setSynopsis(String synopsis) { this.synopsis = synopsis; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
}

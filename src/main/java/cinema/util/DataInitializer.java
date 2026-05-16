package cinema.util;

import cinema.model.Movie;
import cinema.repository.MovieRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Arrays;

@Configuration
public class DataInitializer {

    @Bean
    CommandLineRunner initDatabase(MovieRepository repository) {
        return args -> {
            if (repository.count() > 0) {
                return; // Already populated
            }

            repository.saveAll(Arrays.asList(
                new Movie("AVENGERS: ENDGAME", "ACTION / SCI-FI", 181, "The Avengers assemble once more in order to undo Thanos' actions.", 50000.0, "https://img.fruugo.com/product/7/41/145324147_max.jpg", "4.9"),
                new Movie("SPIDER-MAN: NO WAY HOME", "ACTION / ADVENTURE", 148, "Peter Parker seeks help from Doctor Strange to make people forget his identity.", 45000.0, "https://m.media-amazon.com/images/M/MV5BZWMyYzFjYTYtNTRjYi00OGExLWE2YzgtOGRmYjAxZTU3NzBiXkEyXkFqcGdeQXVyMzQ0MzA0NTM@._V1_.jpg", "4.7"),
                new Movie("BATMAN: THE DARK KNIGHT", "ACTION / DRAMA", 152, "Batman faces the Joker, a criminal mastermind who wants to plunge Gotham into anarchy.", 45000.0, "https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_.jpg", "4.9"),
                new Movie("JOHN WICK 4", "ACTION / THRILLER", 169, "John Wick uncovers a path to defeating The High Table.", 55000.0, "https://m.media-amazon.com/images/M/MV5BMDExZGMyOTMtMDgyYi00NGIwLWJhMTEtOTdkZGFjNmZiMTEwXkEyXkFqcGdeQXVyMjM4NTM5NDY@._V1_.jpg", "4.6"),
                new Movie("GUARDIANS OF THE GALAXY 3", "ACTION / COMEDY", 150, "Peter Quill rallies his team for a dangerous mission to save Rocket.", 45000.0, "https://m.media-amazon.com/images/M/MV5BMDgxOTdjMzYtZGQxMS00ZTAzLWI4Y2UtMTQzN2VlYjYyZWRiXkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_.jpg", "4.7"),
                new Movie("INTERSTELLAR", "SCI-FI / DRAMA", 169, "A team of explorers travel through a wormhole in space in an attempt to ensure humanity's survival.", 40000.0, "https://m.media-amazon.com/images/M/MV5BZjdkOTU3MDktN2IxOS00OGEyLWFmMjktY2FiMmZkNWIyODZiXkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_.jpg", "4.8"),
                new Movie("DUNE: PART TWO", "SCI-FI / ACTION", 166, "Paul Atreides unites with Chani and the Fremen while on a warpath of revenge.", 60000.0, "https://m.media-amazon.com/images/M/MV5BN2QyZGU4ZDctOWMzMy00NTc5LThlOGQtODhmNDI1NmY5YzAwXkEyXkFqcGdeQXVyMDM2NDM2MQ@@._V1_.jpg", "4.7"),
                new Movie("INCEPTION", "SCI-FI / THRILLER", 148, "A thief who steals corporate secrets through use of dream-sharing technology.", 40000.0, "https://m.media-amazon.com/images/M/MV5BMjAxMzY3NjcxNF5BMl5BanBnXkFtZTcwNTI5OTM0Mw@@._V1_.jpg", "4.8"),
                new Movie("JOKER", "DRAMA / CRIME", 122, "A socially disregarded clown is driven to madness.", 35000.0, "https://image.tmdb.org/t/p/original/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg", "4.8"),
                new Movie("OPPENHEIMER", "DRAMA / HISTORY", 180, "The story of J. Robert Oppenheimer's role in the development of the atomic bomb.", 65000.0, "https://m.media-amazon.com/images/M/MV5BMDBmYTZjNjUtN2M1MS00MTQ2LTk2ODgtNzc2M2QyZGE5NTVjXkEyXkFqcGdeQXVyNzAwMjU2MTY@._V1_.jpg", "4.8"),
                new Movie("INSIDE OUT 2", "ANIMATION / COMEDY", 100, "Riley's mind headquarters is undergoing a sudden demolition to make room for new Emotions.", 50000.0, "https://m.media-amazon.com/images/M/MV5BYTc1MDQ3NjAtOWEzMi00YzE1LWI2OWUtNjQ0OWJkMTlhNWI5XkEyXkFqcGdeQXVyMDM2NDM2MQ@@._V1_.jpg", "4.6"),
                new Movie("COCO", "ANIMATION / FANTASY", 105, "Aspiring musician Miguel enters the Land of the Dead.", 35000.0, "https://m.media-amazon.com/images/M/MV5BYjQ5NjM0Y2YtNjZkNC00ZDhkLWJjMWItN2QyNzFkMDE3ZjAxXkEyXkFqcGdeQXVyODIxMzk5NjA@._V1_.jpg", "4.7"),
                new Movie("THE CONJURING", "HORROR / THRILLER", 112, "Paranormal investigators work to help a family terrorized by a dark presence.", 35000.0, "https://m.media-amazon.com/images/M/MV5BMTM3NjA1NDMyMV5BMl5BanBnXkFtZTcwMDQzNDMzOQ@@._V1_.jpg", "4.5"),
                new Movie("A QUIET PLACE", "HORROR / SCI-FI", 90, "A family must live in silence to avoid mysterious creatures that hunt by sound.", 40000.0, "https://m.media-amazon.com/images/M/MV5BMjI0MDMzNTQ0M15BMl5BanBnXkFtZTgwMTM5NzM3NDM@._V1_.jpg", "4.5"),
                new Movie("LA LA LAND", "ROMANCE / MUSICAL", 128, "A pianist and an actress fall in love while attempting to reconcile their aspirations.", 40000.0, "https://m.media-amazon.com/images/M/MV5BMzUzNDM2NzM2MV5BMl5BanBnXkFtZTgwNTM3NTg4OTE@._V1_.jpg", "4.6"),
                new Movie("GLADIATOR 2", "ACTION / DRAMA", 150, "Lucius enters the Colosseum after his home is conquered by tyrannical emperors.", 60000.0, "https://m.media-amazon.com/images/M/MV5BMXUyMWZkMTgtMjBjMC00ZGI0LWFmMDUtZGIzMTA2ZDE2Y2M2XkEyXkFqcGc@._V1_.jpg", "4.5"),
                new Movie("GODZILLA X KONG", "ACTION / SCI-FI", 115, "Two ancient titans, Godzilla and Kong, clash in an epic battle.", 50000.0, "https://m.media-amazon.com/images/M/MV5BODUyZDU4YzQtZGFhZi00YmZmLWExN2ItNTRjMDI0N2RhNzk4XkEyXkFqcGdeQXVyMTEyMjM2NDc2._V1_.jpg", "4.3"),
                new Movie("DEADPOOL & WOLVERINE", "ACTION / COMEDY", 127, "Deadpool and Wolverine team up to save the multiverse.", 70000.0, "https://m.media-amazon.com/images/M/MV5BZTk5OTUxN2ItNmE1Yy00MjE1LWIxN2YtZWVkMjFkNTA0ZDA2XkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_.jpg", "4.8"),
                new Movie("MOANA 2", "ANIMATION / ADVENTURE", 100, "Moana and Maui embark on a new expansive voyage.", 55000.0, "https://m.media-amazon.com/images/M/MV5BNmU4M2E3ZGEtY2Q0Ni00N2Y1LWE2NzItOTY2Y2Y2YmE1YzU5XkEyXkFqcGc@._V1_.jpg", "4.6")
            ));

            System.out.println("Database Initialized with " + repository.count() + " movies.");
        };
    }
}

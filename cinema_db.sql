-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: May 16, 2026 at 03:00 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cinema_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL,
  `booking_code` varchar(255) DEFAULT NULL,
  `total_price` double NOT NULL,
  `schedule_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `booking_seats`
--

CREATE TABLE `booking_seats` (
  `booking_id` int(11) NOT NULL,
  `seat_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `movies`
--

CREATE TABLE `movies` (
  `id` int(11) NOT NULL,
  `duration` int(11) NOT NULL,
  `genre` varchar(255) DEFAULT NULL,
  `price` double NOT NULL,
  `synopsis` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `rating` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `movies`
--

INSERT INTO `movies` (`id`, `duration`, `genre`, `price`, `synopsis`, `title`, `image_url`, `rating`) VALUES
(1, 181, 'ACTION / SCI-FI', 50000, 'The Avengers assemble once more in order to undo Thanos\' actions.', 'AVENGERS: ENDGAME', 'https://img.fruugo.com/product/7/41/145324147_max.jpg', '4.9'),
(2, 148, 'ACTION / ADVENTURE', 45000, 'Peter Parker seeks help from Doctor Strange to make people forget his identity.', 'SPIDER-MAN: NO WAY HOME', 'https://m.media-amazon.com/images/M/MV5BZWMyYzFjYTYtNTRjYi00OGExLWE2YzgtOGRmYjAxZTU3NzBiXkEyXkFqcGdeQXVyMzQ0MzA0NTM@._V1_.jpg', '4.7'),
(3, 152, 'ACTION / DRAMA', 45000, 'Batman faces the Joker, a criminal mastermind who wants to plunge Gotham into anarchy.', 'BATMAN: THE DARK KNIGHT', 'https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_.jpg', '4.9'),
(4, 169, 'ACTION / THRILLER', 55000, 'John Wick uncovers a path to defeating The High Table.', 'JOHN WICK 4', 'https://m.media-amazon.com/images/M/MV5BMDExZGMyOTMtMDgyYi00NGIwLWJhMTEtOTdkZGFjNmZiMTEwXkEyXkFqcGdeQXVyMjM4NTM5NDY@._V1_.jpg', '4.6'),
(5, 150, 'ACTION / COMEDY', 45000, 'Peter Quill rallies his team for a dangerous mission to save Rocket.', 'GUARDIANS OF THE GALAXY 3', 'https://m.media-amazon.com/images/M/MV5BMDgxOTdjMzYtZGQxMS00ZTAzLWI4Y2UtMTQzN2VlYjYyZWRiXkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_.jpg', '4.7'),
(6, 169, 'SCI-FI / DRAMA', 40000, 'A team of explorers travel through a wormhole in space in an attempt to ensure humanity\'s survival.', 'INTERSTELLAR', 'https://m.media-amazon.com/images/M/MV5BZjdkOTU3MDktN2IxOS00OGEyLWFmMjktY2FiMmZkNWIyODZiXkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_.jpg', '4.8'),
(7, 166, 'SCI-FI / ACTION', 60000, 'Paul Atreides unites with Chani and the Fremen while on a warpath of revenge.', 'DUNE: PART TWO', 'https://m.media-amazon.com/images/M/MV5BN2QyZGU4ZDctOWMzMy00NTc5LThlOGQtODhmNDI1NmY5YzAwXkEyXkFqcGdeQXVyMDM2NDM2MQ@@._V1_.jpg', '4.7'),
(8, 148, 'SCI-FI / THRILLER', 40000, 'A thief who steals corporate secrets through use of dream-sharing technology.', 'INCEPTION', 'https://m.media-amazon.com/images/M/MV5BMjAxMzY3NjcxNF5BMl5BanBnXkFtZTcwNTI5OTM0Mw@@._V1_.jpg', '4.8'),
(9, 122, 'DRAMA / CRIME', 35000, 'A socially disregarded clown is driven to madness.', 'JOKER', 'https://image.tmdb.org/t/p/original/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg', '4.8'),
(10, 180, 'DRAMA / HISTORY', 65000, 'The story of J. Robert Oppenheimer\'s role in the development of the atomic bomb.', 'OPPENHEIMER', 'https://m.media-amazon.com/images/M/MV5BMDBmYTZjNjUtN2M1MS00MTQ2LTk2ODgtNzc2M2QyZGE5NTVjXkEyXkFqcGdeQXVyNzAwMjU2MTY@._V1_.jpg', '4.8'),
(11, 100, 'ANIMATION / COMEDY', 50000, 'Riley\'s mind headquarters is undergoing a sudden demolition to make room for new Emotions.', 'INSIDE OUT 2', 'https://m.media-amazon.com/images/M/MV5BYTc1MDQ3NjAtOWEzMi00YzE1LWI2OWUtNjQ0OWJkMTlhNWI5XkEyXkFqcGdeQXVyMDM2NDM2MQ@@._V1_.jpg', '4.6'),
(12, 105, 'ANIMATION / FANTASY', 35000, 'Aspiring musician Miguel enters the Land of the Dead.', 'COCO', 'https://m.media-amazon.com/images/M/MV5BYjQ5NjM0Y2YtNjZkNC00ZDhkLWJjMWItN2QyNzFkMDE3ZjAxXkEyXkFqcGdeQXVyODIxMzk5NjA@._V1_.jpg', '4.7'),
(13, 112, 'HORROR / THRILLER', 35000, 'Paranormal investigators work to help a family terrorized by a dark presence.', 'THE CONJURING', 'https://m.media-amazon.com/images/M/MV5BMTM3NjA1NDMyMV5BMl5BanBnXkFtZTcwMDQzNDMzOQ@@._V1_.jpg', '4.5'),
(14, 90, 'HORROR / SCI-FI', 40000, 'A family must live in silence to avoid mysterious creatures that hunt by sound.', 'A QUIET PLACE', 'https://m.media-amazon.com/images/M/MV5BMjI0MDMzNTQ0M15BMl5BanBnXkFtZTgwMTM5NzM3NDM@._V1_.jpg', '4.5'),
(15, 128, 'ROMANCE / MUSICAL', 40000, 'A pianist and an actress fall in love while attempting to reconcile their aspirations.', 'LA LA LAND', 'https://m.media-amazon.com/images/M/MV5BMzUzNDM2NzM2MV5BMl5BanBnXkFtZTgwNTM3NTg4OTE@._V1_.jpg', '4.6'),
(16, 150, 'ACTION / DRAMA', 60000, 'Lucius enters the Colosseum after his home is conquered by tyrannical emperors.', 'GLADIATOR 2', 'https://m.media-amazon.com/images/M/MV5BMXUyMWZkMTgtMjBjMC00ZGI0LWFmMDUtZGIzMTA2ZDE2Y2M2XkEyXkFqcGc@._V1_.jpg', '4.5'),
(17, 115, 'ACTION / SCI-FI', 50000, 'Two ancient titans, Godzilla and Kong, clash in an epic battle.', 'GODZILLA X KONG', 'https://m.media-amazon.com/images/M/MV5BODUyZDU4YzQtZGFhZi00YmZmLWExN2ItNTRjMDI0N2RhNzk4XkEyXkFqcGdeQXVyMTEyMjM2NDc2._V1_.jpg', '4.3'),
(18, 127, 'ACTION / COMEDY', 70000, 'Deadpool and Wolverine team up to save the multiverse.', 'DEADPOOL & WOLVERINE', 'https://m.media-amazon.com/images/M/MV5BZTk5OTUxN2ItNmE1Yy00MjE1LWIxN2YtZWVkMjFkNTA0ZDA2XkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_.jpg', '4.8'),
(19, 100, 'ANIMATION / ADVENTURE', 55000, 'Moana and Maui embark on a new expansive voyage.', 'MOANA 2', 'https://m.media-amazon.com/images/M/MV5BNmU4M2E3ZGEtY2Q0Ni00N2Y1LWE2NzItOTY2Y2Y2YmE1YzU5XkEyXkFqcGc@._V1_.jpg', '4.6');

-- --------------------------------------------------------

--
-- Table structure for table `schedules`
--

CREATE TABLE `schedules` (
  `schedule_id` int(11) NOT NULL,
  `time` varchar(255) DEFAULT NULL,
  `movie_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `seats`
--

CREATE TABLE `seats` (
  `id` int(11) NOT NULL,
  `is_booked` bit(1) NOT NULL,
  `seat_number` varchar(255) DEFAULT NULL,
  `schedule_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tickets`
--

CREATE TABLE `tickets` (
  `ticket_id` int(11) NOT NULL,
  `booking_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `transaction_id` int(11) NOT NULL,
  `status` varchar(255) DEFAULT NULL,
  `total` double NOT NULL,
  `transaction_date` datetime(6) DEFAULT NULL,
  `booking_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_type` varchar(31) NOT NULL,
  `user_id` int(11) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `balance` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_type`, `user_id`, `email`, `name`, `password`, `balance`) VALUES
('ADMIN', 1, 'admin@gmail.com', 'System Admin', 'admin123', NULL),
('CUSTOMER', 2, 'arin@gmail.com', 'arin', 'arin123', 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FKer0lq2qsui5vv3qn0i6sm1rom` (`schedule_id`),
  ADD KEY `FKeyog2oic85xg7hsu2je2lx3s6` (`user_id`);

--
-- Indexes for table `booking_seats`
--
ALTER TABLE `booking_seats`
  ADD KEY `FKm2vak166qv8osqwe5qcxsn1p` (`seat_id`),
  ADD KEY `FKmbi9ciapn0nvat63t0a8tv478` (`booking_id`);

--
-- Indexes for table `movies`
--
ALTER TABLE `movies`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `schedules`
--
ALTER TABLE `schedules`
  ADD PRIMARY KEY (`schedule_id`),
  ADD KEY `FKrn994bufm9lvyguq5enr8pua2` (`movie_id`);

--
-- Indexes for table `seats`
--
ALTER TABLE `seats`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FKfbw4qi0nr80b7o8kpb25gy2q7` (`schedule_id`);

--
-- Indexes for table `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`ticket_id`),
  ADD UNIQUE KEY `UK_lwytoi4sx2v20kyuj6bvqto1y` (`booking_id`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`transaction_id`),
  ADD UNIQUE KEY `UK_nat4jnsp0mvg3y67bttwlagqy` (`booking_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `UK_6dotkott2kjsp8vw4d0m25fb7` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `movies`
--
ALTER TABLE `movies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `schedules`
--
ALTER TABLE `schedules`
  MODIFY `schedule_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `seats`
--
ALTER TABLE `seats`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tickets`
--
ALTER TABLE `tickets`
  MODIFY `ticket_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `transaction_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `FKer0lq2qsui5vv3qn0i6sm1rom` FOREIGN KEY (`schedule_id`) REFERENCES `schedules` (`schedule_id`),
  ADD CONSTRAINT `FKeyog2oic85xg7hsu2je2lx3s6` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `booking_seats`
--
ALTER TABLE `booking_seats`
  ADD CONSTRAINT `FKm2vak166qv8osqwe5qcxsn1p` FOREIGN KEY (`seat_id`) REFERENCES `seats` (`id`),
  ADD CONSTRAINT `FKmbi9ciapn0nvat63t0a8tv478` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`);

--
-- Constraints for table `schedules`
--
ALTER TABLE `schedules`
  ADD CONSTRAINT `FKrn994bufm9lvyguq5enr8pua2` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`id`);

--
-- Constraints for table `seats`
--
ALTER TABLE `seats`
  ADD CONSTRAINT `FKfbw4qi0nr80b7o8kpb25gy2q7` FOREIGN KEY (`schedule_id`) REFERENCES `schedules` (`schedule_id`);

--
-- Constraints for table `tickets`
--
ALTER TABLE `tickets`
  ADD CONSTRAINT `FKefja4avuu7g29t78mxifrsynb` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`);

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `FK1vvb3q75hdycdrixaiqq80t59` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

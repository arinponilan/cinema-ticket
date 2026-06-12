-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: May 21, 2026 at 01:49 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.0.28

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
  `user_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`id`, `booking_code`, `total_price`, `schedule_id`, `user_id`, `status`) VALUES
(1, 'BKG-45369D29', 100000, 1, 3, 'SUCCESS');

-- --------------------------------------------------------

--
-- Table structure for table `booking_seats`
--

CREATE TABLE `booking_seats` (
  `booking_id` int(11) NOT NULL,
  `seat_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `booking_seats`
--

INSERT INTO `booking_seats` (`booking_id`, `seat_id`) VALUES
(1, 37),
(1, 38);

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
  `image_url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `movies`
--

INSERT INTO `movies` (`id`, `duration`, `genre`, `price`, `synopsis`, `title`, `image_url`) VALUES
(1, 181, 'ACTION / SCI-FI', 50000, 'The Avengers assemble once more in order to undo Thanos\' actions.', 'AVENGERS: ENDGAME', 'https://img.fruugo.com/product/7/41/145324147_max.jpg'),
(2, 148, 'ACTION / ADVENTURE', 45000, 'Peter Parker seeks help from Doctor Strange to make people forget his identity.', 'SPIDER-MAN: NO WAY HOME', 'https://m.media-amazon.com/images/M/MV5BZWMyYzFjYTYtNTRjYi00OGExLWE2YzgtOGRmYjAxZTU3NzBiXkEyXkFqcGdeQXVyMzQ0MzA0NTM@._V1_.jpg'),
(3, 152, 'ACTION / DRAMA', 45000, 'Batman faces the Joker, a criminal mastermind who wants to plunge Gotham into anarchy.', 'BATMAN: THE DARK KNIGHT', 'https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_.jpg'),
(4, 169, 'ACTION / THRILLER', 55000, 'John Wick uncovers a path to defeating The High Table.', 'JOHN WICK 4', 'https://m.media-amazon.com/images/M/MV5BMDExZGMyOTMtMDgyYi00NGIwLWJhMTEtOTdkZGFjNmZiMTEwXkEyXkFqcGdeQXVyMjM4NTM5NDY@._V1_.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `schedules`
--

CREATE TABLE `schedules` (
  `schedule_id` int(11) NOT NULL,
  `time` varchar(255) DEFAULT NULL,
  `movie_id` int(11) DEFAULT NULL,
  `date` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `schedules`
--

INSERT INTO `schedules` (`schedule_id`, `time`, `movie_id`, `date`) VALUES
(1, '12:40:00', 1, '2026-05-21'),
(2, '16:40:00', 1, '2026-05-21'),
(3, '20:40:00', 1, '2026-05-21'),
(4, '11:30:00', 2, '2026-05-21'),
(5, '15:00:00', 2, '2026-05-21'),
(6, '19:30:00', 2, '2026-05-21'),
(7, '10:40:00', 3, '2026-05-21'),
(8, '14:20:00', 3, '2026-05-21'),
(9, '18:10:00', 3, '2026-05-21'),
(10, '13:10:00', 4, '2026-05-21'),
(11, '17:10:00', 4, '2026-05-21'),
(12, '21:00:00', 4, '2026-05-21');

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

--
-- Dumping data for table `seats`
--

INSERT INTO `seats` (`id`, `is_booked`, `seat_number`, `schedule_id`) VALUES
(1, b'0', 'A1', 1),
(2, b'0', 'A2', 1),
(3, b'0', 'A3', 1),
(4, b'0', 'A4', 1),
(5, b'0', 'A5', 1),
(6, b'0', 'A6', 1),
(7, b'0', 'A7', 1),
(8, b'0', 'A8', 1),
(9, b'0', 'A9', 1),
(10, b'0', 'A10', 1),
(11, b'0', 'B1', 1),
(12, b'0', 'B2', 1),
(13, b'0', 'B3', 1),
(14, b'0', 'B4', 1),
(15, b'0', 'B5', 1),
(16, b'0', 'B6', 1),
(17, b'0', 'B7', 1),
(18, b'0', 'B8', 1),
(19, b'0', 'B9', 1),
(20, b'0', 'B10', 1),
(21, b'0', 'C1', 1),
(22, b'0', 'C2', 1),
(23, b'0', 'C3', 1),
(24, b'0', 'C4', 1),
(25, b'0', 'C5', 1),
(26, b'0', 'C6', 1),
(27, b'0', 'C7', 1),
(28, b'0', 'C8', 1),
(29, b'0', 'C9', 1),
(30, b'0', 'C10', 1),
(31, b'0', 'D1', 1),
(32, b'0', 'D2', 1),
(33, b'0', 'D3', 1),
(34, b'0', 'D4', 1),
(35, b'0', 'D5', 1),
(36, b'0', 'D6', 1),
(37, b'1', 'D7', 1),
(38, b'1', 'D8', 1),
(39, b'0', 'D9', 1),
(40, b'0', 'D10', 1),
(41, b'0', 'E1', 1),
(42, b'0', 'E2', 1),
(43, b'0', 'E3', 1),
(44, b'0', 'E4', 1),
(45, b'0', 'E5', 1),
(46, b'0', 'E6', 1),
(47, b'0', 'E7', 1),
(48, b'0', 'E8', 1),
(49, b'0', 'E9', 1),
(50, b'0', 'E10', 1),
(51, b'0', 'F1', 1),
(52, b'0', 'F2', 1),
(53, b'0', 'F3', 1),
(54, b'0', 'F4', 1),
(55, b'0', 'F5', 1),
(56, b'0', 'F6', 1),
(57, b'0', 'F7', 1),
(58, b'0', 'F8', 1),
(59, b'0', 'F9', 1),
(60, b'0', 'F10', 1),
(61, b'0', 'G1', 1),
(62, b'0', 'G2', 1),
(63, b'0', 'G3', 1),
(64, b'0', 'G4', 1),
(65, b'0', 'G5', 1),
(66, b'0', 'G6', 1),
(67, b'0', 'G7', 1),
(68, b'0', 'G8', 1),
(69, b'0', 'G9', 1),
(70, b'0', 'G10', 1),
(71, b'0', 'H1', 1),
(72, b'0', 'H2', 1),
(73, b'0', 'H3', 1),
(74, b'0', 'H4', 1),
(75, b'0', 'H5', 1),
(76, b'0', 'H6', 1),
(77, b'0', 'H7', 1),
(78, b'0', 'H8', 1),
(79, b'0', 'H9', 1),
(80, b'0', 'H10', 1),
(81, b'0', 'A1', 2),
(82, b'0', 'A2', 2),
(83, b'0', 'A3', 2),
(84, b'0', 'A4', 2),
(85, b'0', 'A5', 2),
(86, b'0', 'A6', 2),
(87, b'0', 'A7', 2),
(88, b'0', 'A8', 2),
(89, b'0', 'A9', 2),
(90, b'0', 'A10', 2),
(91, b'0', 'B1', 2),
(92, b'0', 'B2', 2),
(93, b'0', 'B3', 2),
(94, b'0', 'B4', 2),
(95, b'0', 'B5', 2),
(96, b'0', 'B6', 2),
(97, b'0', 'B7', 2),
(98, b'0', 'B8', 2),
(99, b'0', 'B9', 2),
(100, b'0', 'B10', 2),
(101, b'0', 'C1', 2),
(102, b'0', 'C2', 2),
(103, b'0', 'C3', 2),
(104, b'0', 'C4', 2),
(105, b'0', 'C5', 2),
(106, b'0', 'C6', 2),
(107, b'0', 'C7', 2),
(108, b'0', 'C8', 2),
(109, b'0', 'C9', 2),
(110, b'0', 'C10', 2),
(111, b'0', 'D1', 2),
(112, b'0', 'D2', 2),
(113, b'0', 'D3', 2),
(114, b'0', 'D4', 2),
(115, b'0', 'D5', 2),
(116, b'0', 'D6', 2),
(117, b'0', 'D7', 2),
(118, b'0', 'D8', 2),
(119, b'0', 'D9', 2),
(120, b'0', 'D10', 2),
(121, b'0', 'E1', 2),
(122, b'0', 'E2', 2),
(123, b'0', 'E3', 2),
(124, b'0', 'E4', 2),
(125, b'0', 'E5', 2),
(126, b'0', 'E6', 2),
(127, b'0', 'E7', 2),
(128, b'0', 'E8', 2),
(129, b'0', 'E9', 2),
(130, b'0', 'E10', 2),
(131, b'0', 'F1', 2),
(132, b'0', 'F2', 2),
(133, b'0', 'F3', 2),
(134, b'0', 'F4', 2),
(135, b'0', 'F5', 2),
(136, b'0', 'F6', 2),
(137, b'0', 'F7', 2),
(138, b'0', 'F8', 2),
(139, b'0', 'F9', 2),
(140, b'0', 'F10', 2),
(141, b'0', 'G1', 2),
(142, b'0', 'G2', 2),
(143, b'0', 'G3', 2),
(144, b'0', 'G4', 2),
(145, b'0', 'G5', 2),
(146, b'0', 'G6', 2),
(147, b'0', 'G7', 2),
(148, b'0', 'G8', 2),
(149, b'0', 'G9', 2),
(150, b'0', 'G10', 2),
(151, b'0', 'H1', 2),
(152, b'0', 'H2', 2),
(153, b'0', 'H3', 2),
(154, b'0', 'H4', 2),
(155, b'0', 'H5', 2),
(156, b'0', 'H6', 2),
(157, b'0', 'H7', 2),
(158, b'0', 'H8', 2),
(159, b'0', 'H9', 2),
(160, b'0', 'H10', 2),
(161, b'0', 'A1', 3),
(162, b'0', 'A2', 3),
(163, b'0', 'A3', 3),
(164, b'0', 'A4', 3),
(165, b'0', 'A5', 3),
(166, b'0', 'A6', 3),
(167, b'0', 'A7', 3),
(168, b'0', 'A8', 3),
(169, b'0', 'A9', 3),
(170, b'0', 'A10', 3),
(171, b'0', 'B1', 3),
(172, b'0', 'B2', 3),
(173, b'0', 'B3', 3),
(174, b'0', 'B4', 3),
(175, b'0', 'B5', 3),
(176, b'0', 'B6', 3),
(177, b'0', 'B7', 3),
(178, b'0', 'B8', 3),
(179, b'0', 'B9', 3),
(180, b'0', 'B10', 3),
(181, b'0', 'C1', 3),
(182, b'0', 'C2', 3),
(183, b'0', 'C3', 3),
(184, b'0', 'C4', 3),
(185, b'0', 'C5', 3),
(186, b'0', 'C6', 3),
(187, b'0', 'C7', 3),
(188, b'0', 'C8', 3),
(189, b'0', 'C9', 3),
(190, b'0', 'C10', 3),
(191, b'0', 'D1', 3),
(192, b'0', 'D2', 3),
(193, b'0', 'D3', 3),
(194, b'0', 'D4', 3),
(195, b'0', 'D5', 3),
(196, b'0', 'D6', 3),
(197, b'0', 'D7', 3),
(198, b'0', 'D8', 3),
(199, b'0', 'D9', 3),
(200, b'0', 'D10', 3),
(201, b'0', 'E1', 3),
(202, b'0', 'E2', 3),
(203, b'0', 'E3', 3),
(204, b'0', 'E4', 3),
(205, b'0', 'E5', 3),
(206, b'0', 'E6', 3),
(207, b'0', 'E7', 3),
(208, b'0', 'E8', 3),
(209, b'0', 'E9', 3),
(210, b'0', 'E10', 3),
(211, b'0', 'F1', 3),
(212, b'0', 'F2', 3),
(213, b'0', 'F3', 3),
(214, b'0', 'F4', 3),
(215, b'0', 'F5', 3),
(216, b'0', 'F6', 3),
(217, b'0', 'F7', 3),
(218, b'0', 'F8', 3),
(219, b'0', 'F9', 3),
(220, b'0', 'F10', 3),
(221, b'0', 'G1', 3),
(222, b'0', 'G2', 3),
(223, b'0', 'G3', 3),
(224, b'0', 'G4', 3),
(225, b'0', 'G5', 3),
(226, b'0', 'G6', 3),
(227, b'0', 'G7', 3),
(228, b'0', 'G8', 3),
(229, b'0', 'G9', 3),
(230, b'0', 'G10', 3),
(231, b'0', 'H1', 3),
(232, b'0', 'H2', 3),
(233, b'0', 'H3', 3),
(234, b'0', 'H4', 3),
(235, b'0', 'H5', 3),
(236, b'0', 'H6', 3),
(237, b'0', 'H7', 3),
(238, b'0', 'H8', 3),
(239, b'0', 'H9', 3),
(240, b'0', 'H10', 3),
(241, b'0', 'A1', 4),
(242, b'0', 'A2', 4),
(243, b'0', 'A3', 4),
(244, b'0', 'A4', 4),
(245, b'0', 'A5', 4),
(246, b'0', 'A6', 4),
(247, b'0', 'A7', 4),
(248, b'0', 'A8', 4),
(249, b'0', 'A9', 4),
(250, b'0', 'A10', 4),
(251, b'0', 'B1', 4),
(252, b'0', 'B2', 4),
(253, b'0', 'B3', 4),
(254, b'0', 'B4', 4),
(255, b'0', 'B5', 4),
(256, b'0', 'B6', 4),
(257, b'0', 'B7', 4),
(258, b'0', 'B8', 4),
(259, b'0', 'B9', 4),
(260, b'0', 'B10', 4),
(261, b'0', 'C1', 4),
(262, b'0', 'C2', 4),
(263, b'0', 'C3', 4),
(264, b'0', 'C4', 4),
(265, b'0', 'C5', 4),
(266, b'0', 'C6', 4),
(267, b'0', 'C7', 4),
(268, b'0', 'C8', 4),
(269, b'0', 'C9', 4),
(270, b'0', 'C10', 4),
(271, b'0', 'D1', 4),
(272, b'0', 'D2', 4),
(273, b'0', 'D3', 4),
(274, b'0', 'D4', 4),
(275, b'0', 'D5', 4),
(276, b'0', 'D6', 4),
(277, b'0', 'D7', 4),
(278, b'0', 'D8', 4),
(279, b'0', 'D9', 4),
(280, b'0', 'D10', 4),
(281, b'0', 'E1', 4),
(282, b'0', 'E2', 4),
(283, b'0', 'E3', 4),
(284, b'0', 'E4', 4),
(285, b'0', 'E5', 4),
(286, b'0', 'E6', 4),
(287, b'0', 'E7', 4),
(288, b'0', 'E8', 4),
(289, b'0', 'E9', 4),
(290, b'0', 'E10', 4),
(291, b'0', 'F1', 4),
(292, b'0', 'F2', 4),
(293, b'0', 'F3', 4),
(294, b'0', 'F4', 4),
(295, b'0', 'F5', 4),
(296, b'0', 'F6', 4),
(297, b'0', 'F7', 4),
(298, b'0', 'F8', 4),
(299, b'0', 'F9', 4),
(300, b'0', 'F10', 4),
(301, b'0', 'G1', 4),
(302, b'0', 'G2', 4),
(303, b'0', 'G3', 4),
(304, b'0', 'G4', 4),
(305, b'0', 'G5', 4),
(306, b'0', 'G6', 4),
(307, b'0', 'G7', 4),
(308, b'0', 'G8', 4),
(309, b'0', 'G9', 4),
(310, b'0', 'G10', 4),
(311, b'0', 'H1', 4),
(312, b'0', 'H2', 4),
(313, b'0', 'H3', 4),
(314, b'0', 'H4', 4),
(315, b'0', 'H5', 4),
(316, b'0', 'H6', 4),
(317, b'0', 'H7', 4),
(318, b'0', 'H8', 4),
(319, b'0', 'H9', 4),
(320, b'0', 'H10', 4),
(321, b'0', 'A1', 5),
(322, b'0', 'A2', 5),
(323, b'0', 'A3', 5),
(324, b'0', 'A4', 5),
(325, b'0', 'A5', 5),
(326, b'0', 'A6', 5),
(327, b'0', 'A7', 5),
(328, b'0', 'A8', 5),
(329, b'0', 'A9', 5),
(330, b'0', 'A10', 5),
(331, b'0', 'B1', 5),
(332, b'0', 'B2', 5),
(333, b'0', 'B3', 5),
(334, b'0', 'B4', 5),
(335, b'0', 'B5', 5),
(336, b'0', 'B6', 5),
(337, b'0', 'B7', 5),
(338, b'0', 'B8', 5),
(339, b'0', 'B9', 5),
(340, b'0', 'B10', 5),
(341, b'0', 'C1', 5),
(342, b'0', 'C2', 5),
(343, b'0', 'C3', 5),
(344, b'0', 'C4', 5),
(345, b'0', 'C5', 5),
(346, b'0', 'C6', 5),
(347, b'0', 'C7', 5),
(348, b'0', 'C8', 5),
(349, b'0', 'C9', 5),
(350, b'0', 'C10', 5),
(351, b'0', 'D1', 5),
(352, b'0', 'D2', 5),
(353, b'0', 'D3', 5),
(354, b'0', 'D4', 5),
(355, b'0', 'D5', 5),
(356, b'0', 'D6', 5),
(357, b'0', 'D7', 5),
(358, b'0', 'D8', 5),
(359, b'0', 'D9', 5),
(360, b'0', 'D10', 5),
(361, b'0', 'E1', 5),
(362, b'0', 'E2', 5),
(363, b'0', 'E3', 5),
(364, b'0', 'E4', 5),
(365, b'0', 'E5', 5),
(366, b'0', 'E6', 5),
(367, b'0', 'E7', 5),
(368, b'0', 'E8', 5),
(369, b'0', 'E9', 5),
(370, b'0', 'E10', 5),
(371, b'0', 'F1', 5),
(372, b'0', 'F2', 5),
(373, b'0', 'F3', 5),
(374, b'0', 'F4', 5),
(375, b'0', 'F5', 5),
(376, b'0', 'F6', 5),
(377, b'0', 'F7', 5),
(378, b'0', 'F8', 5),
(379, b'0', 'F9', 5),
(380, b'0', 'F10', 5),
(381, b'0', 'G1', 5),
(382, b'0', 'G2', 5),
(383, b'0', 'G3', 5),
(384, b'0', 'G4', 5),
(385, b'0', 'G5', 5),
(386, b'0', 'G6', 5),
(387, b'0', 'G7', 5),
(388, b'0', 'G8', 5),
(389, b'0', 'G9', 5),
(390, b'0', 'G10', 5),
(391, b'0', 'H1', 5),
(392, b'0', 'H2', 5),
(393, b'0', 'H3', 5),
(394, b'0', 'H4', 5),
(395, b'0', 'H5', 5),
(396, b'0', 'H6', 5),
(397, b'0', 'H7', 5),
(398, b'0', 'H8', 5),
(399, b'0', 'H9', 5),
(400, b'0', 'H10', 5),
(401, b'0', 'A1', 6),
(402, b'0', 'A2', 6),
(403, b'0', 'A3', 6),
(404, b'0', 'A4', 6),
(405, b'0', 'A5', 6),
(406, b'0', 'A6', 6),
(407, b'0', 'A7', 6),
(408, b'0', 'A8', 6),
(409, b'0', 'A9', 6),
(410, b'0', 'A10', 6),
(411, b'0', 'B1', 6),
(412, b'0', 'B2', 6),
(413, b'0', 'B3', 6),
(414, b'0', 'B4', 6),
(415, b'0', 'B5', 6),
(416, b'0', 'B6', 6),
(417, b'0', 'B7', 6),
(418, b'0', 'B8', 6),
(419, b'0', 'B9', 6),
(420, b'0', 'B10', 6),
(421, b'0', 'C1', 6),
(422, b'0', 'C2', 6),
(423, b'0', 'C3', 6),
(424, b'0', 'C4', 6),
(425, b'0', 'C5', 6),
(426, b'0', 'C6', 6),
(427, b'0', 'C7', 6),
(428, b'0', 'C8', 6),
(429, b'0', 'C9', 6),
(430, b'0', 'C10', 6),
(431, b'0', 'D1', 6),
(432, b'0', 'D2', 6),
(433, b'0', 'D3', 6),
(434, b'0', 'D4', 6),
(435, b'0', 'D5', 6),
(436, b'0', 'D6', 6),
(437, b'0', 'D7', 6),
(438, b'0', 'D8', 6),
(439, b'0', 'D9', 6),
(440, b'0', 'D10', 6),
(441, b'0', 'E1', 6),
(442, b'0', 'E2', 6),
(443, b'0', 'E3', 6),
(444, b'0', 'E4', 6),
(445, b'0', 'E5', 6),
(446, b'0', 'E6', 6),
(447, b'0', 'E7', 6),
(448, b'0', 'E8', 6),
(449, b'0', 'E9', 6),
(450, b'0', 'E10', 6),
(451, b'0', 'F1', 6),
(452, b'0', 'F2', 6),
(453, b'0', 'F3', 6),
(454, b'0', 'F4', 6),
(455, b'0', 'F5', 6),
(456, b'0', 'F6', 6),
(457, b'0', 'F7', 6),
(458, b'0', 'F8', 6),
(459, b'0', 'F9', 6),
(460, b'0', 'F10', 6),
(461, b'0', 'G1', 6),
(462, b'0', 'G2', 6),
(463, b'0', 'G3', 6),
(464, b'0', 'G4', 6),
(465, b'0', 'G5', 6),
(466, b'0', 'G6', 6),
(467, b'0', 'G7', 6),
(468, b'0', 'G8', 6),
(469, b'0', 'G9', 6),
(470, b'0', 'G10', 6),
(471, b'0', 'H1', 6),
(472, b'0', 'H2', 6),
(473, b'0', 'H3', 6),
(474, b'0', 'H4', 6),
(475, b'0', 'H5', 6),
(476, b'0', 'H6', 6),
(477, b'0', 'H7', 6),
(478, b'0', 'H8', 6),
(479, b'0', 'H9', 6),
(480, b'0', 'H10', 6),
(481, b'0', 'A1', 7),
(482, b'0', 'A2', 7),
(483, b'0', 'A3', 7),
(484, b'0', 'A4', 7),
(485, b'0', 'A5', 7),
(486, b'0', 'A6', 7),
(487, b'0', 'A7', 7),
(488, b'0', 'A8', 7),
(489, b'0', 'A9', 7),
(490, b'0', 'A10', 7),
(491, b'0', 'B1', 7),
(492, b'0', 'B2', 7),
(493, b'0', 'B3', 7),
(494, b'0', 'B4', 7),
(495, b'0', 'B5', 7),
(496, b'0', 'B6', 7),
(497, b'0', 'B7', 7),
(498, b'0', 'B8', 7),
(499, b'0', 'B9', 7),
(500, b'0', 'B10', 7),
(501, b'0', 'C1', 7),
(502, b'0', 'C2', 7),
(503, b'0', 'C3', 7),
(504, b'0', 'C4', 7),
(505, b'0', 'C5', 7),
(506, b'0', 'C6', 7),
(507, b'0', 'C7', 7),
(508, b'0', 'C8', 7),
(509, b'0', 'C9', 7),
(510, b'0', 'C10', 7),
(511, b'0', 'D1', 7),
(512, b'0', 'D2', 7),
(513, b'0', 'D3', 7),
(514, b'0', 'D4', 7),
(515, b'0', 'D5', 7),
(516, b'0', 'D6', 7),
(517, b'0', 'D7', 7),
(518, b'0', 'D8', 7),
(519, b'0', 'D9', 7),
(520, b'0', 'D10', 7),
(521, b'0', 'E1', 7),
(522, b'0', 'E2', 7),
(523, b'0', 'E3', 7),
(524, b'0', 'E4', 7),
(525, b'0', 'E5', 7),
(526, b'0', 'E6', 7),
(527, b'0', 'E7', 7),
(528, b'0', 'E8', 7),
(529, b'0', 'E9', 7),
(530, b'0', 'E10', 7),
(531, b'0', 'F1', 7),
(532, b'0', 'F2', 7),
(533, b'0', 'F3', 7),
(534, b'0', 'F4', 7),
(535, b'0', 'F5', 7),
(536, b'0', 'F6', 7),
(537, b'0', 'F7', 7),
(538, b'0', 'F8', 7),
(539, b'0', 'F9', 7),
(540, b'0', 'F10', 7),
(541, b'0', 'G1', 7),
(542, b'0', 'G2', 7),
(543, b'0', 'G3', 7),
(544, b'0', 'G4', 7),
(545, b'0', 'G5', 7),
(546, b'0', 'G6', 7),
(547, b'0', 'G7', 7),
(548, b'0', 'G8', 7),
(549, b'0', 'G9', 7),
(550, b'0', 'G10', 7),
(551, b'0', 'H1', 7),
(552, b'0', 'H2', 7),
(553, b'0', 'H3', 7),
(554, b'0', 'H4', 7),
(555, b'0', 'H5', 7),
(556, b'0', 'H6', 7),
(557, b'0', 'H7', 7),
(558, b'0', 'H8', 7),
(559, b'0', 'H9', 7),
(560, b'0', 'H10', 7),
(561, b'0', 'A1', 8),
(562, b'0', 'A2', 8),
(563, b'0', 'A3', 8),
(564, b'0', 'A4', 8),
(565, b'0', 'A5', 8),
(566, b'0', 'A6', 8),
(567, b'0', 'A7', 8),
(568, b'0', 'A8', 8),
(569, b'0', 'A9', 8),
(570, b'0', 'A10', 8),
(571, b'0', 'B1', 8),
(572, b'0', 'B2', 8),
(573, b'0', 'B3', 8),
(574, b'0', 'B4', 8),
(575, b'0', 'B5', 8),
(576, b'0', 'B6', 8),
(577, b'0', 'B7', 8),
(578, b'0', 'B8', 8),
(579, b'0', 'B9', 8),
(580, b'0', 'B10', 8),
(581, b'0', 'C1', 8),
(582, b'0', 'C2', 8),
(583, b'0', 'C3', 8),
(584, b'0', 'C4', 8),
(585, b'0', 'C5', 8),
(586, b'0', 'C6', 8),
(587, b'0', 'C7', 8),
(588, b'0', 'C8', 8),
(589, b'0', 'C9', 8),
(590, b'0', 'C10', 8),
(591, b'0', 'D1', 8),
(592, b'0', 'D2', 8),
(593, b'0', 'D3', 8),
(594, b'0', 'D4', 8),
(595, b'0', 'D5', 8),
(596, b'0', 'D6', 8),
(597, b'0', 'D7', 8),
(598, b'0', 'D8', 8),
(599, b'0', 'D9', 8),
(600, b'0', 'D10', 8),
(601, b'0', 'E1', 8),
(602, b'0', 'E2', 8),
(603, b'0', 'E3', 8),
(604, b'0', 'E4', 8),
(605, b'0', 'E5', 8),
(606, b'0', 'E6', 8),
(607, b'0', 'E7', 8),
(608, b'0', 'E8', 8),
(609, b'0', 'E9', 8),
(610, b'0', 'E10', 8),
(611, b'0', 'F1', 8),
(612, b'0', 'F2', 8),
(613, b'0', 'F3', 8),
(614, b'0', 'F4', 8),
(615, b'0', 'F5', 8),
(616, b'0', 'F6', 8),
(617, b'0', 'F7', 8),
(618, b'0', 'F8', 8),
(619, b'0', 'F9', 8),
(620, b'0', 'F10', 8),
(621, b'0', 'G1', 8),
(622, b'0', 'G2', 8),
(623, b'0', 'G3', 8),
(624, b'0', 'G4', 8),
(625, b'0', 'G5', 8),
(626, b'0', 'G6', 8),
(627, b'0', 'G7', 8),
(628, b'0', 'G8', 8),
(629, b'0', 'G9', 8),
(630, b'0', 'G10', 8),
(631, b'0', 'H1', 8),
(632, b'0', 'H2', 8),
(633, b'0', 'H3', 8),
(634, b'0', 'H4', 8),
(635, b'0', 'H5', 8),
(636, b'0', 'H6', 8),
(637, b'0', 'H7', 8),
(638, b'0', 'H8', 8),
(639, b'0', 'H9', 8),
(640, b'0', 'H10', 8),
(641, b'0', 'A1', 9),
(642, b'0', 'A2', 9),
(643, b'0', 'A3', 9),
(644, b'0', 'A4', 9),
(645, b'0', 'A5', 9),
(646, b'0', 'A6', 9),
(647, b'0', 'A7', 9),
(648, b'0', 'A8', 9),
(649, b'0', 'A9', 9),
(650, b'0', 'A10', 9),
(651, b'0', 'B1', 9),
(652, b'0', 'B2', 9),
(653, b'0', 'B3', 9),
(654, b'0', 'B4', 9),
(655, b'0', 'B5', 9),
(656, b'0', 'B6', 9),
(657, b'0', 'B7', 9),
(658, b'0', 'B8', 9),
(659, b'0', 'B9', 9),
(660, b'0', 'B10', 9),
(661, b'0', 'C1', 9),
(662, b'0', 'C2', 9),
(663, b'0', 'C3', 9),
(664, b'0', 'C4', 9),
(665, b'0', 'C5', 9),
(666, b'0', 'C6', 9),
(667, b'0', 'C7', 9),
(668, b'0', 'C8', 9),
(669, b'0', 'C9', 9),
(670, b'0', 'C10', 9),
(671, b'0', 'D1', 9),
(672, b'0', 'D2', 9),
(673, b'0', 'D3', 9),
(674, b'0', 'D4', 9),
(675, b'0', 'D5', 9),
(676, b'0', 'D6', 9),
(677, b'0', 'D7', 9),
(678, b'0', 'D8', 9),
(679, b'0', 'D9', 9),
(680, b'0', 'D10', 9),
(681, b'0', 'E1', 9),
(682, b'0', 'E2', 9),
(683, b'0', 'E3', 9),
(684, b'0', 'E4', 9),
(685, b'0', 'E5', 9),
(686, b'0', 'E6', 9),
(687, b'0', 'E7', 9),
(688, b'0', 'E8', 9),
(689, b'0', 'E9', 9),
(690, b'0', 'E10', 9),
(691, b'0', 'F1', 9),
(692, b'0', 'F2', 9),
(693, b'0', 'F3', 9),
(694, b'0', 'F4', 9),
(695, b'0', 'F5', 9),
(696, b'0', 'F6', 9),
(697, b'0', 'F7', 9),
(698, b'0', 'F8', 9),
(699, b'0', 'F9', 9),
(700, b'0', 'F10', 9),
(701, b'0', 'G1', 9),
(702, b'0', 'G2', 9),
(703, b'0', 'G3', 9),
(704, b'0', 'G4', 9),
(705, b'0', 'G5', 9),
(706, b'0', 'G6', 9),
(707, b'0', 'G7', 9),
(708, b'0', 'G8', 9),
(709, b'0', 'G9', 9),
(710, b'0', 'G10', 9),
(711, b'0', 'H1', 9),
(712, b'0', 'H2', 9),
(713, b'0', 'H3', 9),
(714, b'0', 'H4', 9),
(715, b'0', 'H5', 9),
(716, b'0', 'H6', 9),
(717, b'0', 'H7', 9),
(718, b'0', 'H8', 9),
(719, b'0', 'H9', 9),
(720, b'0', 'H10', 9),
(721, b'0', 'A1', 10),
(722, b'0', 'A2', 10),
(723, b'0', 'A3', 10),
(724, b'0', 'A4', 10),
(725, b'0', 'A5', 10),
(726, b'0', 'A6', 10),
(727, b'0', 'A7', 10),
(728, b'0', 'A8', 10),
(729, b'0', 'A9', 10),
(730, b'0', 'A10', 10),
(731, b'0', 'B1', 10),
(732, b'0', 'B2', 10),
(733, b'0', 'B3', 10),
(734, b'0', 'B4', 10),
(735, b'0', 'B5', 10),
(736, b'0', 'B6', 10),
(737, b'0', 'B7', 10),
(738, b'0', 'B8', 10),
(739, b'0', 'B9', 10),
(740, b'0', 'B10', 10),
(741, b'0', 'C1', 10),
(742, b'0', 'C2', 10),
(743, b'0', 'C3', 10),
(744, b'0', 'C4', 10),
(745, b'0', 'C5', 10),
(746, b'0', 'C6', 10),
(747, b'0', 'C7', 10),
(748, b'0', 'C8', 10),
(749, b'0', 'C9', 10),
(750, b'0', 'C10', 10),
(751, b'0', 'D1', 10),
(752, b'0', 'D2', 10),
(753, b'0', 'D3', 10),
(754, b'0', 'D4', 10),
(755, b'0', 'D5', 10),
(756, b'0', 'D6', 10),
(757, b'0', 'D7', 10),
(758, b'0', 'D8', 10),
(759, b'0', 'D9', 10),
(760, b'0', 'D10', 10),
(761, b'0', 'E1', 10),
(762, b'0', 'E2', 10),
(763, b'0', 'E3', 10),
(764, b'0', 'E4', 10),
(765, b'0', 'E5', 10),
(766, b'0', 'E6', 10),
(767, b'0', 'E7', 10),
(768, b'0', 'E8', 10),
(769, b'0', 'E9', 10),
(770, b'0', 'E10', 10),
(771, b'0', 'F1', 10),
(772, b'0', 'F2', 10),
(773, b'0', 'F3', 10),
(774, b'0', 'F4', 10),
(775, b'0', 'F5', 10),
(776, b'0', 'F6', 10),
(777, b'0', 'F7', 10),
(778, b'0', 'F8', 10),
(779, b'0', 'F9', 10),
(780, b'0', 'F10', 10),
(781, b'0', 'G1', 10),
(782, b'0', 'G2', 10),
(783, b'0', 'G3', 10),
(784, b'0', 'G4', 10),
(785, b'0', 'G5', 10),
(786, b'0', 'G6', 10),
(787, b'0', 'G7', 10),
(788, b'0', 'G8', 10),
(789, b'0', 'G9', 10),
(790, b'0', 'G10', 10),
(791, b'0', 'H1', 10),
(792, b'0', 'H2', 10),
(793, b'0', 'H3', 10),
(794, b'0', 'H4', 10),
(795, b'0', 'H5', 10),
(796, b'0', 'H6', 10),
(797, b'0', 'H7', 10),
(798, b'0', 'H8', 10),
(799, b'0', 'H9', 10),
(800, b'0', 'H10', 10),
(801, b'0', 'A1', 11),
(802, b'0', 'A2', 11),
(803, b'0', 'A3', 11),
(804, b'0', 'A4', 11),
(805, b'0', 'A5', 11),
(806, b'0', 'A6', 11),
(807, b'0', 'A7', 11),
(808, b'0', 'A8', 11),
(809, b'0', 'A9', 11),
(810, b'0', 'A10', 11),
(811, b'0', 'B1', 11),
(812, b'0', 'B2', 11),
(813, b'0', 'B3', 11),
(814, b'0', 'B4', 11),
(815, b'0', 'B5', 11),
(816, b'0', 'B6', 11),
(817, b'0', 'B7', 11),
(818, b'0', 'B8', 11),
(819, b'0', 'B9', 11),
(820, b'0', 'B10', 11),
(821, b'0', 'C1', 11),
(822, b'0', 'C2', 11),
(823, b'0', 'C3', 11),
(824, b'0', 'C4', 11),
(825, b'0', 'C5', 11),
(826, b'0', 'C6', 11),
(827, b'0', 'C7', 11),
(828, b'0', 'C8', 11),
(829, b'0', 'C9', 11),
(830, b'0', 'C10', 11),
(831, b'0', 'D1', 11),
(832, b'0', 'D2', 11),
(833, b'0', 'D3', 11),
(834, b'0', 'D4', 11),
(835, b'0', 'D5', 11),
(836, b'0', 'D6', 11),
(837, b'0', 'D7', 11),
(838, b'0', 'D8', 11),
(839, b'0', 'D9', 11),
(840, b'0', 'D10', 11),
(841, b'0', 'E1', 11),
(842, b'0', 'E2', 11),
(843, b'0', 'E3', 11),
(844, b'0', 'E4', 11),
(845, b'0', 'E5', 11),
(846, b'0', 'E6', 11),
(847, b'0', 'E7', 11),
(848, b'0', 'E8', 11),
(849, b'0', 'E9', 11),
(850, b'0', 'E10', 11),
(851, b'0', 'F1', 11),
(852, b'0', 'F2', 11),
(853, b'0', 'F3', 11),
(854, b'0', 'F4', 11),
(855, b'0', 'F5', 11),
(856, b'0', 'F6', 11),
(857, b'0', 'F7', 11),
(858, b'0', 'F8', 11),
(859, b'0', 'F9', 11),
(860, b'0', 'F10', 11),
(861, b'0', 'G1', 11),
(862, b'0', 'G2', 11),
(863, b'0', 'G3', 11),
(864, b'0', 'G4', 11),
(865, b'0', 'G5', 11),
(866, b'0', 'G6', 11),
(867, b'0', 'G7', 11),
(868, b'0', 'G8', 11),
(869, b'0', 'G9', 11),
(870, b'0', 'G10', 11),
(871, b'0', 'H1', 11),
(872, b'0', 'H2', 11),
(873, b'0', 'H3', 11),
(874, b'0', 'H4', 11),
(875, b'0', 'H5', 11),
(876, b'0', 'H6', 11),
(877, b'0', 'H7', 11),
(878, b'0', 'H8', 11),
(879, b'0', 'H9', 11),
(880, b'0', 'H10', 11),
(881, b'0', 'A1', 12),
(882, b'0', 'A2', 12),
(883, b'0', 'A3', 12),
(884, b'0', 'A4', 12),
(885, b'0', 'A5', 12),
(886, b'0', 'A6', 12),
(887, b'0', 'A7', 12),
(888, b'0', 'A8', 12),
(889, b'0', 'A9', 12),
(890, b'0', 'A10', 12),
(891, b'0', 'B1', 12),
(892, b'0', 'B2', 12),
(893, b'0', 'B3', 12),
(894, b'0', 'B4', 12),
(895, b'0', 'B5', 12),
(896, b'0', 'B6', 12),
(897, b'0', 'B7', 12),
(898, b'0', 'B8', 12),
(899, b'0', 'B9', 12),
(900, b'0', 'B10', 12),
(901, b'0', 'C1', 12),
(902, b'0', 'C2', 12),
(903, b'0', 'C3', 12),
(904, b'0', 'C4', 12),
(905, b'0', 'C5', 12),
(906, b'0', 'C6', 12),
(907, b'0', 'C7', 12),
(908, b'0', 'C8', 12),
(909, b'0', 'C9', 12),
(910, b'0', 'C10', 12),
(911, b'0', 'D1', 12),
(912, b'0', 'D2', 12),
(913, b'0', 'D3', 12),
(914, b'0', 'D4', 12),
(915, b'0', 'D5', 12),
(916, b'0', 'D6', 12),
(917, b'0', 'D7', 12),
(918, b'0', 'D8', 12),
(919, b'0', 'D9', 12),
(920, b'0', 'D10', 12),
(921, b'0', 'E1', 12),
(922, b'0', 'E2', 12),
(923, b'0', 'E3', 12),
(924, b'0', 'E4', 12),
(925, b'0', 'E5', 12),
(926, b'0', 'E6', 12),
(927, b'0', 'E7', 12),
(928, b'0', 'E8', 12),
(929, b'0', 'E9', 12),
(930, b'0', 'E10', 12),
(931, b'0', 'F1', 12),
(932, b'0', 'F2', 12),
(933, b'0', 'F3', 12),
(934, b'0', 'F4', 12),
(935, b'0', 'F5', 12),
(936, b'0', 'F6', 12),
(937, b'0', 'F7', 12),
(938, b'0', 'F8', 12),
(939, b'0', 'F9', 12),
(940, b'0', 'F10', 12),
(941, b'0', 'G1', 12),
(942, b'0', 'G2', 12),
(943, b'0', 'G3', 12),
(944, b'0', 'G4', 12),
(945, b'0', 'G5', 12),
(946, b'0', 'G6', 12),
(947, b'0', 'G7', 12),
(948, b'0', 'G8', 12),
(949, b'0', 'G9', 12),
(950, b'0', 'G10', 12),
(951, b'0', 'H1', 12),
(952, b'0', 'H2', 12),
(953, b'0', 'H3', 12),
(954, b'0', 'H4', 12),
(955, b'0', 'H5', 12),
(956, b'0', 'H6', 12),
(957, b'0', 'H7', 12),
(958, b'0', 'H8', 12),
(959, b'0', 'H9', 12),
(960, b'0', 'H10', 12);

-- --------------------------------------------------------

--
-- Table structure for table `tickets`
--

CREATE TABLE `tickets` (
  `ticket_id` int(11) NOT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `ticket_code` varchar(255) DEFAULT NULL,
  `seat_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tickets`
--

INSERT INTO `tickets` (`ticket_id`, `booking_id`, `ticket_code`, `seat_id`) VALUES
(1, 1, 'TIX-A5838A22', 37),
(2, 1, 'TIX-4DF7F5AA', 38);

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
('CUSTOMER', 2, 'arin@gmail.com', 'arin', 'arin123', 0),
('CUSTOMER', 3, 'sitialqia@gmail.com', 'qia', 'qia123', 0);

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
  ADD UNIQUE KEY `uk_booking_seat` (`booking_id`,`seat_id`),
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
  ADD UNIQUE KEY `uk_schedule_seat` (`schedule_id`,`seat_number`),
  ADD KEY `FKfbw4qi0nr80b7o8kpb25gy2q7` (`schedule_id`);

--
-- Indexes for table `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`ticket_id`),
  ADD KEY `FK1f6n3pv4b80wl6gj4ra32ctxk` (`seat_id`),
  ADD KEY `idx_tickets_booking_id` (`booking_id`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `movies`
--
ALTER TABLE `movies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `schedules`
--
ALTER TABLE `schedules`
  MODIFY `schedule_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `seats`
--
ALTER TABLE `seats`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=961;

--
-- AUTO_INCREMENT for table `tickets`
--
ALTER TABLE `tickets`
  MODIFY `ticket_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `transaction_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

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
  ADD CONSTRAINT `FK1f6n3pv4b80wl6gj4ra32ctxk` FOREIGN KEY (`seat_id`) REFERENCES `seats` (`id`),
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

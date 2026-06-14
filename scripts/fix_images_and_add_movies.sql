-- Fix ALL existing movie poster URLs to use TMDb (which allows hotlinking)
UPDATE movies SET image_url='https://image.tmdb.org/t/p/w500/or06FN3Dka5tlukNl9oJqRganFJ.jpg', status='Now Showing' WHERE id=1;  -- Avengers Endgame
UPDATE movies SET image_url='https://image.tmdb.org/t/p/w500/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg', status='Now Showing' WHERE id=2;  -- Spider-Man NWH
UPDATE movies SET image_url='https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911BTUgMe1nNaD3.jpg', status='Now Showing' WHERE id=3;  -- Dark Knight
UPDATE movies SET image_url='https://image.tmdb.org/t/p/w500/vZloFAK7NmvMGKE7LsyBGSCw8Ed.jpg', status='Now Showing' WHERE id=4;  -- John Wick 4
UPDATE movies SET image_url='https://image.tmdb.org/t/p/w500/ljsZTbVsrQSqZgWeep2B1QiDKuh.jpg', status='Now Showing' WHERE id=20; -- Inception
UPDATE movies SET image_url='https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg', status='Now Showing' WHERE id=21; -- Interstellar
UPDATE movies SET image_url='https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg', status='Now Showing' WHERE id=22; -- The Matrix
UPDATE movies SET image_url='https://image.tmdb.org/t/p/w500/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg', status='Now Showing' WHERE id=23; -- Deadpool & Wolverine
UPDATE movies SET image_url='https://image.tmdb.org/t/p/w500/8b8R8l88Qje9dn9OE8PY05Nez7S.jpg', status='Now Showing' WHERE id=24; -- Dune Part Two
UPDATE movies SET image_url='https://image.tmdb.org/t/p/w500/aciP8Km0wezdMfN8it7Th2UaTfR.jpg', status='Coming Soon' WHERE id=25; -- Joker 2
UPDATE movies SET image_url='https://image.tmdb.org/t/p/w500/2cxhvwyEwRlysAmRH4iodkvo0z5.jpg', status='Coming Soon' WHERE id=26; -- Gladiator II
UPDATE movies SET image_url='https://image.tmdb.org/t/p/w500/pzIddUEMWhWzfvLI3TwxUG2wGoi.jpg', status='Coming Soon' WHERE id=27; -- Captain America BNW
UPDATE movies SET image_url='https://image.tmdb.org/t/p/w500/z1FEhmApik0TNSzWF3iNGoXz8mv.jpg', status='Coming Soon' WHERE id=28; -- Mission Impossible
UPDATE movies SET image_url='https://image.tmdb.org/t/p/w500/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg', status='Coming Soon' WHERE id=29; -- Inside Out 2

-- Add more Now Showing movies
INSERT INTO `movies` (`duration`, `genre`, `price`, `synopsis`, `title`, `image_url`, `status`) VALUES
(152, 'Action / Sci-Fi', 55000, 'The Guardians must fight to protect the universe once more.', 'GUARDIANS OF THE GALAXY VOL. 3', 'https://image.tmdb.org/t/p/w500/r2J02Z2OpNTctfOSN1Ydgii51I3.jpg', 'Now Showing'),
(169, 'Action / Sci-Fi', 55000, 'Furiosa joins forces with the Praetorian Jack as they plot multi-year revenge against the Warlord.', 'FURIOSA: A MAD MAX SAGA', 'https://image.tmdb.org/t/p/w500/iADOJ8Zymht2JPMoy3R7xceZprc.jpg', 'Now Showing'),
(127, 'Animation / Adventure', 45000, 'Simba idolizes his father and takes on his own legacy.', 'THE LION KING', 'https://image.tmdb.org/t/p/w500/sKCr78MXSLixwmZ8DyJLrpMsd15.jpg', 'Now Showing'),
(130, 'Action / Sci-Fi', 50000, 'A blade runner discovers a long-buried secret that has the potential to plunge society into chaos.', 'BLADE RUNNER 2049', 'https://image.tmdb.org/t/p/w500/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg', 'Now Showing'),
(121, 'Sci-Fi / Adventure', 50000, 'A group of explorers travel through a wormhole near Saturn in search of a new home for humanity.', 'THE MARTIAN', 'https://image.tmdb.org/t/p/w500/5BHuvQ6p9kfc091Z8RiFNhCwL4b.jpg', 'Now Showing'),
(156, 'Drama / Crime', 50000, 'The aging patriarch of an organized crime dynasty transfers control to his reluctant youngest son.', 'THE GODFATHER', 'https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsRolD1fZdja1.jpg', 'Now Showing'),
(142, 'Drama / Thriller', 50000, 'An insomniac office worker and a devil-may-care soap maker form an underground fight club.', 'FIGHT CLUB', 'https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg', 'Now Showing');

-- Add more Coming Soon movies
INSERT INTO `movies` (`duration`, `genre`, `price`, `synopsis`, `title`, `image_url`, `status`) VALUES
(120, 'Sci-Fi / Action', 55000, 'The epic conclusion to the new Star Wars sequel saga.', 'THUNDERBOLTS', 'https://image.tmdb.org/t/p/w500/t4gFMVmr1HERLoqAqzawB6gcaRO.jpg', 'Coming Soon'),
(135, 'Action / Adventure', 55000, 'Katniss Everdeen becomes the symbol of rebellion against the Capitol in the new era.', 'THE FANTASTIC FOUR: FIRST STEPS', 'https://image.tmdb.org/t/p/w500/x2MjNrn74MhEPHaE9pOsXcaEyp8.jpg', 'Coming Soon'),
(140, 'Horror / Thriller', 50000, 'A group of friends discover an ancient evil lurking beneath their hometown.', 'A MINECRAFT MOVIE', 'https://image.tmdb.org/t/p/w500/iPaJAj0MEpp7e0bBjJOD1dhEB7L.jpg', 'Coming Soon'),
(115, 'Animation / Family', 45000, 'A young robot discovers what it means to be alive in a world of machines.', 'ELIO', 'https://image.tmdb.org/t/p/w500/hfjsMPHsjRiCCi2JOQrrKOBNqMN.jpg', 'Coming Soon'),
(125, 'Comedy / Action', 50000, 'A mismatched duo must team up to save the world from an unlikely threat.', 'LILO & STITCH', 'https://image.tmdb.org/t/p/w500/2fay2dGOWqKEflAOWKBqKCOUF4g.jpg', 'Coming Soon'),
(148, 'Drama / War', 55000, 'A soldier navigates the complexities of modern warfare in an unforgettable journey.', 'JURASSIC WORLD REBIRTH', 'https://image.tmdb.org/t/p/w500/dBiEUGOWTMkliyrRKUDsHBVmzmW.jpg', 'Coming Soon'),
(130, 'Thriller / Mystery', 50000, 'A detective uncovers a web of lies in a seemingly perfect small town.', 'SUPERMAN', 'https://image.tmdb.org/t/p/w500/rOmUuQEZfPXglwFs5ELLLUDKodL.jpg', 'Coming Soon');

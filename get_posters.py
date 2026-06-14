import urllib.request
import json
import time

movies = [
    "AVENGERS: ENDGAME", "SPIDER-MAN: NO WAY HOME", "BATMAN: THE DARK KNIGHT", "JOHN WICK 4",
    "INCEPTION", "INTERSTELLAR", "THE MATRIX", "DEADPOOL & WOLVERINE", "DUNE: PART TWO",
    "JOKER: FOLIE À DEUX", "GLADIATOR II", "CAPTAIN AMERICA: BRAVE NEW WORLD",
    "MISSION: IMPOSSIBLE 8", "INSIDE OUT 2", "GUARDIANS OF THE GALAXY VOL. 3",
    "FURIOSA: A MAD MAX SAGA", "THE LION KING", "BLADE RUNNER 2049", "THE MARTIAN",
    "THE GODFATHER", "FIGHT CLUB", "THUNDERBOLTS", "THE FANTASTIC FOUR: FIRST STEPS",
    "A MINECRAFT MOVIE", "ELIO", "LILO & STITCH", "JURASSIC WORLD REBIRTH", "SUPERMAN"
]

try:
    from duckduckgo_search import DDGS
    ddgs = DDGS()
except Exception:
    ddgs = None

result_map = {}

for m in movies:
    print(f"Searching for {m}...")
    try:
        if ddgs:
            results = ddgs.images(f"{m} movie poster", max_results=1)
            if results:
                url = results[0]['image']
                result_map[m] = url
                print(url)
                time.sleep(1)
                continue
    except Exception as e:
        pass
    
    result_map[m] = "https://placehold.co/600x900/1a1a1a/FFFFFF/png?text=" + m.replace(" ", "+")
    print(result_map[m])

print("DONE")
with open("movie_urls.txt", "w") as f:
    for k, v in result_map.items():
        f.write(f'"{k}": "{v}",\n')

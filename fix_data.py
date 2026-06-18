import urllib.request
import urllib.error
import json
import datetime

BASE_URL = "http://localhost:8081/api/admin"

def request(url, method="GET", data=None):
    req = urllib.request.Request(url, method=method)
    if data:
        req.add_header('Content-Type', 'application/json')
        jsondata = json.dumps(data)
        jsondataasbytes = jsondata.encode('utf-8')
        req.add_header('Content-Length', len(jsondataasbytes))
        try:
            response = urllib.request.urlopen(req, jsondataasbytes)
            return json.loads(response.read())
        except Exception as e:
            print(f"Error {method} {url}: {e}")
            return None
    else:
        try:
            response = urllib.request.urlopen(req)
            return json.loads(response.read())
        except Exception as e:
            print(f"Error {method} {url}: {e}")
            return None

movies = request(f"{BASE_URL}/movies")
schedules = request(f"{BASE_URL}/schedules")

movie_has_schedule = set()
if schedules:
    for s in schedules:
        if s.get("movie"):
            movie_has_schedule.add(s["movie"]["id"])

if movies:
    for m in movies:
        update_needed = False
        
        # Fix Interstellar image if broken
        if m["title"] == "Interstellar":
            m["imageUrl"] = "https://image.tmdb.org/t/p/w500/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg"
            update_needed = True
            
        # Fix Avengers
        if "AVENGERS" in m["title"].upper() and (not m.get("imageUrl") or "file:" in m.get("imageUrl", "")):
            m["imageUrl"] = "https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg"
            update_needed = True
            
        # Fix LEGO Batman
        if "LEGO" in m["title"].upper() and (not m.get("imageUrl") or "file:" in m.get("imageUrl", "")):
            m["imageUrl"] = "https://image.tmdb.org/t/p/w500/snGwr2gag4Fcgx2zGQxgjtxcprG.jpg"
            update_needed = True

        if not m.get("imageUrl") or m.get("imageUrl") == "" or "file:" in m.get("imageUrl", ""):
            # Generic image fallback
            m["imageUrl"] = "https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg"
            update_needed = True

        if update_needed:
            request(f"{BASE_URL}/movies/{m['id']}", method="PUT", data=m)

        # Add schedule if missing
        if m["id"] not in movie_has_schedule and m.get("status") != "Coming Soon":
            new_schedule = {
                "movie": {"id": m["id"]},
                "date": "2026-06-20",
                "time": "19:00",
                "hall": "Studio 1"
            }
            request(f"{BASE_URL}/schedules", method="POST", data=new_schedule)

coming_soon_movies = [
    {"title": "Deadpool & Wolverine", "genre": "Action", "duration": 127, "synopsis": "Wolverine is recovering from his injuries when he crosses paths with the loudmouth, Deadpool. They team up to defeat a common enemy.", "price": 50000, "imageUrl": "https://image.tmdb.org/t/p/w500/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg", "status": "Coming Soon"},
    {"title": "Inside Out 2", "genre": "Animation", "duration": 96, "synopsis": "Teenager Riley's mind headquarters is undergoing a sudden demolition to make room for something entirely unexpected: new Emotions! Joy, Sadness, Anger, Fear and Disgust, who’ve long been running a successful operation by all accounts, aren’t sure how to feel when Anxiety shows up. And it looks like she’s not alone.", "price": 40000, "imageUrl": "https://image.tmdb.org/t/p/w500/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg", "status": "Coming Soon"},
    {"title": "Gladiator II", "genre": "Action", "duration": 150, "synopsis": "Years after witnessing the death of the revered hero Maximus at the hands of his uncle, Lucius is forced to enter the Colosseum after his home is conquered by the tyrannical Emperors who now lead Rome with an iron fist.", "price": 60000, "imageUrl": "https://image.tmdb.org/t/p/w500/2cxhvwyEwRlysAmRH4iodkvo0z5.jpg", "status": "Coming Soon"},
    {"title": "Kingdom of the Planet of the Apes", "genre": "Action", "duration": 145, "synopsis": "Several generations in the future following Caesar's reign, apes are now the dominant species and live harmoniously while humans have been reduced to living in the shadows.", "price": 55000, "imageUrl": "https://image.tmdb.org/t/p/w500/gKkl37BQuKTanygYQG1pyYgLVgf.jpg", "status": "Coming Soon"}
]

for cs in coming_soon_movies:
    request(f"{BASE_URL}/movies", method="POST", data=cs)

print("Done fixing movies, adding schedules, and adding coming soon movies!")

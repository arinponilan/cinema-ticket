import json

def run():
    with open('movies.json', 'r') as f:
        movies = json.load(f)

    with open('generate_updates.sh', 'w') as out:
        out.write("#!/bin/bash\n")
        
        for m in movies:
            update = False
            img = m.get('imageUrl', '')
            
            if "AVENGERS" in m["title"].upper():
                m["imageUrl"] = "https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg"
                update = True
            elif "LEGO" in m["title"].upper():
                m["imageUrl"] = "https://image.tmdb.org/t/p/w500/snGwr2gag4Fcgx2zGQxgjtxcprG.jpg"
                update = True
            elif "INTERSTELLAR" in m["title"].upper():
                m["imageUrl"] = "https://image.tmdb.org/t/p/w500/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg"
                update = True
            elif not img or img.startswith('file:'):
                m["imageUrl"] = "https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg"
                update = True
                
            if update:
                js = json.dumps(m).replace("'", "'\\''")
                out.write(f"curl -s -X PUT http://localhost:8081/api/admin/movies/{m['id']} -H 'Content-Type: application/json' -d '{js}' > /dev/null\n")
                
            # Add schedule for everyone but Coming Soon
            if m.get("status") != "Coming Soon":
                sched = {
                    "movie": {"id": m["id"]},
                    "date": "2026-06-20",
                    "time": "19:00",
                    "hall": "Studio 1"
                }
                sj = json.dumps(sched).replace("'", "'\\''")
                out.write(f"curl -s -X POST http://localhost:8081/api/admin/schedules -H 'Content-Type: application/json' -d '{sj}' > /dev/null\n")
                
        # Add coming soon movies
        cs1 = {"title": "Deadpool & Wolverine", "genre": "Action", "duration": 127, "synopsis": "Wolverine is recovering from his injuries when he crosses paths with the loudmouth, Deadpool.", "price": 50000, "imageUrl": "https://image.tmdb.org/t/p/w500/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg", "status": "Coming Soon"}
        cs2 = {"title": "Inside Out 2", "genre": "Animation", "duration": 96, "synopsis": "Teenager Riley's mind headquarters is undergoing a sudden demolition.", "price": 40000, "imageUrl": "https://image.tmdb.org/t/p/w500/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg", "status": "Coming Soon"}
        cs3 = {"title": "Gladiator II", "genre": "Action", "duration": 150, "synopsis": "Years after witnessing the death of the revered hero Maximus.", "price": 60000, "imageUrl": "https://image.tmdb.org/t/p/w500/2cxhvwyEwRlysAmRH4iodkvo0z5.jpg", "status": "Coming Soon"}
        
        for cs in [cs1, cs2, cs3]:
            js = json.dumps(cs).replace("'", "'\\''")
            out.write(f"curl -s -X POST http://localhost:8081/api/admin/movies -H 'Content-Type: application/json' -d '{js}' > /dev/null\n")

if __name__ == '__main__':
    run()

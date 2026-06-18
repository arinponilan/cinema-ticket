import urllib.request
import json

BASE_URL_MOVIES = 'http://localhost:8081/api/admin/movies'
BASE_URL_SCHEDULES = 'http://localhost:8081/api/admin/schedules'

def get_movies():
    req = urllib.request.Request(BASE_URL_MOVIES, method='GET')
    with urllib.request.urlopen(req) as response:
        return json.loads(response.read().decode())

def create_schedules(movies):
    studios = ["Studio 1", "Studio 2", "Studio 3", "Studio 4", "Studio 5"]
    times = ["10:00", "13:00", "16:00", "19:00", "22:00"]
    
    slots = []
    for s in studios:
        for t in times:
            slots.append((s, t))
            
    # Assign one slot to each movie
    for i, movie in enumerate(movies):
        if i < len(slots):
            studio, time = slots[i]
            schedule_data = {
                "movie": {"id": movie["id"]},
                "hall": studio,
                "time": time,
                "date": "2026-06-16",
                "format": "Reguler 2D"
            }
            data = json.dumps(schedule_data).encode('utf-8')
            req = urllib.request.Request(BASE_URL_SCHEDULES, data=data, headers={'Content-Type': 'application/json'})
            try:
                urllib.request.urlopen(req)
                print(f"Created schedule for {movie['title']} at {studio} {time}")
            except Exception as e:
                print(f"Error creating schedule for {movie['title']}: {e}")

if __name__ == '__main__':
    movies = get_movies()
    create_schedules(movies)

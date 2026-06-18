import urllib.request
import json

BASE_URL_MOVIES = "http://localhost:8082/api/admin/movies"

def update_movie_image():
    try:
        req = urllib.request.Request(BASE_URL_MOVIES)
        with urllib.request.urlopen(req) as res:
            movies = json.loads(res.read().decode())
            
        transformers = None
        for m in movies:
            if m["title"] == "Transformers One":
                transformers = m
                break
                
        if not transformers:
            print("Could not find movie 'Transformers One' in the database!")
            return
            
        movie_id = transformers["id"]
        print(f"Found Transformers One with ID {movie_id}")
        
        # Update the image URL to local upload URL
        local_url = f"http://localhost:8082/uploads/transformers_one.jpg"
        
        # Prepare the update payload
        payload = {
            "title": transformers["title"],
            "code": transformers.get("code", "TFONE"),
            "genre": transformers["genre"],
            "duration": transformers["duration"],
            "synopsis": transformers["synopsis"],
            "price": transformers["price"],
            "imageUrl": local_url,
            "status": transformers.get("status", "Now Showing")
        }
        
        put_url = f"{BASE_URL_MOVIES}/{movie_id}"
        print(f"Updating movie {movie_id} image URL to {local_url} via PUT {put_url}...")
        
        data = json.dumps(payload).encode('utf-8')
        put_req = urllib.request.Request(
            put_url, 
            data=data, 
            headers={'Content-Type': 'application/json'},
            method='PUT'
        )
        with urllib.request.urlopen(put_req) as res:
            resp = json.loads(res.read().decode())
            print(f"Update response status: SUCCESS. New Image URL: {resp.get('imageUrl')}")
            
    except Exception as e:
        print(f"Failed to update movie image in database: {e}")

if __name__ == '__main__':
    update_movie_image()

import json
import urllib.request

urls = {
    "Dune: Part Two": "https://upload.wikimedia.org/wikipedia/en/5/52/Dune_Part_Two_poster.jpeg",
    "Deadpool & Wolverine": "https://upload.wikimedia.org/wikipedia/en/4/4c/Deadpool_%26_Wolverine_poster.jpg",
    "Inside Out 2": "https://upload.wikimedia.org/wikipedia/en/f/f7/Inside_Out_2_poster.jpg",
    "Transformers One": "https://upload.wikimedia.org/wikipedia/en/a/a4/Transformers_One_Official_Poster.jpg",
    "Godzilla x Kong: The New Empire": "https://upload.wikimedia.org/wikipedia/en/b/be/Godzilla_x_kong_the_new_empire_poster.jpg",
    "Kung Fu Panda 4": "https://upload.wikimedia.org/wikipedia/en/7/7f/Kung_Fu_Panda_4_poster.jpg",
    "Mission: Impossible - Dead Reckoning": "https://upload.wikimedia.org/wikipedia/en/e/ed/Mission-_Impossible_%E2%80%93_Dead_Reckoning_Part_One_poster.jpg",
    "Avatar: The Way of Water": "https://upload.wikimedia.org/wikipedia/en/5/54/Avatar_The_Way_of_Water_poster.jpg",
    "Mufasa: The Lion King": "https://upload.wikimedia.org/wikipedia/en/0/0b/Mufasa_The_Lion_King_Movie_2024.jpeg",
    "Joker: Folie à Deux": "https://upload.wikimedia.org/wikipedia/en/e/e8/Joker_-_Folie_%C3%A0_Deux_poster.jpg",
    "Venom: The Last Dance": "https://upload.wikimedia.org/wikipedia/en/a/a3/Venom_The_Last_Dance_Poster.jpg",
    "Gladiator II": "https://upload.wikimedia.org/wikipedia/en/0/04/Gladiator_II_%282024%29_poster.jpg",
    "Kraven the Hunter": "https://upload.wikimedia.org/wikipedia/en/e/ec/Kraven_the_Hunter_%28film%29_poster.jpg",
    "Oppenheimer": "https://m.media-amazon.com/images/M/MV5BMDBmYTZjNjUtN2M1MS00MTQ2LTk2ODgtNzc2M2QyZGE5NTVjXkEyXkFqcGdeQXVyNzAwMjU2MTY@._V1_FMjpg_UX1000_.jpg",
    "The Batman": "https://m.media-amazon.com/images/M/MV5BMDExZGMyOTMtMDgyYi00NGIwLWJhMTEtOTdkZGFjNmZiMTEwXkEyXkFqcGdeQXVyMjM4NTM5NDY@._V1_FMjpg_UX1000_.jpg",
}

# 1. Get all movies
req = urllib.request.Request("http://localhost:8081/api/admin/movies")
with urllib.request.urlopen(req) as response:
    movies = json.loads(response.read().decode())

# 2. Update via PUT
for movie in movies:
    title = movie['title']
    if title in urls:
        movie['imgUrl'] = urls[title]
        
        # PUT request
        put_req = urllib.request.Request(
            f"http://localhost:8081/api/admin/movies/{movie['id']}",
            data=json.dumps(movie).encode('utf-8'),
            headers={'Content-Type': 'application/json'},
            method='PUT'
        )
        try:
            with urllib.request.urlopen(put_req) as res:
                print(f"Updated {title}")
        except Exception as e:
            print(f"Failed to update {title}: {e}")

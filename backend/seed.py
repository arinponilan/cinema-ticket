import urllib.request
import json
import time

BASE_URL = 'http://localhost:8081/api/admin/movies'

def delete_all_movies():
    req = urllib.request.Request(BASE_URL, method='GET')
    try:
        with urllib.request.urlopen(req) as response:
            movies = json.loads(response.read().decode())
            for movie in movies:
                movie_id = movie['id']
                print(f"Deleting movie {movie_id}")
                del_req = urllib.request.Request(f"{BASE_URL}/{movie_id}", method='DELETE')
                urllib.request.urlopen(del_req)
                time.sleep(0.1)
    except Exception as e:
        print(f"Error fetching/deleting movies: {e}")

def create_movies():
    movies = [
        # 10 Now Showing
        {"title": "Dune: Part Two", "genre": "SCI-FI / ADVENTURE", "duration": 166, "synopsis": "Paul Atreides unites with Chani and the Fremen while on a warpath of revenge against the conspirators who destroyed his family.", "price": 50000, "status": "Now Showing", "code": "DUNE2", "imageUrl": "https://m.media-amazon.com/images/M/MV5BODE2OTIxMTAwOF5BMl5BanBnXkFtZTgwNTU1MDI3OTM@._V1_FMjpg_UX1000_.jpg"},
        {"title": "Oppenheimer", "genre": "DRAMA / HISTORY", "duration": 180, "synopsis": "The story of American scientist J. Robert Oppenheimer and his role in the development of the atomic bomb.", "price": 45000, "status": "Now Showing", "code": "OPPEN", "imageUrl": "https://m.media-amazon.com/images/M/MV5BMDBmYTZjNjUtN2M1MS00MTQ2LTk2ODgtNzc2M2QyZGE5NTVjXkEyXkFqcGdeQXVyNzAwMjU2MTY@._V1_FMjpg_UX1000_.jpg"},
        {"title": "The Batman", "genre": "ACTION / CRIME", "duration": 176, "synopsis": "When a sadistic serial killer begins murdering key political figures in Gotham, Batman is forced to investigate the city's hidden corruption and question his family's involvement.", "price": 45000, "status": "Now Showing", "code": "BATMAN", "imageUrl": "https://m.media-amazon.com/images/M/MV5BMDExZGMyOTMtMDgyYi00NGIwLWJhMTEtOTdkZGFjNmZiMTEwXkEyXkFqcGdeQXVyMjM4NTM5NDY@._V1_FMjpg_UX1000_.jpg"},
        {"title": "Deadpool & Wolverine", "genre": "ACTION / COMEDY", "duration": 127, "synopsis": "Wolverine is recovering from his injuries when he crosses paths with the loudmouth, Deadpool. They team up to defeat a common enemy.", "price": 55000, "status": "Now Showing", "code": "DPWOL", "imageUrl": "https://m.media-amazon.com/images/M/MV5BNzRiMjg0MzUtNTQ1Mi00Y2Q5LWEwM2MtMzUwZDVjNjQwZmNiXkEyXkFqcGdeQXVyMDM2NDM2MQ@@._V1_FMjpg_UX1000_.jpg"},
        {"title": "Inside Out 2", "genre": "ANIMATION / FAMILY", "duration": 96, "synopsis": "Follows Riley, in her teenage years, encountering new emotions.", "price": 40000, "status": "Now Showing", "code": "IO2", "imageUrl": "https://m.media-amazon.com/images/M/MV5BZDQwZTVjYjctYzY4NC00ZGQ5LWEwNWYtNzg5YTgwZDg1ODhhXkEyXkFqcGdeQXVyMTAwOTI5MDk3._V1_FMjpg_UX1000_.jpg"},
        {"title": "Transformers One", "genre": "ANIMATION / ACTION", "duration": 104, "synopsis": "The untold origin story of Optimus Prime and Megatron, better known as sworn enemies, but once were friends bonded like brothers who changed the fate of Cybertron forever.", "price": 40000, "status": "Now Showing", "code": "TFONE", "imageUrl": "https://m.media-amazon.com/images/M/MV5BOTE1ZTllNzMtNjA1MS00YTNjLWFhNTUtYTJiYjQyZDlhNjkzXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg"},
        {"title": "Godzilla x Kong: The New Empire", "genre": "ACTION / SCI-FI", "duration": 115, "synopsis": "Two ancient titans, Godzilla and Kong, clash in an epic battle as humans unravel their intertwined origins and connection to Skull Island's mysteries.", "price": 55000, "status": "Now Showing", "code": "GXK", "imageUrl": "https://m.media-amazon.com/images/M/MV5BYTJlNmRhYTktZDBlMy00MjNlLWE1OWEtOTJjZjJjYjZlMjQwXkEyXkFqcGdeQXVyMTA3MDk2NDg2._V1_FMjpg_UX1000_.jpg"},
        {"title": "Kung Fu Panda 4", "genre": "ANIMATION / COMEDY", "duration": 94, "synopsis": "After Po is tapped to become the Spiritual Leader of the Valley of Peace, he needs to find and train a new Dragon Warrior, while a wicked sorceress plans to re-summon all the master villains whom Po has vanquished to the spirit realm.", "price": 40000, "status": "Now Showing", "code": "KFP4", "imageUrl": "https://m.media-amazon.com/images/M/MV5BZDY0YzI0OTctYjVhYy00MTVhLWE0NTgtYTRmYTBmOTE3YTViXkEyXkFqcGdeQXVyMTUzMTg2ODkz._V1_FMjpg_UX1000_.jpg"},
        {"title": "Mission: Impossible - Dead Reckoning", "genre": "ACTION / THRILLER", "duration": 163, "synopsis": "Ethan Hunt and his IMF team must track down a dangerous weapon before it falls into the wrong hands.", "price": 55000, "status": "Now Showing", "code": "MI7", "imageUrl": "https://m.media-amazon.com/images/M/MV5BYzFiZjc1YzctMDY3Zi00NGE5LTlmNWEtN2Q3OWFjYjY1NGM2XkEyXkFqcGdeQXVyMTUyMTUzNjQ0._V1_FMjpg_UX1000_.jpg"},
        {"title": "Avatar: The Way of Water", "genre": "SCI-FI / FANTASY", "duration": 192, "synopsis": "Jake Sully lives with his newfound family formed on the extrasolar moon Pandora. Once a familiar threat returns to finish what was previously started, Jake must work with Neytiri and the army of the Na'vi race to protect their home.", "price": 60000, "status": "Now Showing", "code": "AVATAR2", "imageUrl": "https://m.media-amazon.com/images/M/MV5BYjhiNjBlODctY2ZiOC00YjVlLWFlNzAtNTVhNzM1YjI1NzMxXkEyXkFqcGdeQXVyMjQxNTE1MDA@._V1_FMjpg_UX1000_.jpg"},
        
        # 5 Coming Soon
        {"title": "Mufasa: The Lion King", "genre": "ANIMATION / ADVENTURE", "duration": 118, "synopsis": "Simba, having become king of the Pride Lands, is determined for his cub to follow in his paw prints while the origins of his late father Mufasa are explored.", "price": 40000, "status": "Coming Soon", "code": "MUFASA", "imageUrl": "https://m.media-amazon.com/images/M/MV5BMjA5OTU1NTQxOV5BMl5BanBnXkFtZTgwMDM2MzUyMTI@._V1_FMjpg_UX1000_.jpg"},
        {"title": "Joker: Folie à Deux", "genre": "DRAMA / THRILLER", "duration": 138, "synopsis": "Failed comedian Arthur Fleck meets the love of his life, Harley Quinn, while incarcerated at Arkham State Hospital.", "price": 50000, "status": "Coming Soon", "code": "JOKER2", "imageUrl": "https://m.media-amazon.com/images/M/MV5BOTEyZGVmNjktNTQwNC00MzU4LWI3MzktZmFhZGJlNDY3Y2FmXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg"},
        {"title": "Venom: The Last Dance", "genre": "ACTION / SCI-FI", "duration": 125, "synopsis": "Eddie and Venom are on the run. Hunted by both of their worlds and with the net closing in, the duo are forced into a devastating decision that will bring the curtains down on Venom and Eddie's last dance.", "price": 45000, "status": "Coming Soon", "code": "VENOM3", "imageUrl": "https://m.media-amazon.com/images/M/MV5BZDMyYWU4NzItZTBhMi00NjliLThvNjItYjhWNzFjNjg3YmYyXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg"},
        {"title": "Gladiator II", "genre": "ACTION / DRAMA", "duration": 145, "synopsis": "After his home is conquered by the tyrannical emperors who now lead Rome, Lucius is forced to enter the Colosseum and must look to his past to find strength to return the glory of Rome to its people.", "price": 55000, "status": "Coming Soon", "code": "GLAD2", "imageUrl": "https://m.media-amazon.com/images/M/MV5BYTJiNzBkNjUtOGU0YS00ZTBkLTgxZGEtNzNjZmJhNjAzMjVjXkEyXkFqcGdeQXVyMDM2NDM2MQ@@._V1_FMjpg_UX1000_.jpg"},
        {"title": "Kraven the Hunter", "genre": "ACTION / ADVENTURE", "duration": 127, "synopsis": "Russian immigrant Sergei Kravinoff is on a mission to prove that he is the greatest hunter in the world.", "price": 45000, "status": "Coming Soon", "code": "KRAVEN", "imageUrl": "https://m.media-amazon.com/images/M/MV5BMjY5NmM0ODctNjNlMy00MGU5LWFiYzEtNTBhOGJhYThmZDFiXkEyXkFqcGdeQXVyMDM2NDM2MQ@@._V1_FMjpg_UX1000_.jpg"}
    ]

    for m in movies:
        data = json.dumps(m).encode('utf-8')
        req = urllib.request.Request(BASE_URL, data=data, headers={'Content-Type': 'application/json'})
        try:
            with urllib.request.urlopen(req) as response:
                print(f"Created {m['title']}")
                time.sleep(0.1)
        except Exception as e:
            print(f"Error creating {m['title']}: {e}")

if __name__ == '__main__':
    delete_all_movies()
    create_movies()

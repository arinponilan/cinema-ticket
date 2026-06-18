import urllib.request
import json
import urllib.parse

def get_wiki_image(title):
    search_url = f"https://en.wikipedia.org/w/api.php?action=query&prop=pageimages&titles={urllib.parse.quote(title)}&pithumbsize=500&format=json"
    req = urllib.request.Request(search_url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            pages = data['query']['pages']
            for page_id, page_data in pages.items():
                if 'thumbnail' in page_data:
                    return page_data['thumbnail']['source']
    except Exception as e:
        pass
    return None

titles = ["Dune: Part Two", "Deadpool & Wolverine", "Inside Out 2", "Transformers One", "Godzilla x Kong: The New Empire", "Kung Fu Panda 4", "Mission: Impossible – Dead Reckoning Part One", "Avatar: The Way of Water", "Mufasa: The Lion King", "Joker: Folie à Deux", "Venom: The Last Dance", "Gladiator II", "Kraven the Hunter"]

for t in titles:
    img = get_wiki_image(t)
    print(f"{t}: {img}")

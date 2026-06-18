import urllib.request
import urllib.parse
import re
import ssl

titles = {
    "Dune2": "Dune: Part Two",
    "DPWOL": "Deadpool & Wolverine",
    "IO2": "Inside Out 2",
    "TFONE": "Transformers One",
    "GXK": "Godzilla x Kong: The New Empire",
    "KFP4": "Kung Fu Panda 4",
    "MI7": "Mission: Impossible – Dead Reckoning Part One",
    "AVATAR2": "Avatar: The Way of Water",
    "MUFASA": "Mufasa: The Lion King",
    "JOKER2": "Joker: Folie à Deux",
    "VENOM3": "Venom: The Last Dance",
    "GLAD2": "Gladiator II",
    "KRAVEN": "Kraven the Hunter (film)"
}

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

for code, title in titles.items():
    url = f"https://en.wikipedia.org/wiki/{urllib.parse.quote(title.replace(' ', '_'))}"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req, context=ctx) as response:
            html = response.read().decode('utf-8', errors='ignore')
            # Look for <meta property="og:image" content="...">
            match = re.search(r'<meta property="og:image" content="([^"]+)"', html)
            if match:
                img_url = match.group(1)
                print(f"{code}: {img_url}")
            else:
                print(f"{code}: No image found")
    except Exception as e:
        print(f"{code}: Error {e}")

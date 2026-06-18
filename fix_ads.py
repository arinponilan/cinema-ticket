import urllib.request
import json
import urllib.parse

def request(url, method="GET", data=None):
    req = urllib.request.Request(url, method=method)
    if data:
        req.add_header('Content-Type', 'application/json')
        jsondata = json.dumps(data)
        jsondataasbytes = jsondata.encode('utf-8')
        req.add_header('Content-Length', len(jsondataasbytes))
        response = urllib.request.urlopen(req, jsondataasbytes)
    else:
        response = urllib.request.urlopen(req)
    return json.loads(response.read())

def run():
    BASE = "http://localhost:8081/api/admin"
    
    # 1. Update Dune & LEGO
    movies = request(f"{BASE}/movies")
    for m in movies:
        update = False
        if "DUNE" in m["title"].upper():
            # Use another Dune poster
            m["imageUrl"] = "https://image.tmdb.org/t/p/w500/czembW0Rk1Ke7lCJGahbOhdCuhV.jpg"
            update = True
        elif "LEGO" in m["title"].upper():
            m["imageUrl"] = "https://image.tmdb.org/t/p/w500/snGwr2gag4Fcgx2zGQxgjtxcprG.jpg"
            update = True
            
        if update:
            print(f"Updating {m['title']}...")
            request(f"{BASE}/movies/{m['id']}", method="PUT", data=m)
            
    # 2. Add Promotions
    ads = [
        {"title": "Deadpool & Wolverine", "imageUrl": "https://image.tmdb.org/t/p/w1280/9l1eZiJHmhr5jIlthMdJN5WYoff.jpg", "linkUrl": "", "active": True, "sortOrder": 1},
        {"title": "Inside Out 2", "imageUrl": "https://image.tmdb.org/t/p/w1280/stKGOm8UyhuLPR9sZLjs5AkmncA.jpg", "linkUrl": "", "active": True, "sortOrder": 2},
        {"title": "Dune: Part Two", "imageUrl": "https://image.tmdb.org/t/p/w1280/8rpDcsfLJypbO6vtec0geA4T4z.jpg", "linkUrl": "", "active": True, "sortOrder": 3}
    ]
    
    for ad in ads:
        print(f"Adding Ad {ad['title']}...")
        # Since the backend uses /api/ads, but the python requests it via BASE, wait... The backend has @RequestMapping("/api/ads") on AdvertisementController, not /api/admin/ads.
        # Let's use http://localhost:8081/api/ads
        req = urllib.request.Request("http://localhost:8081/api/ads", method="POST")
        req.add_header('Content-Type', 'application/json')
        jsondata = json.dumps(ad).encode('utf-8')
        req.add_header('Content-Length', len(jsondata))
        urllib.request.urlopen(req, jsondata)
        
    print("All done!")

if __name__ == '__main__':
    run()

import json

INPUT = "assets/maps/izmir_regions_2geo.json"
OUTPUT = "assets/maps/izmir_regions_3geo_fixed.json"

ID_MAP = {
    "İZMİR-1": 201,
    "İZMİR-2": 202,
}

with open(INPUT, "r", encoding="utf-8") as f:
    data = json.load(f)

for feature in data["features"]:
    region_id = feature["properties"]["region_id"]
    feature["properties"]["id"] = ID_MAP[region_id]
    feature["properties"]["city"] = "izmir"

with open(OUTPUT, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("✔ İzmir ID fix tamamlandı:", OUTPUT)

import json

IST_ANK = "assets/maps/regions87_istanbul_ankara_fixed.geojson"
IZMIR = "assets/maps/izmir_regions_final.geojson"
OUTPUT = "assets/maps/regions87_all.geojson"

with open(IST_ANK, "r", encoding="utf-8") as f:
    all_data = json.load(f)

with open(IZMIR, "r", encoding="utf-8") as f:
    izmir = json.load(f)

# İzmir feature’larını ekle
all_data["features"].extend(izmir["features"])

with open(OUTPUT, "w", encoding="utf-8") as f:
    json.dump(all_data, f, ensure_ascii=False, indent=2)

print("✔ Tüm şehirler birleşti!")
print(f"✔ Çıktı: {OUTPUT}")

import json
from shapely.geometry import shape, mapping
from shapely.ops import unary_union

# ----------------------------------------------------------
# 1) GİRİŞ ve ÇIKIŞ DOSYA YOLLARI
# ----------------------------------------------------------

INPUT_FILE = "assets/maps/izmir_regions_2geo.json"
OUTPUT_FILE = "assets/maps/izmir_regions_3geo.json"

# ----------------------------------------------------------
# 2) BÖLGE LİSTELERİ (sabit)
# ----------------------------------------------------------

REGIONS = {
    "İZMİR-1": {
        "region_id": "İZMİR-1",
        "city": "izmir",
        "seats": 14
    },
    "İZMİR-2": {
        "region_id": "İZMİR-2",
        "city": "izmir",
        "seats": 14
    }
}

# ----------------------------------------------------------
# 3) DOSYAYI OKU
# ----------------------------------------------------------

with open(INPUT_FILE, "r", encoding="utf-8") as f:
    data = json.load(f)

# ----------------------------------------------------------
# 4) BÖLGELERE GÖRE İLÇELERİ TOPLA
# ----------------------------------------------------------

districts_by_region = {
    "İZMİR-1": [],
    "İZMİR-2": []
}

for feature in data["features"]:
    props = feature["properties"]
    region = props.get("region")

    if region in districts_by_region:
        geom = shape(feature["geometry"])
        districts_by_region[region].append(geom)

# ----------------------------------------------------------
# 5) POLYGON BİRLEŞTİRME (UNION)
# ----------------------------------------------------------

merged_features = []

for region_key, geom_list in districts_by_region.items():
    if not geom_list:
        continue

    merged_geom = unary_union(geom_list)
    # Geometriyi temizle – kritik fix
    merged_geom = merged_geom.buffer(0)
    merged_geom = merged_geom.simplify(0.0001, preserve_topology=True)


    merged_feature = {
        "type": "Feature",
        "properties": REGIONS[region_key],
        "geometry": mapping(merged_geom)
    }

    merged_features.append(merged_feature)

# ----------------------------------------------------------
# 6) ÇIKTI GEOJSON OLUŞTUR
# ----------------------------------------------------------

output_geojson = {
    "type": "FeatureCollection",
    "name": "izmir_regions_3geo",
    "crs": {
        "type": "name",
        "properties": {
            "name": "urn:ogc:def:crs:OGC:1.3:CRS84"
        }
    },
    "features": merged_features
}

# ----------------------------------------------------------
# 7) DOSYAYA YAZ
# ----------------------------------------------------------

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    json.dump(output_geojson, f, ensure_ascii=False, indent=2)

print("✔ İzmir bölge birleştirme tamamlandı!")
print(f"✔ Çıktı dosyası: {OUTPUT_FILE}")

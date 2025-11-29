import json
from shapely.geometry import shape, mapping
from shapely.ops import unary_union

# ============================================================
# 0) DOSYA TANIMLARI
# ============================================================

DISTRICTS_INPUT = "geo/izmir_districts.geojson"
FINAL_OUTPUT = "assets/maps/izmir_regions_final.geojson"

# ============================================================
# 1) İZMİR BÖLGE SÖZLÜĞÜ
# ============================================================

IZMIR_REGION_MAP = {
    # 1. Bölge
    "BALÇOVA": "İZMİR-1",
    "BUCA": "İZMİR-1",
    "GAZIEMIR": "İZMİR-1",
    "GÜZELBAHÇE": "İZMİR-1",
    "KARABAĞLAR": "İZMİR-1",
    "KARABURUN": "İZMİR-1",
    "KONAK": "İZMİR-1",
    "MENDERES": "İZMİR-1",
    "NARLIDERE": "İZMİR-1",
    "SEFERIHISAR": "İZMİR-1",
    "SELÇUK": "İZMİR-1",
    "TORBALI": "İZMİR-1",
    "URLA": "İZMİR-1",
    "ÇEŞME": "İZMİR-1",

    # 2. Bölge
    "ALIAĞA": "İZMİR-2",
    "BAYINDIR": "İZMİR-2",
    "BAYRAKLI": "İZMİR-2",
    "BERGAMA": "İZMİR-2",
    "BEYDAĞ": "İZMİR-2",
    "BORNOVA": "İZMİR-2",
    "DIKILI": "İZMİR-2",
    "FOÇA": "İZMİR-2",
    "KARŞIYAKA": "İZMİR-2",
    "KEMALPAŞA": "İZMİR-2",
    "KINIK": "İZMİR-2",
    "KIRAZ": "İZMİR-2",
    "MENEMEN": "İZMİR-2",
    "TIRE": "İZMİR-2",
    "ÇIĞLI": "İZMİR-2",
    "ÖDEMIŞ": "İZMİR-2",
}

IZMIR_IDS = {
    "İZMİR-1": 201,
    "İZMİR-2": 202,
}

# ============================================================
# 2) ADIM → İlçeleri oku + region ata
# ============================================================

print("→ İzmir ilçe verisi okunuyor...")

with open(DISTRICTS_INPUT, "r", encoding="utf-8") as f:
    districts = json.load(f)

# Yeni feature listesi
districts_with_region = {
    "type": "FeatureCollection",
    "features": []
}

for feature in districts["features"]:
    props = feature["properties"]

    ilce = (
        props.get("İlçe") or 
        props.get("ilce") or
        props.get("name") or ""
    )

    region = IZMIR_REGION_MAP.get(ilce.upper().strip(), None)
    props["region"] = region

    districts_with_region["features"].append(feature)

print("✔ İlçelere bölge atandı.")

# ============================================================
# 3) ADIM → Bölgeleri UNION ile birleştir
# ============================================================

print("→ Bölge poligonları birleştiriliyor...")

by_region = {"İZMİR-1": [], "İZMİR-2": []}

for feature in districts_with_region["features"]:
    region = feature["properties"].get("region")
    if region:
        by_region[region].append(shape(feature["geometry"]))

merged_features = []

for key, geom_list in by_region.items():
    if not geom_list:
        continue

    merged = unary_union(geom_list)

    # geometriyi düzeltme
    merged = merged.buffer(0)
    merged = merged.simplify(0.0001, preserve_topology=True)

    merged_features.append({
        "type": "Feature",
        "properties": {
            "region_id": key,
            "id": IZMIR_IDS[key],
            "city": "izmir",
            "seats": 14
        },
        "geometry": mapping(merged)
    })

print("✔ Tüm ilçeler bölge polygonlarında birleştirildi.")

# ============================================================
# 4) ADIM → Final GeoJSON’u Yaz
# ============================================================

final_output = {
    "type": "FeatureCollection",
    "name": "izmir_regions_final",
    "crs": {
        "type": "name",
        "properties": {"name": "urn:ogc:def:crs:OGC:1.3:CRS84"}
    },
    "features": merged_features
}

with open(FINAL_OUTPUT, "w", encoding="utf-8") as f:
    json.dump(final_output, f, ensure_ascii=False, indent=2)

print("✔ İzmir final harita oluşturuldu!")
print("✔ Çıktı dosyası:", FINAL_OUTPUT)

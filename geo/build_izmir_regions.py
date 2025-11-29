import json

INPUT_FILE = "geo/izmir_districts.geojson"
OUTPUT_FILE = "assets/maps/izmir_regions_2geo.json"

# --- İZMİR BÖLGE SÖZLÜĞÜ (upper() ile birebir aynı olacak!) ---
izmir_bolge_mapping = {
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

# --- 1) GİRİŞ DOSYASINI OKU ---
with open(INPUT_FILE, "r", encoding="utf-8") as f:
    data = json.load(f)

# --- 2) İLÇELERE 'region' EKLE ---
for feature in data["features"]:
    props = feature["properties"]

    # İlçe adını bul (farklı key isimlerine karşı dayanıklı)
    ilce = (
        props.get("İlçe")   # orijinal dosyadaki key
        or props.get("ilçe")
        or props.get("ilce")
        or props.get("name")
        or props.get("NAME")
        or ""
    )

    ilce_key = ilce.strip().upper()

    bolge = izmir_bolge_mapping.get(ilce_key, None)

    props["region"] = bolge

# --- 3) ÇIKTIYI YAZ ---
with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("✔ İzmir ilçe -> bölge mapping tamamlandı!")
print(f"✔ Çıktı: {OUTPUT_FILE}")

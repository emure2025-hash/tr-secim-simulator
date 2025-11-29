import json
import unicodedata

IST_ANK = "assets/maps/regions87_istanbul_ankara_fixed.geojson"
IZMIR = "assets/maps/izmir_regions_final.geojson"
OUTPUT = "assets/maps/regions87_all.geojson"

with open(IST_ANK, "r", encoding="utf-8") as f:
    all_data = json.load(f)

# İstanbul/Ankara entegre edilmiş dosyada zaten eski İzmir geometrileri var.
# Bozuk/duble geometri eklenmemesi için önce İzmir feature’larını temizleyip
# final İzmir dosyasındaki (doğru projeksiyonlu) halleri ekliyoruz.
with open(IZMIR, "r", encoding="utf-8") as f:
    izmir = json.load(f)


def _normalize(text) -> str:
    return str(text or "").strip()


def _fold_tr(text: str) -> str:
    """Turkçe karakterleri noktalama farklarından arındırarak katlar."""

    normalized = unicodedata.normalize("NFKD", text.casefold())
    return "".join(ch for ch in normalized if unicodedata.category(ch) != "Mn")


def _izmir_ids(feature_collection: dict) -> set[str]:
    """Final dosyadaki İzmir ID'lerini toplayıp eski kayıtları güvenle eşler."""

    ids: set[str] = set()
    for feature in feature_collection.get("features", []):
        feature_id = _normalize(feature.get("properties", {}).get("id")).upper()
        if feature_id:
            ids.add(feature_id)
    return ids


IZMIR_IDS = _izmir_ids(izmir)


# Eski İzmir bölgelerini (ID, şehir adı veya başlıktaki ibareye göre) çıkar
def _is_izmir(props: dict) -> bool:
    """
    Şehir adını Türkçe karakter duyarlı şekilde normalize edip İzmir'i yakalar.

    lower() yerine casefold() kullanarak "İzmir", "IZMIR" gibi varyantların tümünü
    temizlediğimizden emin oluruz. Ayrıca ID setini final dosyadan okuduğumuz için
    şehir ismi boş bırakılmış eski kayıtlar da elenir.
    """

    city = _fold_tr(_normalize(props.get("city")))
    name = _fold_tr(_normalize(props.get("name")))
    feature_id = _normalize(props.get("id")).upper()

    city_is_izmir = city == "izmir"
    name_mentions_izmir = "izmir" in name
    id_is_izmir = feature_id in IZMIR_IDS
    return city_is_izmir or name_mentions_izmir or id_is_izmir


all_data["features"] = [
    f for f in all_data["features"] if not _is_izmir(f.get("properties", {}))
]

# Şehir adı büyük harf uyumunu koru ve final İzmir geometrilerini ekle
for feature in izmir["features"]:
    props = feature.setdefault("properties", {})
    props["city"] = "İzmir"

all_data["features"].extend(izmir["features"])

with open(OUTPUT, "w", encoding="utf-8") as f:
    json.dump(all_data, f, ensure_ascii=False, indent=2)

print("✔ Tüm şehirler birleşti!")
print(f"✔ Çıktı: {OUTPUT}")

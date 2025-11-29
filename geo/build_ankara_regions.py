import geopandas as gpd
import unicodedata

def normalize_turkish(s):
    """Türkçe karakterleri normalize eder, eşleştirmeye hazırlar."""
    if not s:
        return ""
    s = unicodedata.normalize("NFKD", str(s))
    s = ''.join(c for c in s if not unicodedata.combining(c))
    s = s.strip().lower()

    table = {
        "ç": "c", "ğ": "g", "ı": "i",
        "ö": "o", "ş": "s", "ü": "u"
    }
    for tr, asc in table.items():
        s = s.replace(tr, asc)
    return s

# --- 1) Ankara ilçe GeoJSON'unu oku ---
FILE_IN = "geo/ankara_districts_fixed.geojson"
FILE_OUT = "geo/ankara_regions_3geo.json"

print(f"→ Dosya okunuyor: {FILE_IN}")
gdf = gpd.read_file(FILE_IN)

# İlçe adları
col_name = None
for c in gdf.columns:
    if "name" in c.lower():
        col_name = c
        break

if col_name is None:
    raise Exception("❌ İlçe isim kolonu bulunamadı. 'name' içeren bir kolon gerekli.")

gdf["ilce_norm"] = gdf[col_name].apply(normalize_turkish)

# --- 2) Ankara bölge mapping ---
district_to_region = {
    # --- 1. BÖLGE ---
    "bala": "ANKARA-1",
    "elmadağ": "ANKARA-1",
    "elmadag": "ANKARA-1",  # normalize yedeği
    "cankaya": "ANKARA-1",
    "golbasi": "ANKARA-1",
    "gölbaşi": "ANKARA-1",
    "evren": "ANKARA-1",
    "mamak": "ANKARA-1",
    "haymana": "ANKARA-1",
    "sereflikochisar": "ANKARA-1",
    "sereflikoçhisar": "ANKARA-1",  # yedek
    "polatli": "ANKARA-1",
    "polatlı": "ANKARA-1",

    # --- 2. BÖLGE ---
    "altindag": "ANKARA-2",
    "gudul": "ANKARA-2",
    "camlidere": "ANKARA-2",
    "kalecik": "ANKARA-2",
    "kecioren": "ANKARA-2",
    "kizilcahamam": "ANKARA-2",
    "kahramankazan": "ANKARA-2",
    "cubuk": "ANKARA-2",
    "pursaklar": "ANKARA-2",
    "akyurt": "ANKARA-2",

    # --- 3. BÖLGE ---
    "ayas": "ANKARA-3",
    "yenimahalle": "ANKARA-3",
    "beypazari": "ANKARA-3",
    "sincan": "ANKARA-3",
    "etimesgut": "ANKARA-3",
    "nallihan": "ANKARA-3",
}

# Normalize mapping
norm_mapping = {normalize_turkish(k): v for k, v in district_to_region.items()}

# Eşleştir
gdf["region_id"] = gdf["ilce_norm"].map(norm_mapping)

# --- 3) Eşleşmeyen ilçe var mı? ---
missing = gdf[gdf["region_id"].isna()]
if not missing.empty:
    print("\n⚠️  EŞLEŞMEYEN İLÇELER:")
    for _, row in missing.iterrows():
        print(" →", row[col_name], "(norm:", row["ilce_norm"], ")")
    raise SystemExit("❌ Mapping eksik — Yukarıdaki ilçeler eşleşmedi.")

print("\n✓ Tüm ilçeler başarıyla eşleştirildi!")

# --- 4) Dissolve ile 3 büyük bölge poligonu oluştur ---
regions = gdf.dissolve(by="region_id", as_index=False)

# Ek bilgiler
regions["city"] = "Ankara"
regions["seats"] = regions["region_id"].map({
    "ANKARA-1": 20,
    "ANKARA-2": 15,
    "ANKARA-3": 16,
})

# Çıktı kolon seçimi
regions = regions[["region_id", "city", "seats", "geometry"]]

# --- 5) GeoJSON olarak kaydet ---
regions.to_file(FILE_OUT, driver="GeoJSON")
print(f"\n✓ ÇIKTI OLUŞTURULDU: {FILE_OUT}")
print(f"Toplam bölge: {len(regions)}")

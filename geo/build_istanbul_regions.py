import geopandas as gpd
import unicodedata

def normalize_turkish(s):
    """Türkçe karakterleri normalize et ve karşılaştırmaya hazırla"""
    if s is None or s == "":
        return ""
    
    # Unicode normalization
    s = unicodedata.normalize('NFKD', str(s))
    s = ''.join(ch for ch in s if not unicodedata.combining(ch))
    
    # Boşlukları/özel karakterleri temizle
    s = s.strip().lower()
    
    # Türkçe karakterleri ASCII'ye çevir (eşleştirme için)
    tr_to_ascii = {
        'ç': 'c', 'ğ': 'g', 'ı': 'i', 'ö': 'o', 'ş': 's', 'ü': 'u',
        'Ç': 'c', 'Ğ': 'g', 'İ': 'i', 'Ö': 'o', 'Ş': 's', 'Ü': 'u'
    }
    for tr, ascii_ch in tr_to_ascii.items():
        s = s.replace(tr, ascii_ch)
    
    return s

# 1) İstanbul ilçe GeoJSON'unu oku
gdf = gpd.read_file("istanbul_districts.geojson")

print("Kolonlar:", gdf.columns.tolist())
print("\nİlk ilçeler:")
print(gdf.head()[["name"]])

# İlçe isimlerini normalize et
gdf["ilce_norm"] = gdf["name"].apply(normalize_turkish)

# Mapping sözlüğü (orijinal isimler)
district_to_region = {
    # --- 1. Bölge ---
    "Adalar": "ISTANBUL-1",
    "Ataşehir": "ISTANBUL-1",
    "Beykoz": "ISTANBUL-1",
    "Çekmeköy": "ISTANBUL-1",
    "Kadıköy": "ISTANBUL-1",
    "Kartal": "ISTANBUL-1",
    "Maltepe": "ISTANBUL-1",
    "Pendik": "ISTANBUL-1",
    "Sancaktepe": "ISTANBUL-1",
    "Sultanbeyli": "ISTANBUL-1",
    "Şile": "ISTANBUL-1",
    "Tuzla": "ISTANBUL-1",
    "Ümraniye": "ISTANBUL-1",
    "Üsküdar": "ISTANBUL-1",

    # --- 2. Bölge ---
    "Bayrampaşa": "ISTANBUL-2",
    "Beşiktaş": "ISTANBUL-2",
    "Beyoğlu": "ISTANBUL-2",
    "Esenler": "ISTANBUL-2",
    "Eyüpsultan": "ISTANBUL-2",  # ← EYÜP kaldırıldı, sadece EYÜPSULTAN kalıyor
    "Fatih": "ISTANBUL-2",
    "Gaziosmanpaşa": "ISTANBUL-2",
    "Kağıthane": "ISTANBUL-2",
    "Sarıyer": "ISTANBUL-2",
    "Sultangazi": "ISTANBUL-2",
    "Şişli": "ISTANBUL-2",
    "Zeytinburnu": "ISTANBUL-2",

    # --- 3. Bölge ---
    "Arnavutköy": "ISTANBUL-3",
    "Avcılar": "ISTANBUL-3",
    "Bağcılar": "ISTANBUL-3",
    "Bahçelievler": "ISTANBUL-3",
    "Bakırköy": "ISTANBUL-3",
    "Başakşehir": "ISTANBUL-3",
    "Beylikdüzü": "ISTANBUL-3",
    "Büyükçekmece": "ISTANBUL-3",
    "Çatalca": "ISTANBUL-3",
    "Esenyurt": "ISTANBUL-3",
    "Güngören": "ISTANBUL-3",
    "Küçükçekmece": "ISTANBUL-3",
    "Silivri": "ISTANBUL-3",
}

# Normalize edilmiş mapping (lowercase ASCII)
norm_mapping = {normalize_turkish(k): v for k, v in district_to_region.items()}

# Eşle
gdf["region_id"] = gdf["ilce_norm"].map(norm_mapping)

# Kontrol: eşleşmeyen ilçe kaldı mı?
missing = gdf[gdf["region_id"].isna()]
if not missing.empty:
    print("\n⚠️  Eşleşmeyen ilçeler:")
    for idx, row in missing.iterrows():
        print(f"  {row['name']:20} → normalized: {row['ilce_norm']}")
else:
    print("\n✓ Tüm ilçeler başarıyla eşleştirildi!")

# Her şey tamamsa, seçim bölgesi poligonlarını üret (dissolve)
gdf_valid = gdf.dropna(subset=["region_id"])
if gdf_valid.empty:
    print("HATA: Hiçbir ilçe eşleşmedi. Mapping'i kontrol edin.")
    exit(1)

regions = gdf_valid.dissolve(by="region_id", as_index=False)

# Özellikleri düzenle
regions["city"] = "İstanbul"
regions["seats"] = regions["region_id"].map({
    "ISTANBUL-1": 35,
    "ISTANBUL-2": 28,
    "ISTANBUL-3": 35,
})

# Kullanılmayacak kolonu sil (geometry ve region_id dışında)
cols_to_keep = ["region_id", "city", "seats", "geometry"]
regions = regions[[c for c in cols_to_keep if c in regions.columns]]

# GeoJSON olarak kaydet
regions.to_file("istanbul_regions_3geo.json", driver="GeoJSON")
print("\n✓ istanbul_regions_3geo.json oluşturuldu.")
print(f"Toplam bölge: {len(regions)}")

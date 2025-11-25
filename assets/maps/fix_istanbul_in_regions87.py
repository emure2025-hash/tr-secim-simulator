import geopandas as gpd

# YOLLARI KENDİNE GÖRE GÜNCELLE
TURKEY_PATH = "regions87.geojson"              # Türkiye’nin 87 bölgeli dosyası
IST_PATH    = "istanbul_regions_3geo.json"     # İlçe bazlı dissolve ettiğimiz İstanbul 3 bölge dosyası
OUT_PATH    = "regions87_istanbul_fixed.geojson"

print("Dosyalar yükleniyor...")
turkey = gpd.read_file(TURKEY_PATH)
ist = gpd.read_file(IST_PATH)

print("Önceki kolonlar (turkey):", turkey.columns)
print("Önceki kolonlar (ist):", ist.columns)

# ist dosyasında: region_id, city, seats, geometry var
# turkey dosyasında: id, name, city, seats, geometry var (id -> ISTANBUL-1/2/3)
# region_id ile id’yi eşleştiriyoruz
merged = turkey.merge(
    ist[["region_id", "geometry"]],
    left_on="id",
    right_on="region_id",
    how="left",
    suffixes=("", "_new"),
)

# region_id dolu olan satırlar İstanbul-1/2/3
mask = merged["region_id"].notna()
print("Güncellenecek satır sayısı (İstanbul bölgeleri):", mask.sum())

# İstanbul-1/2/3’ün geometrisini yeniyle değiştir
merged.loc[mask, "geometry"] = merged.loc[mask, "geometry_new"]

# Temizlik
merged = merged.drop(columns=["region_id", "geometry_new"])

print("Kaydediliyor:", OUT_PATH)
merged.to_file(OUT_PATH, driver="GeoJSON")
print("Bitti. Yeni dosya:", OUT_PATH)

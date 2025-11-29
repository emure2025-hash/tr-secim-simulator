import geopandas as gpd

# --- PATH AYARLARI ---
TURKEY_PATH = "assets/maps/regions87.geojson"               # Türkiye 87 bölgeli ana dosya
IST_PATH    = "assets/maps/istanbul_regions_3geo.json"      # İstanbul dissolve sonucu 3 bölge
ANK_PATH    = "assets/maps/ankara_regions_3geo.json"        # Ankara dissolve sonucu 3 bölge

OUT_PATH    = "assets/maps/regions87_istanbul_ankara_fixed.geojson"


print("\n📌 Dosyalar yükleniyor...")
turkey = gpd.read_file(TURKEY_PATH)
ist = gpd.read_file(IST_PATH)
ank = gpd.read_file(ANK_PATH)

print("→ Türkiye kolonları:", list(turkey.columns))
print("→ İstanbul kolonları:", list(ist.columns))
print("→ Ankara kolonları:", list(ank.columns))


# ------------------------------
# 1) İSTANBUL 3 BÖLGE ENTEGRASYONU
# ------------------------------
print("\n🔵 İstanbul bölgeleri işleniyor...")

merged = turkey.merge(
    ist[["region_id", "geometry"]],
    left_on="id",
    right_on="region_id",
    how="left",
    suffixes=("", "_ist"),
)

ist_mask = merged["region_id"].notna()
print("→ Güncellenecek İstanbul bölgesi sayısı:", ist_mask.sum())

merged.loc[ist_mask, "geometry"] = merged.loc[ist_mask, "geometry_ist"]
merged = merged.drop(columns=["region_id", "geometry_ist"])


# ------------------------------
# 2) ANKARA 3 BÖLGE ENTEGRASYONU
# ------------------------------
print("\n🟣 Ankara bölgeleri işleniyor...")

merged = merged.merge(
    ank[["region_id", "geometry"]],
    left_on="id",
    right_on="region_id",
    how="left",
    suffixes=("", "_ank"),
)

ank_mask = merged["region_id"].notna()
print("→ Güncellenecek Ankara bölgesi sayısı:", ank_mask.sum())

merged.loc[ank_mask, "geometry"] = merged.loc[ank_mask, "geometry_ank"]
merged = merged.drop(columns=["region_id", "geometry_ank"])


# ------------------------------
# 3) KAYDET
# ------------------------------
print("\n💾 Kaydediliyor:", OUT_PATH)
merged.to_file(OUT_PATH, driver="GeoJSON")

print("\n🎉 BİTTİ!")
print("✔ Yeni GeoJSON hazır:", OUT_PATH)

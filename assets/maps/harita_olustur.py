import geopandas as gpd
import pandas as pd
import os

# --- AYARLAR ---
# GADM dosya adını buraya tam yaz (uzantısı .shp olacak)
SHAPEFILE_NAME = "gadm41_TUR_2.shp"
OUTPUT_NAME = "turkiye_87_secim_bolgesi.geojson"

# 1. DOSYALARI YÜKLE
print("Harita dosyası okunuyor...")
if not os.path.exists(SHAPEFILE_NAME):
    print(f"HATA: '{SHAPEFILE_NAME}' dosyası bulunamadı! 5 dosyanın da script ile aynı klasörde olduğundan emin ol.")
    exit()

gdf = gpd.read_file(SHAPEFILE_NAME)

# 2. SEÇİM BÖLGELERİ SÖZLÜĞÜ (2023 YSK)
# Türkçe karakter sorunu yaşamamak için ilçe isimlerini normalize ederek kontrol edeceğiz.
bolge_sozlugu = {
    'istanbul': {
        1: ['adalar', 'atasehir', 'beykoz', 'cekmekoy', 'kadikoy', 'kartal', 'maltepe', 'pendik', 'sancaktepe', 'sultanbeyli', 'sile', 'tuzla', 'umraniye', 'uskudar'],
        2: ['bayrampasa', 'besiktas', 'beyoglu', 'esenler', 'eyupsultan', 'eyup', 'fatih', 'gaziosmanpasa', 'kagithane', 'sariyer', 'sultangazi', 'sisli', 'zeytinburnu'],
        3: ['arnavutkoy', 'avcilar', 'bagcilar', 'bahcelievler', 'bakirkoy', 'basaksehir', 'beylikduzu', 'buyukcekmece', 'catalca', 'esenyurt', 'gungoren', 'kucukcekmece', 'silivri']
    },
    'ankara': {
        1: ['bala', 'cankaya', 'elmadag', 'evren', 'golbasi', 'haymana', 'mamak', 'polatli', 'sultan kochisar'],
        2: ['akyurt', 'altindag', 'camlidere', 'cubuk', 'gudul', 'kahramankazan', 'kazan', 'kalecik', 'kecioren', 'kizilcahamam', 'pursaklar'],
        3: ['ayas', 'beypazari', 'etimesgut', 'nallihan', 'sincan', 'yenimahalle']
    },
    'izmir': {
        1: ['balcova', 'buca', 'cesme', 'gaziemir', 'guzelbahce', 'karabaglar', 'karaburun', 'konak', 'menderes', 'narlidere', 'seferihisar', 'selcuk', 'torbali', 'urla'],
        2: ['aliaga', 'bayindir', 'bayrakli', 'bergama', 'beydag', 'bornova', 'cigli', 'dikili', 'foca', 'karsiyaka', 'kemalpasa', 'kinik', 'kiraz', 'menemen', 'odemis', 'tire']
    },
    'bursa': {
        1: ['buyukorhan', 'karacabey', 'mustafa kemalpasa', 'nilufer', 'orhaneli', 'osmangazi'],
        2: ['gemlik', 'gursu', 'harmancik', 'inegol', 'iznik', 'keles', 'kestel', 'mudanya', 'orhangazi', 'yenisehir', 'yildirim']
    }
}

# Yardımcı Fonksiyon: Metni İngilizce karakterlere ve küçük harfe çevirir (Eşleşme garantisi için)
def normalize(text):
    if not isinstance(text, str): return ""
    tr_map = str.maketrans("İıŞşĞğÜüÖöÇç", "IiSsGgUuOoCc")
    return text.translate(tr_map).lower()

# 3. BÖLGE ATAMA MANTIĞI
def bolge_bul(row):
    # GADM verisinde NAME_1 = İl, NAME_2 = İlçe
    il = normalize(row['NAME_1'])
    ilce = normalize(row['NAME_2'])
    
    # Orjinal İl Adı (Etiket için düzgün hali)
    orjinal_il = row['NAME_1']

    # Eğer 4 büyük ilden biriyse
    if il in bolge_sozlugu:
        for bolge_no, ilceler in bolge_sozlugu[il].items():
            if ilce in ilceler:
                return f"{orjinal_il}-{bolge_no}" # Örn: İstanbul-1
        
        # Listede bulamazsa (GADM ile isim uyuşmazlığı varsa)
        print(f"UYARI: {row['NAME_1']} - {row['NAME_2']} ilçesi listede bulunamadı!")
        return f"{orjinal_il}-Tanımsız"

    # Diğer 77 il için bölge adı direkt ilin adıdır
    return orjinal_il

print("Bölgeler hesaplanıyor...")
gdf['SECIM_BOLGESI'] = gdf.apply(bolge_bul, axis=1)

# 4. DISSOLVE (BİRLEŞTİRME)
print("İlçe sınırları eritilip seçim bölgelerine dönüştürülüyor (Dissolve)...")
# Sadece SECIM_BOLGESI ve geometri kalsın
gdf_final = gdf.dissolve(by='SECIM_BOLGESI', as_index=False)

# (İsteğe bağlı) Dosya boyutunu küçültmek için geometriyi basitleştir
# Mobil uygulama için detay seviyesini biraz düşürmek performansı artırır.
print("Geometri basitleştiriliyor (Mobil app için optimizasyon)...")
gdf_final['geometry'] = gdf_final['geometry'].simplify(tolerance=0.005, preserve_topology=True)

# 5. KAYDET
gdf_final = gdf_final[['SECIM_BOLGESI', 'geometry']] # Sadece gerekli kolonları al
gdf_final.to_file(OUTPUT_NAME, driver='GeoJSON')

print(f"\nBAŞARILI! Dosya oluşturuldu: {OUTPUT_NAME}")
print("Bu dosyayı mobil projene dahil edebilirsin.")
class PartyStrengths {
  // Not: Ýstanbul/Ankara/Ýzmir/Bursa bölündü (1-2-3) için aynı şehir katsayısı kullanıldı.
  static const Map<String, double> chp = {
    "Adana": 1.10, "Adiyaman": 0.55, "Afyon": 0.65, "Agri": 0.40,
    "Aksaray": 0.55, "Amasya": 0.85, "Ankara": 1.20, "Ankara-1": 1.20, "Ankara-2": 1.20, "Ankara-3": 1.20,
    "Antalya": 1.25, "Ardahan": 0.95, "Artvin": 0.90, "Aydin": 1.30,
    "Balikesir": 0.95, "Bartin": 0.90, "Batman": 0.45, "Bayburt": 0.40,
    "Bilecik": 1.05, "Bingol": 0.40, "Bitlis": 0.45, "Bolu": 0.80,
    "Burdur": 1.00, "Bursa": 0.90, "Bursa-1": 0.90, "Bursa-2": 0.90,
    "Canakkale": 1.25, "Cankiri": 0.55, "Corum": 0.70, "Denizli": 1.00,
    "Diyarbakir": 0.45, "Duzce": 0.55, "Edirne": 1.35, "Elazig": 0.50,
    "Erzincan": 0.60, "Erzurum": 0.40, "Eskisehir": 1.30, "Gaziantep": 1.10,
    "Giresun": 0.95, "Gumushane": 0.95, "Hakkari": 1.15, "Hatay": 1.00,
    "Igdir": 1.05, "Isparta": 0.95, "Istanbul": 1.00, "Istanbul-1": 1.00, "Istanbul-2": 1.00, "Istanbul-3": 1.00,
    "Izmir": 0.95, "Izmir-1": 0.95, "Izmir-2": 0.95, "Kahramanmaras": 1.05, "Karabuk": 0.95,
    "Karaman": 1.00, "Kars": 1.00, "Kastamonu": 0.95, "Kayseri": 1.00,
    "Kirikkale": 0.95, "Kirklareli": 0.90, "Kirsehir": 0.95, "Kilis": 1.05,
    "Kocaeli": 0.95, "Konya": 1.05, "Kutahya": 0.95, "Malatya": 1.00,
    "Manisa": 0.95, "Mardin": 1.10, "Mersin": 0.95, "Mugla": 0.90,
    "Mus": 1.10, "Nevsehir": 1.00, "Nigde": 1.00, "Ordu": 0.95,
    "Osmaniye": 1.00, "Rize": 0.95, "Sakarya": 0.95, "Samsun": 0.95,
    "Sanliurfa": 1.15, "Siirt": 1.10, "Sinop": 0.95, "Sivas": 0.95,
    "Sirnak": 1.15, "Tekirdag": 0.90, "Tokat": 0.95, "Trabzon": 0.95,
    "Tunceli": 0.85, "Usak": 0.95, "Van": 1.10, "Yalova": 0.95,
    "Yozgat": 1.00, "Zonguldak": 0.95,
  };

  static const Map<String, double> akp = {
    "Adana": 1.05, "Adiyaman": 1.30, "Afyon": 1.40, "Agri": 1.10,
    "Aksaray": 1.50, "Amasya": 1.30, "Ankara": 1.10, "Ankara-1": 1.10, "Ankara-2": 1.10, "Ankara-3": 1.10,
    "Antalya": 0.90, "Ardahan": 0.75, "Artvin": 0.95, "Aydin": 0.60,
    "Balikesir": 1.20, "Bartin": 1.25, "Batman": 0.70, "Bayburt": 1.60,
    "Bilecik": 1.10, "Bingol": 0.80, "Bitlis": 0.85, "Bolu": 1.35,
    "Burdur": 1.20, "Bursa": 1.25, "Bursa-1": 1.25, "Bursa-2": 1.25,
    "Canakkale": 0.80, "Cankiri": 1.70, "Corum": 1.45, "Denizli": 1.10,
    "Diyarbakir": 0.55, "Duzce": 1.70, "Edirne": 0.45, "Elazig": 1.20,
    "Erzincan": 1.10, "Erzurum": 1.50, "Eskisehir": 0.95, "Gaziantep": 1.30,
    "Giresun": 1.30, "Gumushane": 1.50, "Hakkari": 0.40, "Hatay": 1.10,
    "Igdir": 0.50, "Isparta": 1.40, "Istanbul": 0.90, "Istanbul-1": 0.90, "Istanbul-2": 0.90, "Istanbul-3": 0.90,
    "Izmir": 0.55, "Izmir-1": 0.55, "Izmir-2": 0.55, "Kahramanmaras": 1.60, "Karabuk": 1.30,
    "Karaman": 1.50, "Kars": 1.10, "Kastamonu": 1.55, "Kayseri": 1.70,
    "Kirikkale": 1.55, "Kirklareli": 0.70, "Kirsehir": 1.10, "Kilis": 1.20,
    "Kocaeli": 1.10, "Konya": 1.85, "Kutahya": 1.45, "Malatya": 1.40,
    "Manisa": 1.10, "Mardin": 0.60, "Mersin": 0.85, "Mugla": 0.55,
    "Mus": 0.90, "Nevsehir": 1.60, "Nigde": 1.55, "Ordu": 1.30,
    "Osmaniye": 1.70, "Rize": 1.95, "Sakarya": 1.45, "Samsun": 1.40,
    "Sanliurfa": 1.25, "Siirt": 0.85, "Sinop": 1.00, "Sivas": 1.40,
    "Sirnak": 0.45, "Tekirdag": 0.75, "Tokat": 1.40, "Trabzon": 1.60,
    "Tunceli": 0.45, "Usak": 1.20, "Van": 0.60, "Yalova": 1.00,
    "Yozgat": 1.70, "Zonguldak": 1.20,
  };

  static const Map<String, double> mhp = {
    "Adana": 1.20, "Adiyaman": 0.90, "Afyonkarahisar": 1.30, "Agri": 0.50,
    "Aksaray": 1.40, "Amasya": 1.25, "Ankara": 1.10, "Ankara-1": 1.10, "Ankara-2": 1.10, "Ankara-3": 1.10,
    "Antalya": 0.90, "Ardahan": 0.70, "Artvin": 0.85, "Aydin": 0.80,
    "Balikesir": 1.15, "Bartin": 1.25, "Batman": 0.40, "Bayburt": 1.30,
    "Bilecik": 1.05, "Bingol": 0.60, "Bitlis": 0.40, "Bolu": 1.25,
    "Burdur": 1.10, "Bursa": 1.10, "Bursa-1": 1.10, "Bursa-2": 1.10,
    "Canakkale": 0.80, "Cankiri": 1.60, "Corum": 1.30, "Denizli": 1.05,
    "Diyarbakir": 0.30, "Duzce": 1.35, "Edirne": 0.70, "Elazig": 1.00,
    "Erzincan": 1.00, "Erzurum": 1.20, "Eskisehir": 0.85, "Gaziantep": 0.90,
    "Giresun": 1.20, "Gumushane": 1.40, "Hakkari": 0.20, "Hatay": 0.95,
    "Igdir": 0.40, "Isparta": 1.30, "Istanbul": 0.90, "Istanbul-1": 0.90, "Istanbul-2": 0.90, "Istanbul-3": 0.90,
    "Izmir": 0.60, "Izmir-1": 0.60, "Izmir-2": 0.60, "Kahramanmaras": 1.30, "Karabuk": 1.25,
    "Karaman": 1.40, "Kars": 0.60, "Kastamonu": 1.45, "Kayseri": 1.45,
    "Kirikkale": 1.40, "Kirklareli": 0.80, "Kirsehir": 1.05, "Kilis": 1.00,
    "Kocaeli": 1.00, "Konya": 1.20, "Kutahya": 1.40, "Malatya": 1.05,
    "Manisa": 1.10, "Mardin": 0.40, "Mersin": 0.95, "Mugla": 0.65,
    "Mus": 0.35, "Nevsehir": 1.30, "Nigde": 1.30, "Ordu": 1.25,
    "Osmaniye": 1.80, "Rize": 1.40, "Sakarya": 1.30, "Samsun": 1.25,
    "Sanliurfa": 0.50, "Siirt": 0.40, "Sinop": 1.10, "Sivas": 1.40,
    "Sirnak": 0.20, "Tekirdag": 0.80, "Tokat": 1.30, "Trabzon": 1.30,
    "Tunceli": 0.20, "Usak": 1.10, "Van": 0.30, "Yalova": 1.00,
    "Yozgat": 1.60, "Zonguldak": 1.10,
  };

  static const Map<String, double> iyi = {
    "Adana": 1.10, "Adiyaman": 0.80, "Afyonkarahisar": 1.20, "Agri": 0.30,
    "Aksaray": 1.10, "Amasya": 1.30, "Ankara": 1.40, "Ankara-1": 1.40, "Ankara-2": 1.40, "Ankara-3": 1.40,
    "Antalya": 1.30, "Ardahan": 0.70, "Artvin": 1.20, "Aydin": 1.10,
    "Balikesir": 1.20, "Bartin": 1.00, "Batman": 0.25, "Bayburt": 0.50,
    "Bilecik": 1.30, "Bingol": 0.30, "Bitlis": 0.25, "Bolu": 1.30,
    "Burdur": 1.20, "Bursa": 1.30, "Bursa-1": 1.30, "Bursa-2": 1.30,
    "Canakkale": 1.30, "Cankiri": 0.70, "Corum": 1.20, "Denizli": 1.30,
    "Diyarbakir": 0.20, "Duzce": 1.10, "Edirne": 1.30, "Elazig": 0.60,
    "Erzincan": 1.00, "Erzurum": 0.60, "Eskisehir": 1.50, "Gaziantep": 0.60,
    "Giresun": 1.20, "Gumushane": 0.70, "Hakkari": 0.20, "Hatay": 1.10,
    "Igdir": 0.30, "Isparta": 1.10, "Istanbul": 1.20, "Istanbul-1": 1.20, "Istanbul-2": 1.20, "Istanbul-3": 1.20,
    "Izmir": 1.30, "Izmir-1": 1.30, "Izmir-2": 1.30, "Kahramanmaras": 0.60, "Karabuk": 1.10,
    "Karaman": 0.90, "Kars": 0.40, "Kastamonu": 1.10, "Kayseri": 1.20,
    "Kirikkale": 1.00, "Kirklareli": 1.40, "Kirsehir": 1.30, "Kilis": 0.60,
    "Kocaeli": 1.20, "Konya": 0.80, "Kutahya": 1.10, "Malatya": 0.70,
    "Manisa": 1.10, "Mardin": 0.30, "Mersin": 1.20, "Mugla": 1.40,
    "Mus": 0.20, "Nevsehir": 1.00, "Nigde": 0.90, "Ordu": 1.20,
    "Osmaniye": 0.60, "Rize": 0.70, "Sakarya": 1.10, "Samsun": 1.20,
    "Sanliurfa": 0.40, "Siirt": 0.20, "Sinop": 1.10, "Sivas": 1.10,
    "Sirnak": 0.20, "Tekirdag": 1.30, "Tokat": 1.10, "Trabzon": 1.10,
    "Tunceli": 0.40, "Usak": 1.10, "Van": 0.30, "Yalova": 1.10,
    "Yozgat": 0.90, "Zonguldak": 1.10,
  };

  static const Map<String, double> dem = {
    "Adana": 0.90, "Adiyaman": 0.70, "Afyonkarahisar": 0.20, "Agri": 2.20,
    "Aksaray": 0.10, "Amasya": 0.20, "Ankara": 0.90, "Ankara-1": 0.90, "Ankara-2": 0.90, "Ankara-3": 0.90,
    "Antalya": 0.80, "Ardahan": 0.70, "Artvin": 0.50, "Aydin": 0.60,
    "Balikesir": 0.40, "Bartin": 0.20, "Batman": 2.40, "Bayburt": 0.05,
    "Bilecik": 0.30, "Bingol": 1.60, "Bitlis": 1.80, "Bolu": 0.20,
    "Burdur": 0.25, "Bursa": 0.70, "Bursa-1": 0.70, "Bursa-2": 0.70,
    "Canakkale": 0.60, "Cankiri": 0.05, "Corum": 0.20, "Denizli": 0.40,
    "Diyarbakir": 2.60, "Duzce": 0.10, "Edirne": 0.50, "Elazig": 0.60,
    "Erzincan": 0.50, "Erzurum": 0.40, "Eskisehir": 0.60, "Gaziantep": 1.10,
    "Giresun": 0.10, "Gumushane": 0.05, "Hakkari": 2.80, "Hatay": 0.70,
    "Igdir": 2.20, "Isparta": 0.15, "Istanbul": 1.20, "Istanbul-1": 1.20, "Istanbul-2": 1.20, "Istanbul-3": 1.20,
    "Izmir": 1.00, "Izmir-1": 1.00, "Izmir-2": 1.00, "Kahramanmaras": 0.20, "Karabuk": 0.10,
    "Karaman": 0.05, "Kars": 1.40, "Kastamonu": 0.10, "Kayseri": 0.25,
    "Kirikkale": 0.05, "Kirklareli": 0.40, "Kirsehir": 0.05, "Kilis": 0.30,
    "Kocaeli": 1.00, "Konya": 0.10, "Kutahya": 0.10, "Malatya": 0.60,
    "Manisa": 0.50, "Mardin": 2.20, "Mersin": 1.60, "Mugla": 0.40,
    "Mus": 1.80, "Nevsehir": 0.10, "Nigde": 0.05, "Ordu": 0.10,
    "Osmaniye": 0.05, "Rize": 0.05, "Sakarya": 0.10, "Samsun": 0.10,
    "Sanliurfa": 1.40, "Siirt": 1.60, "Sinop": 0.15, "Sivas": 0.20,
    "Sirnak": 2.80, "Tekirdag": 0.50, "Tokat": 0.20, "Trabzon": 0.10,
    "Tunceli": 2.40, "Usak": 0.20, "Van": 2.50, "Yalova": 0.20,
    "Yozgat": 0.05, "Zonguldak": 0.20,
  };

  static const Map<String, double> yenidenRefah = {
    "Adana": 1.10, "Adiyaman": 1.20, "Afyon": 1.15, "Agri": 1.10,
    "Aksaray": 1.25, "Amasya": 1.10, "Ankara": 1.00, "Ankara-1": 1.00, "Ankara-2": 1.00, "Ankara-3": 1.00,
    "Antalya": 0.90, "Ardahan": 0.80, "Artvin": 0.85, "Aydin": 0.85,
    "Balikesir": 1.05, "Bartin": 1.00, "Batman": 1.30, "Bayburt": 1.10,
    "Bilecik": 1.00, "Bingol": 1.20, "Bitlis": 1.25, "Bolu": 1.05,
    "Burdur": 1.00, "Bursa": 1.10, "Bursa-1": 1.10, "Bursa-2": 1.10,
    "Canakkale": 0.90, "Cankiri": 1.20, "Corum": 1.15, "Denizli": 0.95,
    "Diyarbakir": 1.40, "Duzce": 1.10, "Edirne": 0.80, "Elazig": 1.15,
    "Erzincan": 1.10, "Erzurum": 1.20, "Eskisehir": 0.85, "Gaziantep": 1.35,
    "Giresun": 1.05, "Gumushane": 1.10, "Hakkari": 1.50, "Hatay": 1.10,
    "Igdir": 1.30, "Isparta": 1.05, "Istanbul": 1.15, "Istanbul-1": 1.15, "Istanbul-2": 1.15, "Istanbul-3": 1.15,
    "Izmir": 0.95, "Izmir-1": 0.95, "Izmir-2": 0.95, "Kahramanmaras": 1.30, "Karabuk": 1.00,
    "Karaman": 1.20, "Kars": 1.20, "Kastamonu": 1.10, "Kayseri": 1.25,
    "Kirikkale": 1.10, "Kirklareli": 0.85, "Kirsehir": 1.05, "Kilis": 1.25,
    "Kocaeli": 1.05, "Konya": 1.30, "Kutahya": 1.15, "Malatya": 1.25,
    "Manisa": 1.00, "Mardin": 1.35, "Mersin": 1.05, "Mugla": 0.85,
    "Mus": 1.30, "Nevsehir": 1.20, "Nigde": 1.15, "Ordu": 1.05,
    "Osmaniye": 1.25, "Rize": 1.15, "Sakarya": 1.15, "Samsun": 1.10,
    "Sanliurfa": 1.40, "Siirt": 1.35, "Sinop": 0.95, "Sivas": 1.15,
    "Sirnak": 1.45, "Tekirdag": 0.90, "Tokat": 1.10, "Trabzon": 1.10,
    "Tunceli": 0.70, "Usak": 1.00, "Van": 1.40, "Yalova": 1.00,
    "Yozgat": 1.20, "Zonguldak": 1.00,
  };

  static const Map<String, double> zafer = {
    "Adana": 1.05, "Adiyaman": 0.90, "Afyon": 1.10, "Agri": 0.70,
    "Aksaray": 1.15, "Amasya": 1.20, "Ankara": 1.25, "Ankara-1": 1.25, "Ankara-2": 1.25, "Ankara-3": 1.25,
    "Antalya": 1.15, "Ardahan": 0.85, "Artvin": 0.95, "Aydin": 1.10,
    "Balikesir": 1.15, "Bartin": 1.10, "Batman": 0.60, "Bayburt": 0.90,
    "Bilecik": 1.15, "Bingol": 0.70, "Bitlis": 0.65, "Bolu": 1.20,
    "Burdur": 1.10, "Bursa": 1.20, "Bursa-1": 1.20, "Bursa-2": 1.20,
    "Canakkale": 1.15, "Cankiri": 1.10, "Corum": 1.15, "Denizli": 1.15,
    "Diyarbakir": 0.50, "Duzce": 1.15, "Edirne": 1.20, "Elazig": 0.85,
    "Erzincan": 0.95, "Erzurum": 0.90, "Eskisehir": 1.25, "Gaziantep": 0.95,
    "Giresun": 1.10, "Gumushane": 1.00, "Hakkari": 0.40, "Hatay": 1.00,
    "Igdir": 0.60, "Isparta": 1.10, "Istanbul": 1.30, "Istanbul-1": 1.30, "Istanbul-2": 1.30, "Istanbul-3": 1.30,
    "Izmir": 1.25, "Izmir-1": 1.25, "Izmir-2": 1.25, "Kahramanmaras": 0.90, "Karabuk": 1.15,
    "Karaman": 1.05, "Kars": 0.80, "Kastamonu": 1.15, "Kayseri": 1.10,
    "Kirikkale": 1.10, "Kirklareli": 1.25, "Kirsehir": 1.10, "Kilis": 0.85,
    "Kocaeli": 1.20, "Konya": 1.00, "Kutahya": 1.15, "Malatya": 0.90,
    "Manisa": 1.15, "Mardin": 0.60, "Mersin": 1.10, "Mugla": 1.20,
    "Mus": 0.55, "Nevsehir": 1.05, "Nigde": 1.05, "Ordu": 1.10,
    "Osmaniye": 0.90, "Rize": 1.00, "Sakarya": 1.15, "Samsun": 1.15,
    "Sanliurfa": 0.70, "Siirt": 0.60, "Sinop": 1.10, "Sivas": 1.10,
    "Sirnak": 0.45, "Tekirdag": 1.20, "Tokat": 1.10, "Trabzon": 1.05,
    "Tunceli": 0.50, "Usak": 1.10, "Van": 0.60, "Yalova": 1.15,
    "Yozgat": 1.05, "Zonguldak": 1.15,
  };

  static const Map<String, double> hudapar = {
    "Adana": 0.85, "Adiyaman": 1.10, "Afyon": 0.75, "Agri": 1.40,
    "Aksaray": 0.80, "Amasya": 0.70, "Ankara": 0.85, "Ankara-1": 0.85, "Ankara-2": 0.85, "Ankara-3": 0.85,
    "Antalya": 0.75, "Ardahan": 0.70, "Artvin": 0.65, "Aydin": 0.70,
    "Balikesir": 0.75, "Bartin": 0.70, "Batman": 2.00, "Bayburt": 0.60,
    "Bilecik": 0.75, "Bingol": 1.80, "Bitlis": 2.10, "Bolu": 0.70,
    "Burdur": 0.70, "Bursa": 0.85, "Bursa-1": 0.85, "Bursa-2": 0.85,
    "Canakkale": 0.70, "Cankiri": 0.65, "Corum": 0.70, "Denizli": 0.75,
    "Diyarbakir": 2.50, "Duzce": 0.70, "Edirne": 0.70, "Elazig": 1.20,
    "Erzincan": 0.80, "Erzurum": 0.90, "Eskisehir": 0.75, "Gaziantep": 1.30,
    "Giresun": 0.65, "Gumushane": 0.60, "Hakkari": 2.80, "Hatay": 0.85,
    "Igdir": 1.50, "Isparta": 0.70, "Istanbul": 1.00, "Istanbul-1": 1.00, "Istanbul-2": 1.00, "Istanbul-3": 1.00,
    "Izmir": 0.80, "Izmir-1": 0.80, "Izmir-2": 0.80, "Kahramanmaras": 1.00, "Karabuk": 0.70,
    "Karaman": 0.70, "Kars": 1.10, "Kastamonu": 0.65, "Kayseri": 0.85,
    "Kirikkale": 0.65, "Kirklareli": 0.70, "Kirsehir": 0.70, "Kilis": 1.10,
    "Kocaeli": 0.85, "Konya": 0.85, "Kutahya": 0.75, "Malatya": 1.15,
    "Manisa": 0.75, "Mardin": 2.30, "Mersin": 0.90, "Mugla": 0.70,
    "Mus": 2.00, "Nevsehir": 0.75, "Nigde": 0.75, "Ordu": 0.70,
    "Osmaniye": 0.80, "Rize": 0.65, "Sakarya": 0.80, "Samsun": 0.75,
    "Sanliurfa": 1.90, "Siirt": 2.10, "Sinop": 0.70, "Sivas": 0.80,
    "Sirnak": 2.70, "Tekirdag": 0.75, "Tokat": 0.75, "Trabzon": 0.70,
    "Tunceli": 0.50, "Usak": 0.70, "Van": 2.20, "Yalova": 0.75,
    "Yozgat": 0.75, "Zonguldak": 0.75,
  };

  static const Map<String, double> buyukBirlik = {
    "Adana": 0.95, "Adiyaman": 1.05, "Afyon": 0.95, "Agri": 1.00,
    "Aksaray": 1.05, "Amasya": 0.95, "Ankara": 0.95, "Ankara-1": 0.95, "Ankara-2": 0.95, "Ankara-3": 0.95,
    "Antalya": 0.90, "Ardahan": 0.85, "Artvin": 0.85, "Aydin": 0.90,
    "Balikesir": 0.95, "Bartin": 0.95, "Batman": 1.10, "Bayburt": 0.95,
    "Bilecik": 0.95, "Bingol": 1.05, "Bitlis": 1.10, "Bolu": 0.95,
    "Burdur": 0.95, "Bursa": 0.95, "Bursa-1": 0.95, "Bursa-2": 0.95,
    "Canakkale": 0.90, "Cankiri": 1.00, "Corum": 0.95, "Denizli": 0.95,
    "Diyarbakir": 1.10, "Duzce": 0.95, "Edirne": 0.85, "Elazig": 1.00,
    "Erzincan": 0.95, "Erzurum": 1.00, "Eskisehir": 0.90, "Gaziantep": 1.05,
    "Giresun": 0.90, "Gumushane": 0.85, "Hakkari": 1.15, "Hatay": 0.95,
    "Igdir": 1.10, "Isparta": 0.95, "Istanbul": 1.00, "Istanbul-1": 1.00, "Istanbul-2": 1.00, "Istanbul-3": 1.00,
    "Izmir": 0.90, "Izmir-1": 0.90, "Izmir-2": 0.90, "Kahramanmaras": 1.00, "Karabuk": 0.95,
    "Karaman": 0.95, "Kars": 1.05, "Kastamonu": 0.90, "Kayseri": 1.00,
    "Kirikkale": 0.95, "Kirklareli": 0.85, "Kirsehir": 0.95, "Kilis": 1.00,
    "Kocaeli": 0.95, "Konya": 1.00, "Kutahya": 0.95, "Malatya": 1.00,
    "Manisa": 0.95, "Mardin": 1.10, "Mersin": 0.95, "Mugla": 0.90,
    "Mus": 1.10, "Nevsehir": 0.95, "Nigde": 0.95, "Ordu": 0.90,
    "Osmaniye": 1.00, "Rize": 0.85, "Sakarya": 0.95, "Samsun": 0.95,
    "Sanliurfa": 1.05, "Siirt": 1.10, "Sinop": 0.90, "Sivas": 0.95,
    "Sirnak": 1.15, "Tekirdag": 0.85, "Tokat": 0.95, "Trabzon": 0.95,
    "Tunceli": 1.05, "Usak": 0.95, "Van": 1.10, "Yalova": 0.95,
    "Yozgat": 0.95, "Zonguldak": 0.95,
  };

  static const Map<String, double> diger = {
    "Adana": 1.0, "Adiyaman": 1.0, "Afyonkarahisar": 1.0, "Agri": 1.0,
    "Aksaray": 1.0, "Amasya": 1.0, "Ankara": 1.0, "Ankara-1": 1.0, "Ankara-2": 1.0, "Ankara-3": 1.0,
    "Antalya": 1.0, "Ardahan": 1.0, "Artvin": 1.0, "Aydin": 1.0,
    "Balikesir": 1.0, "Bartin": 1.0, "Batman": 1.0, "Bayburt": 1.0,
    "Bilecik": 1.0, "Bingol": 1.0, "Bitlis": 1.0, "Bolu": 1.0,
    "Burdur": 1.0, "Bursa": 1.0, "Bursa-1": 1.0, "Bursa-2": 1.0,
    "Canakkale": 1.0, "Cankiri": 1.0, "Corum": 1.0, "Denizli": 1.0,
    "Diyarbakir": 1.0, "Duzce": 1.0, "Edirne": 1.0, "Elazig": 1.0,
    "Erzincan": 1.0, "Erzurum": 1.0, "Eskisehir": 1.0, "Gaziantep": 1.0,
    "Giresun": 1.0, "Gumushane": 1.0, "Hakkari": 1.0, "Hatay": 1.0,
    "Igdir": 1.0, "Isparta": 1.0, "Istanbul": 1.0, "Istanbul-1": 1.0, "Istanbul-2": 1.0, "Istanbul-3": 1.0,
    "Izmir": 1.0, "Izmir-1": 1.0, "Izmir-2": 1.0, "Kahramanmaras": 1.0, "Karabuk": 1.0,
    "Karaman": 1.0, "Kars": 1.0, "Kastamonu": 1.0, "Kayseri": 1.0,
    "Kirikkale": 1.0, "Kirklareli": 1.0, "Kirsehir": 1.0, "Kilis": 1.0,
    "Kocaeli": 1.0, "Konya": 1.0, "Kutahya": 1.0, "Malatya": 1.0,
    "Manisa": 1.0, "Mardin": 1.0, "Mersin": 1.0, "Mugla": 1.0,
    "Mus": 1.0, "Nevsehir": 1.0, "Nigde": 1.0, "Ordu": 1.0,
    "Osmaniye": 1.0, "Rize": 1.0, "Sakarya": 1.0, "Samsun": 1.0,
    "Sanliurfa": 1.0, "Siirt": 1.0, "Sinop": 1.0, "Sivas": 1.0,
    "Sirnak": 1.0, "Tekirdag": 1.0, "Tokat": 1.0, "Trabzon": 1.0,
    "Tunceli": 1.0, "Usak": 1.0, "Van": 1.0, "Yalova": 1.0,
    "Yozgat": 1.0, "Zonguldak": 1.0,
  };
}

// Geriye dönük uyumluluk için top-level alias'lar
final Map<String, double> chpStrength = PartyStrengths.chp;
final Map<String, double> akpStrength = PartyStrengths.akp;
final Map<String, double> mhpStrength = PartyStrengths.mhp;
final Map<String, double> iyiStrength = PartyStrengths.iyi;
final Map<String, double> demStrength = PartyStrengths.dem;
final Map<String, double> yenidenRefahStrength = PartyStrengths.yenidenRefah;
final Map<String, double> zaferStrength = PartyStrengths.zafer;
final Map<String, double> hudaparStrength = PartyStrengths.hudapar;
final Map<String, double> buyukBirlikStrength = PartyStrengths.buyukBirlik;
final Map<String, double> otherStrength = PartyStrengths.diger;

String _normalize(String s) {
  return s
      .toLowerCase()
      .trim()
      .replaceAll('ı', 'i')
      .replaceAll('İ', 'i')
      .replaceAll('ş', 's')
      .replaceAll('Ş', 's')
      .replaceAll('ç', 'c')
      .replaceAll('Ç', 'c')
      .replaceAll('ğ', 'g')
      .replaceAll('Ğ', 'g')
      .replaceAll('ö', 'o')
      .replaceAll('Ö', 'o')
      .replaceAll('ü', 'u')
      .replaceAll('Ü', 'u')
      .replaceAll(RegExp(r'[^a-z0-9\\s]'), '')
      .replaceAll(' ', '');
}

double strengthFromMap(Map<String, double> map, String city) {
  if (map.containsKey(city)) return map[city]!;
  final norm = _normalize(city);
  for (final k in map.keys) {
    if (_normalize(k) == norm) return map[k]!;
  }
  if (norm == 'afyon' && map.containsKey('Afyonkarahisar')) {
    return map['Afyonkarahisar']!;
  }
  return 1.0;
}

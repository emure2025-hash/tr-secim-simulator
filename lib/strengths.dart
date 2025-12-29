class PartyStrengths {
  // Not: Ýstanbul/Ankara/Ýzmir/Bursa bölündü (1-2-3) için aynı şehir katsayısı kullanıldı.
  static const Map<String, double> chp = {
   "Adana": 1.13, "Adiyaman": 0.74, "Afyon": 0.75, "Agri": 0.13,
    "Aksaray": 0.29, "Amasya": 1.17, "Ankara-1": 1.64, "Ankara-2": 0.82,
    "Ankara-3": 1.10, "Antalya": 1.28, "Ardahan": 1.17, "Artvin": 1.18,
    "Aydin": 1.40, "Balikesir": 1.24, "Bartin": 1.24, "Batman": 0.11,
    "Bayburt": 0.24, "Bilecik": 1.06, "Bingol": 0.22, "Bitlis": 0.33,
    "Bolu": 0.86, "Burdur": 1.23, "Bursa-1": 1.07, "Bursa-2": 0.85,
    "Canakkale": 1.39, "Cankiri": 0.19, "Corum": 1.22, "Denizli": 1.26,
    "Diyarbakir": 0.32, "Duzce": 0.89, "Edirne": 1.55, "Elazig": 0.82,
    "Erzincan": 1.42, "Erzurum": 0.28, "Eskisehir": 1.35, "Gaziantep": 0.80,
    "Giresun": 0.81, "Gumushane": 0.31, "Hakkari": 0.29, "Hatay": 1.14,
    "Igdir": 0.26, "Isparta": 0.88, "Istanbul-1": 1.25, "Istanbul-2": 1.05,
    "Istanbul-3": 1.04, "Izmir-1": 1.85, "Izmir-2": 1.88, "Kahramanmaras": 0.65,
    "Karabuk": 0.87, "Karaman": 0.76, "Kars": 0.66, "Kastamonu": 0.86,
    "Kayseri": 0.68, "Kirikkale": 1.05, "Kirklareli": 1.79, "Kirsehir": 1.15,
    "Kilis": 0.81, "Kocaeli": 0.95, "Konya": 0.54, "Kutahya": 0.66,
    "Malatya": 0.85, "Manisa": 1.16, "Mardin": 0.28, "Mersin": 1.23,
    "Mugla": 1.49, "Mus": 0.10, "Nevsehir": 0.69, "Nigde": 0.96,
    "Ordu": 0.96, "Osmaniye": 0.68, "Rize": 0.65, "Sakarya": 0.65,
    "Samsun": 0.78, "Sanliurfa": 0.32, "Siirt": 0.31, "Sinop": 1.01,
    "Sivas": 0.65, "Sirnak": 0.34, "Tekirdag": 1.43, "Tokat": 0.82,
    "Trabzon": 0.72, "Tunceli": 1.26, "Usak": 1.15, "Van": 0.34,
    "Yalova": 1.13, "Yozgat": 0.25, "Zonguldak": 1.26,
  };

  static const Map<String, double> akp = {
   "Adana": 0.86, "Adiyaman": 1.53, "Afyon": 1.24, "Agri": 0.47,
    "Aksaray": 1.24, "Amasya": 1.11, "Ankara-1": 0.71, "Ankara-2": 1.17,
    "Ankara-3": 0.90, "Antalya": 0.82, "Ardahan": 0.98, "Artvin": 1.04,
    "Aydin": 0.69, "Balikesir": 0.97, "Bartin": 1.03, "Batman": 0.84,
    "Bayburt": 1.88, "Bilecik": 1.05, "Bingol": 1.10, "Bitlis": 1.06,
    "Bolu": 1.09, "Burdur": 1.03, "Bursa-1": 1.00, "Bursa-2": 1.14,
    "Canakkale": 0.90, "Cankiri": 1.20, "Corum": 1.13, "Denizli": 0.95,
    "Diyarbakir": 0.23, "Duzce": 1.40, "Edirne": 0.66, "Elazig": 1.14,
    "Erzincan": 1.09, "Erzurum": 1.52, "Eskisehir": 0.99, "Gaziantep": 1.26,
    "Giresun": 1.13, "Gumushane": 1.34, "Hakkari": 0.58, "Hatay": 0.95,
    "Igdir": 0.99, "Isparta": 0.92, "Istanbul-1": 0.99, "Istanbul-2": 1.09,
    "Istanbul-3": 1.00, "Izmir-1": 0.53, "Izmir-2": 0.50, "Kahramanmaras": 1.23,
    "Karabuk": 1.06, "Karaman": 1.14, "Kars": 0.73, "Kastamonu": 1.28,
    "Kayseri": 1.14, "Kirikkale": 1.07, "Kirklareli": 0.71, "Kirsehir": 1.09,
    "Kilis": 1.10, "Kocaeli": 1.11, "Konya": 1.32, "Kutahya": 1.31,
    "Malatya": 1.27, "Manisa": 1.04, "Mardin": 0.72, "Mersin": 0.70,
    "Mugla": 0.68, "Mus": 0.60, "Nevsehir": 1.11, "Nigde": 1.07,
    "Ordu": 1.27, "Osmaniye": 0.93, "Rize": 1.90, "Sakarya": 1.33,
    "Samsun": 1.19, "Sanliurfa": 1.21, "Siirt": 1.01, "Sinop": 1.20,
    "Sivas": 1.14, "Sirnak": 0.60, "Tekirdag": 0.84, "Tokat": 1.05,
    "Trabzon": 1.34, "Tunceli": 0.37, "Usak": 1.01, "Van": 0.57,
    "Yalova": 0.96, "Yozgat": 1.21, "Zonguldak": 1.13,
  };

  static const Map<String, double> mhp = {
    "Adana": 1.09, "Adiyaman": 0.44, "Afyon": 1.59, "Agri": 0.08,
    "Aksaray": 2.08, "Amasya": 1.66, "Ankara-1": 1.28, "Ankara-2": 1.19,
    "Ankara-3": 1.07, "Antalya": 1.03, "Ardahan": 0.32, "Artvin": 0.96,
    "Aydin": 0.86, "Balikesir": 0.81, "Bartin": 2.34, "Batman": 0.84,
    "Bayburt": 1.65, "Bilecik": 1.03, "Bingol": 0.04, "Bitlis": 0.06,
    "Bolu": 2.31, "Burdur": 1.39, "Bursa-1": 0.80, "Bursa-2": 0.93,
    "Canakkale": 0.66, "Cankiri": 3.11, "Corum": 2.00, "Denizli": 0.84,
    "Diyarbakir": 0.04, "Duzce": 1.60, "Edirne": 0.77, "Elazig": 1.10,
    "Erzincan": 1.95, "Erzurum": 1.65, "Eskisehir": 0.76, "Gaziantep": 0.96,
    "Giresun": 1.55, "Gumushane": 2.62, "Hakkari": 0.08, "Hatay": 1.26,
    "Igdir": 0.44, "Isparta": 2.06, "Istanbul-1": 0.65, "Istanbul-2": 0.58,
    "Istanbul-3": 0.66, "Izmir-1": 0.51, "Izmir-2": 0.58, "Kahramanmaras": 1.62,
    "Karabuk": 1.58, "Karaman": 1.79, "Kars": 0.53, "Kastamonu": 1.49,
    "Kayseri": 1.89, "Kirikkale": 2.15, "Kirklareli": 0.48, "Kirsehir": 1.47,
    "Kilis": 2.63, "Kocaeli": 0.84, "Konya": 1.42, "Kutahya": 1.29,
    "Malatya": 1.28, "Manisa": 1.43, "Mardin": 0.35, "Mersin": 1.19,
    "Mugla": 0.62, "Mus": 1.65, "Nevsehir": 2.01, "Nigde": 2.26,
    "Ordu": 1.26, "Osmaniye": 2.83, "Rize": 1.29, "Sakarya": 1.19,
    "Samsun": 1.19, "Sanliurfa": 0.94, "Siirt": 0.39, "Sinop": 0.91,
    "Sivas": 1.79, "Sirnak": 0.24, "Tekirdag": 0.64, "Tokat": 2.19,
    "Trabzon": 1.05, "Tunceli": 0.56, "Usak": 0.93, "Van": 0.09,
    "Yalova": 1.13, "Yozgat": 2.31, "Zonguldak": 0.86,
  };

  static const Map<String, double> iyi = {
     "Adana": 1.11, "Adiyaman": 0.10, "Afyon": 1.27, "Agri": 1.14,
    "Aksaray": 2.55, "Amasya": 0.73, "Ankara-1": 1.27, "Ankara-2": 1.18,
    "Ankara-3": 1.42, "Antalya": 1.22, "Ardahan": 0.50, "Artvin": 1.34,
    "Aydin": 1.32, "Balikesir": 1.51, "Bartin": 0.20, "Batman": 0.87,
    "Bayburt": 1.65, "Bilecik": 1.26, "Bingol": 0.60, "Bitlis": 0.08,
    "Bolu": 0.77, "Burdur": 1.17, "Bursa-1": 1.40, "Bursa-2": 1.04,
    "Canakkale": 1.68, "Cankiri": 1.81, "Corum": 0.24, "Denizli": 1.45,
    "Diyarbakir": 0.07, "Duzce": 0.30, "Edirne": 2.09, "Elazig": 0.25,
    "Erzincan": 0.28, "Erzurum": 0.98, "Eskisehir": 1.42, "Gaziantep": 0.56,
    "Giresun": 1.27, "Gumushane": 1.89, "Hakkari": 0.05, "Hatay": 0.83,
    "Igdir": 0.25, "Isparta": 1.68, "Istanbul-1": 0.80, "Istanbul-2": 0.88,
    "Istanbul-3": 0.83, "Izmir-1": 1.20, "Izmir-2": 1.13, "Kahramanmaras": 0.77,
    "Karabuk": 0.99, "Karaman": 1.12, "Kars": 1.53, "Kastamonu": 0.79,
    "Kayseri": 1.03, "Kirikkale": 1.04, "Kirklareli": 1.57, "Kirsehir": 0.74,
    "Kilis": 0.59, "Kocaeli": 0.98, "Konya": 0.89, "Kutahya": 1.08,
    "Malatya": 0.40, "Manisa": 1.13, "Mardin": 0.12, "Mersin": 1.22,
    "Mugla": 1.76, "Mus": 0.57, "Nevsehir": 1.62, "Nigde": 1.26,
    "Ordu": 1.01, "Osmaniye": 1.29, "Rize": 0.32, "Sakarya": 1.13,
    "Samsun": 1.27, "Sanliurfa": 0.47, "Siirt": 0.15, "Sinop": 0.97,
    "Sivas": 0.75, "Sirnak": 0.12, "Tekirdag": 1.14, "Tokat": 1.14,
    "Trabzon": 1.27, "Tunceli": 0.23, "Usak": 1.79, "Van": 0.11,
    "Yalova": 0.98, "Yozgat": 2.36, "Zonguldak": 1.00,
  };

  static const Map<String, double> dem = {
   "Adana": 1.10, "Adiyaman": 1.43, "Afyon": 0.07, "Agri": 6.14,
    "Aksaray": 0.10, "Amasya": 0.07, "Ankara-1": 0.47, "Ankara-2": 0.28,
    "Ankara-3": 0.31, "Antalya": 0.54, "Ardahan": 2.41, "Artvin": 0.13,
    "Aydin": 0.08, "Balikesir": 0.26, "Bartin": 0.07, "Batman": 6.51,
    "Bayburt": 0.08, "Bilecik": 0.03, "Bingol": 2.70, "Bitlis": 4.53,
    "Bolu": 0.11, "Burdur": 0.10, "Bursa-1": 0.37, "Bursa-2": 0.40,
    "Canakkale": 0.25, "Cankiri": 0.06, "Corum": 0.08, "Denizli": 0.30,
    "Diyarbakir": 7.74, "Duzce": 0.14, "Edirne": 0.23, "Elazig": 0.41,
    "Erzincan": 0.15, "Erzurum": 1.05, "Eskisehir": 0.27, "Gaziantep": 1.03,
    "Giresun": 0.28, "Gumushane": 0.07, "Hakkari": 7.05, "Hatay": 0.21,
    "Igdir": 4.91, "Isparta": 0.11, "Istanbul-1": 0.70, "Istanbul-2": 0.84,
    "Istanbul-3": 1.20, "Izmir-1": 0.55, "Izmir-2": 0.68, "Kahramanmaras": 0.10,
    "Karabuk": 0.08, "Karaman": 0.09, "Kars": 3.12, "Kastamonu": 0.06,
    "Kayseri": 0.13, "Kirikkale": 0.07, "Kirklareli": 0.22, "Kirsehir": 0.31,
    "Kilis": 0.18, "Kocaeli": 0.66, "Konya": 0.31, "Kutahya": 0.07,
    "Malatya": 0.36, "Manisa": 0.18, "Mardin": 6.16, "Mersin": 1.49,
    "Mugla": 0.40, "Mus": 5.71, "Nevsehir": 0.09, "Nigde": 0.11,
    "Ordu": 0.06, "Osmaniye": 0.06, "Rize": 0.07, "Sakarya": 0.20,
    "Samsun": 0.07, "Sanliurfa": 2.80, "Siirt": 5.27, "Sinop": 0.07,
    "Sivas": 0.39, "Sirnak": 7.06, "Tekirdag": 0.11, "Tokat": 0.07,
    "Trabzon": 0.05, "Tunceli": 4.72, "Usak": 0.18, "Van": 5.91,
    "Yalova": 0.65, "Yozgat": 0.08, "Zonguldak": 0.07,
  };

  static const Map<String, double> yenidenRefah = {
    "Adana": 0.64, "Adiyaman": 1.71, "Afyon": 1.05, "Agri": 1.96,
    "Aksaray": 0.93, "Amasya": 0.64, "Ankara-1": 0.46, "Ankara-2": 1.24,
    "Ankara-3": 0.98, "Antalya": 0.45, "Ardahan": 0.36, "Artvin": 0.85,
    "Aydin": 0.27, "Balikesir": 0.74, "Bartin": 0.64, "Batman": 0.40,
    "Bayburt": 1.06, "Bilecik": 1.19, "Bingol": 4.88, "Bitlis": 1.05,
    "Bolu": 0.27, "Burdur": 0.44, "Bursa-1": 1.14, "Bursa-2": 1.45,
    "Canakkale": 0.70, "Cankiri": 0.36, "Corum": 1.18, "Denizli": 0.49,
    "Diyarbakir": 0.79, "Duzce": 1.38, "Edirne": 0.25, "Elazig": 1.30,
    "Erzincan": 0.52, "Erzurum": 1.77, "Eskisehir": 0.51, "Gaziantep": 1.47,
    "Giresun": 0.89, "Gumushane": 0.96, "Hakkari": 0.65, "Hatay": 0.66,
    "Igdir": 1.57, "Isparta": 0.66, "Istanbul-1": 1.06, "Istanbul-2": 1.37,
    "Istanbul-3": 1.12, "Izmir-1": 0.30, "Izmir-2": 0.34, "Kahramanmaras": 1.95,
    "Karabuk": 2.95, "Karaman": 0.85, "Kars": 0.93, "Kastamonu": 1.45,
    "Kayseri": 1.25, "Kirikkale": 0.66, "Kirklareli": 0.24, "Kirsehir": 0.58,
    "Kilis": 0.84, "Kocaeli": 2.07, "Konya": 1.82, "Kutahya": 2.53,
    "Malatya": 3.31, "Manisa": 0.56, "Mardin": 0.41, "Mersin": 0.33,
    "Mugla": 0.23, "Mus": 1.20, "Nevsehir": 0.72, "Nigde": 0.94,
    "Ordu": 0.82, "Osmaniye": 0.71, "Rize": 1.81, "Sakarya": 1.42,
    "Samsun": 1.43, "Sanliurfa": 2.10, "Siirt": 0.85, "Sinop": 0.81,
    "Sivas": 1.23, "Sirnak": 0.62, "Tekirdag": 0.57, "Tokat": 0.91,
    "Trabzon": 1.62, "Tunceli": 0.09, "Usak": 0.51, "Van": 1.13,
    "Yalova": 0.76, "Yozgat": 1.58, "Zonguldak": 0.67,
  };

  static const Map<String, double> zafer = {
     "Adana": 1.11, "Adiyaman": 0.10, "Afyon": 1.27, "Agri": 1.14,
    "Aksaray": 1.55, "Amasya": 0.73, "Ankara-1": 1.27, "Ankara-2": 1.18,
    "Ankara-3": 1.42, "Antalya": 1.22, "Ardahan": 0.50, "Artvin": 1.34,
    "Aydin": 1.32, "Balikesir": 1.51, "Bartin": 0.20, "Batman": 0.37,
    "Bayburt": 0.95, "Bilecik": 1.26, "Bingol": 0.50, "Bitlis": 0.08,
    "Bolu": 1.17, "Burdur": 1.18, "Bursa-1": 1.40, "Bursa-2": 1.04,
    "Canakkale": 1.68, "Cankiri": 1.81, "Corum": 0.24, "Denizli": 1.45,
    "Diyarbakir": 0.07, "Duzce": 0.30, "Edirne": 2.09, "Elazig": 0.25,
    "Erzincan": 0.28, "Erzurum": 0.98, "Eskisehir": 1.62, "Gaziantep": 0.96,
    "Giresun": 1.27, "Gumushane": 1.89, "Hakkari": 0.05, "Hatay": 0.83,
    "Igdir": 0.25, "Isparta": 1.68, "Istanbul-1": 1.80, "Istanbul-2": 1.88,
    "Istanbul-3": 1.83, "Izmir-1": 1.20, "Izmir-2": 1.13, "Kahramanmaras": 0.77,
    "Karabuk": 0.99, "Karaman": 1.12, "Kars": 1.73, "Kastamonu": 0.79,
    "Kayseri": 1.33, "Kirikkale": 1.04, "Kirklareli": 1.57, "Kirsehir": 0.94,
    "Kilis": 0.59, "Kocaeli": 0.98, "Konya": 1.29, "Kutahya": 1.08,
    "Malatya": 0.40, "Manisa": 1.23, "Mardin": 0.12, "Mersin": 1.22,
    "Mugla": 1.76, "Mus": 0.37, "Nevsehir": 1.62, "Nigde": 1.26,
    "Ordu": 1.01, "Osmaniye": 1.29, "Rize": 0.32, "Sakarya": 1.13,
    "Samsun": 1.27, "Sanliurfa": 0.27, "Siirt": 0.15, "Sinop": 0.97,
    "Sivas": 0.75, "Sirnak": 0.02, "Tekirdag": 1.15, "Tokat": 1.14,
    "Trabzon": 1.27, "Tunceli": 0.23, "Usak": 1.79, "Van": 0.11,
    "Yalova": 0.98, "Yozgat": 2.36, "Zonguldak": 1.10,
  };

  static const Map<String, double> hudapar = {
    "Adana": 0.85, "Adiyaman": 1.50, "Afyon": 0.75, "Agri": 1.40,
    "Aksaray": 0.50, "Amasya": 0.70, "Ankara-1": 0.75, "Ankara-2": 0.95, "Ankara-3": 0.85,
    "Antalya": 0.75, "Ardahan": 0.70, "Artvin": 0.15, "Aydin": 0.70,
    "Balikesir": 0.75, "Bartin": 0.70, "Batman": 3.00, "Bayburt": 0.60,
    "Bilecik": 0.75, "Bingol": 1.80, "Bitlis": 2.10, "Bolu": 0.70,
    "Burdur": 0.70, "Bursa-1": 0.85, "Bursa-2": 0.95,
    "Canakkale": 0.70, "Cankiri": 0.65, "Corum": 0.70, "Denizli": 0.75,
    "Diyarbakir": 2.50, "Duzce": 0.70, "Edirne": 0.70, "Elazig": 1.20,
    "Erzincan": 0.80, "Erzurum": 0.90, "Eskisehir": 0.75, "Gaziantep": 1.30,
    "Giresun": 0.65, "Gumushane": 0.60, "Hakkari": 2.80, "Hatay": 0.85,
    "Igdir": 1.50, "Isparta": 0.70, "Istanbul-1": 1.00, "Istanbul-2": 1.10, "Istanbul-3": 1.08,
    "Izmir-1": 0.80, "Izmir-2": 0.80, "Kahramanmaras": 1.30, "Karabuk": 0.70,
    "Karaman": 0.70, "Kars": 1.10, "Kastamonu": 0.65, "Kayseri": 0.85,
    "Kirikkale": 0.65, "Kirklareli": 0.40, "Kirsehir": 0.70, "Kilis": 1.10,
    "Kocaeli": 0.85, "Konya": 0.85, "Kutahya": 0.75, "Malatya": 1.15,
    "Manisa": 0.75, "Mardin": 2.30, "Mersin": 1.25, "Mugla": 0.70,
    "Mus": 2.00, "Nevsehir": 0.75, "Nigde": 0.75, "Ordu": 0.70,
    "Osmaniye": 0.80, "Rize": 0.65, "Sakarya": 0.80, "Samsun": 0.75,
    "Sanliurfa": 1.90, "Siirt": 2.50, "Sinop": 0.70, "Sivas": 0.80,
    "Sirnak": 2.70, "Tekirdag": 0.75, "Tokat": 0.75, "Trabzon": 0.70,
    "Tunceli": 0.50, "Usak": 0.70, "Van": 2.20, "Yalova": 0.65,
    "Yozgat": 0.75, "Zonguldak": 0.55,
  };

  static const Map<String, double> buyukBirlik = {
    "Adana": 0.95, "Adiyaman": 1.05, "Afyon": 0.95, "Agri": 1.00,
    "Aksaray": 1.05, "Amasya": 0.95, "Ankara-1": 0.85, "Ankara-2": 1.05, "Ankara-3": 1.15,
    "Antalya": 0.90, "Ardahan": 0.85, "Artvin": 0.85, "Aydin": 0.90,
    "Balikesir": 0.95, "Bartin": 0.95, "Batman": 1.10, "Bayburt": 0.95,
    "Bilecik": 0.95, "Bingol": 1.05, "Bitlis": 1.10, "Bolu": 0.95,
    "Burdur": 0.95, "Bursa-1": 0.95, "Bursa-2": 0.95,
    "Canakkale": 0.90, "Cankiri": 1.00, "Corum": 0.95, "Denizli": 0.95,
    "Diyarbakir": 0.60, "Duzce": 0.95, "Edirne": 0.85, "Elazig": 1.00,
    "Erzincan": 0.95, "Erzurum": 1.00, "Eskisehir": 0.90, "Gaziantep": 1.05,
    "Giresun": 0.90, "Gumushane": 0.85, "Hakkari": 1.15, "Hatay": 0.95,
    "Igdir": 1.10, "Isparta": 0.95, "Istanbul-1": 1.00, "Istanbul-2": 1.10, "Istanbul-3": 1.05,
    "Izmir-1": 0.90, "Izmir-2": 0.90, "Kahramanmaras": 1.00, "Karabuk": 0.95,
    "Karaman": 0.95, "Kars": 1.05, "Kastamonu": 0.90, "Kayseri": 1.00,
    "Kirikkale": 0.95, "Kirklareli": 0.85, "Kirsehir": 0.95, "Kilis": 1.00,
    "Kocaeli": 0.95, "Konya": 1.00, "Kutahya": 0.95, "Malatya": 1.50,
    "Manisa": 0.95, "Mardin": 1.10, "Mersin": 0.95, "Mugla": 0.90,
    "Mus": 1.10, "Nevsehir": 0.95, "Nigde": 0.95, "Ordu": 0.90,
    "Osmaniye": 1.00, "Rize": 0.85, "Sakarya": 0.95, "Samsun": 0.95,
    "Sanliurfa": 1.05, "Siirt": 1.10, "Sinop": 0.90, "Sivas": 3.95,
    "Sirnak": 1.15, "Tekirdag": 0.85, "Tokat": 0.95, "Trabzon": 0.95,
    "Tunceli": 1.05, "Usak": 0.95, "Van": 1.10, "Yalova": 0.95,
    "Yozgat": 0.95, "Zonguldak": 0.95,
  };

  static const Map<String, double> tip = {
    "Adana": 1.33, "Adiyaman": 0.10, "Afyon": 0.18, "Agri": 0.12,
    "Aksaray": 0.20, "Amasya": 0.26, "Ankara-1": 0.69, "Ankara-2": 0.99,
    "Ankara-3": 1.43, "Antalya": 1.10, "Ardahan": 0.92, "Artvin": 0.90,
    "Aydin": 1.20, "Balikesir": 0.73, "Bartin": 0.95, "Batman": 0.21,
    "Bayburt": 0.17, "Bilecik": 0.88, "Bingol": 0.50, "Bitlis": 2.24,
    "Bolu": 0.91, "Burdur": 0.78, "Bursa-1": 0.81, "Bursa-2": 0.70,
    "Canakkale": 0.75, "Cankiri": 0.15, "Corum": 0.25, "Denizli": 0.62,
    "Diyarbakir": 0.63, "Duzce": 0.30, "Edirne": 0.64, "Elazig": 0.31,
    "Erzincan": 0.19, "Erzurum": 0.09, "Eskisehir": 0.94, "Gaziantep": 0.41,
    "Giresun": 0.62, "Gumushane": 0.21, "Hakkari": 1.73, "Hatay": 3.25,
    "Igdir": 0.66, "Isparta": 0.05, "Istanbul-1": 3.59, "Istanbul-2": 2.13,
    "Istanbul-3": 2.16, "Izmir-1": 2.81, "Izmir-2": 3.14, "Kahramanmaras": 0.06,
    "Karabuk": 0.24, "Karaman": 0.21, "Kars": 0.42, "Kastamonu": 0.52,
    "Kayseri": 0.27, "Kirikkale": 0.22, "Kirklareli": 1.03, "Kirsehir": 0.28,
    "Kilis": 0.05, "Kocaeli": 2.02, "Konya": 0.03, "Kutahya": 0.20,
    "Malatya": 0.21, "Manisa": 0.60, "Mardin": 0.35, "Mersin": 1.17,
    "Mugla": 1.08, "Mus": 0.12, "Nevsehir": 0.27, "Nigde": 0.15,
    "Ordu": 0.25, "Osmaniye": 0.20, "Rize": 0.22, "Sakarya": 0.35,
    "Samsun": 0.40, "Sanliurfa": 0.09, "Siirt": 0.08, "Sinop": 0.49,
    "Sivas": 0.36, "Sirnak": 0.83, "Tekirdag": 1.16, "Tokat": 0.02,
    "Trabzon": 0.04, "Tunceli": 1.11, "Usak": 0.25, "Van": 0.60,
    "Yalova": 0.62, "Yozgat": 0.16, "Zonguldak": 1.00,
  };

    static const Map<String, double> emep = {
    "Adana": 1.33, "Adiyaman": 0.10, "Afyon": 0.18, "Agri": 0.12,
    "Aksaray": 0.20, "Amasya": 0.26, "Ankara-1": 0.69, "Ankara-2": 0.99,
    "Ankara-3": 1.43, "Antalya": 1.10, "Ardahan": 0.92, "Artvin": 0.90,
    "Aydin": 1.20, "Balikesir": 0.73, "Bartin": 0.95, "Batman": 0.21,
    "Bayburt": 0.17, "Bilecik": 0.88, "Bingol": 0.50, "Bitlis": 2.24,
    "Bolu": 0.91, "Burdur": 0.78, "Bursa-1": 0.81, "Bursa-2": 0.70,
    "Canakkale": 0.75, "Cankiri": 0.15, "Corum": 0.25, "Denizli": 0.62,
    "Diyarbakir": 0.63, "Duzce": 0.30, "Edirne": 0.64, "Elazig": 0.31,
    "Erzincan": 0.19, "Erzurum": 0.09, "Eskisehir": 0.94, "Gaziantep": 0.41,
    "Giresun": 0.62, "Gumushane": 0.21, "Hakkari": 1.73, "Hatay": 3.25,
    "Igdir": 0.66, "Isparta": 0.05, "Istanbul-1": 3.59, "Istanbul-2": 2.13,
    "Istanbul-3": 2.16, "Izmir-1": 2.81, "Izmir-2": 3.14, "Kahramanmaras": 0.06,
    "Karabuk": 0.24, "Karaman": 0.21, "Kars": 0.42, "Kastamonu": 0.52,
    "Kayseri": 0.27, "Kirikkale": 0.22, "Kirklareli": 1.03, "Kirsehir": 0.28,
    "Kilis": 0.05, "Kocaeli": 2.02, "Konya": 0.03, "Kutahya": 0.20,
    "Malatya": 0.21, "Manisa": 0.60, "Mardin": 0.35, "Mersin": 1.17,
    "Mugla": 1.08, "Mus": 0.12, "Nevsehir": 0.27, "Nigde": 0.15,
    "Ordu": 0.25, "Osmaniye": 0.20, "Rize": 0.22, "Sakarya": 0.35,
    "Samsun": 0.40, "Sanliurfa": 0.09, "Siirt": 0.08, "Sinop": 0.49,
    "Sivas": 0.36, "Sirnak": 0.83, "Tekirdag": 1.16, "Tokat": 0.02,
    "Trabzon": 0.04, "Tunceli": 4.21, "Usak": 0.25, "Van": 0.60,
    "Yalova": 0.62, "Yozgat": 0.16, "Zonguldak": 1.00,
  };

      static const Map<String, double> sol = {
    "Adana": 1.33, "Adiyaman": 0.10, "Afyon": 0.18, "Agri": 0.12,
    "Aksaray": 0.20, "Amasya": 0.26, "Ankara-1": 0.69, "Ankara-2": 0.99,
    "Ankara-3": 1.43, "Antalya": 1.10, "Ardahan": 0.92, "Artvin": 0.90,
    "Aydin": 1.20, "Balikesir": 0.73, "Bartin": 0.95, "Batman": 0.21,
    "Bayburt": 0.17, "Bilecik": 0.88, "Bingol": 0.50, "Bitlis": 2.24,
    "Bolu": 0.91, "Burdur": 0.78, "Bursa-1": 0.81, "Bursa-2": 0.70,
    "Canakkale": 0.75, "Cankiri": 0.15, "Corum": 0.25, "Denizli": 0.62,
    "Diyarbakir": 0.63, "Duzce": 0.30, "Edirne": 0.64, "Elazig": 0.31,
    "Erzincan": 0.19, "Erzurum": 0.09, "Eskisehir": 0.94, "Gaziantep": 0.41,
    "Giresun": 0.62, "Gumushane": 0.21, "Hakkari": 1.73, "Hatay": 3.25,
    "Igdir": 0.66, "Isparta": 0.05, "Istanbul-1": 3.59, "Istanbul-2": 2.13,
    "Istanbul-3": 2.16, "Izmir-1": 2.81, "Izmir-2": 3.14, "Kahramanmaras": 0.06,
    "Karabuk": 0.24, "Karaman": 0.21, "Kars": 0.42, "Kastamonu": 0.52,
    "Kayseri": 0.27, "Kirikkale": 0.22, "Kirklareli": 1.03, "Kirsehir": 0.28,
    "Kilis": 0.05, "Kocaeli": 2.02, "Konya": 0.03, "Kutahya": 0.20,
    "Malatya": 0.21, "Manisa": 0.60, "Mardin": 0.35, "Mersin": 1.17,
    "Mugla": 1.08, "Mus": 0.12, "Nevsehir": 0.27, "Nigde": 0.15,
    "Ordu": 0.25, "Osmaniye": 0.20, "Rize": 0.22, "Sakarya": 0.35,
    "Samsun": 0.40, "Sanliurfa": 0.09, "Siirt": 0.08, "Sinop": 0.49,
    "Sivas": 0.36, "Sirnak": 0.83, "Tekirdag": 1.16, "Tokat": 0.02,
    "Trabzon": 0.04, "Tunceli": 4.21, "Usak": 0.25, "Van": 0.60,
    "Yalova": 0.62, "Yozgat": 0.16, "Zonguldak": 1.00,
  };

  static const Map<String, double> anahtar = {
    "Adana": 1.09, "Adiyaman": 0.44, "Afyon": 1.59, "Agri": 0.08,
    "Aksaray": 2.08, "Amasya": 1.66, "Ankara-1": 1.28, "Ankara-2": 1.19,
    "Ankara-3": 1.07, "Antalya": 1.03, "Ardahan": 0.32, "Artvin": 0.96,
    "Aydin": 0.86, "Balikesir": 0.81, "Bartin": 2.34, "Batman": 0.84,
    "Bayburt": 1.65, "Bilecik": 1.03, "Bingol": 0.04, "Bitlis": 0.06,
    "Bolu": 2.31, "Burdur": 1.39, "Bursa-1": 0.80, "Bursa-2": 0.93,
    "Canakkale": 0.66, "Cankiri": 3.11, "Corum": 2.00, "Denizli": 0.84,
    "Diyarbakir": 0.04, "Duzce": 1.60, "Edirne": 0.77, "Elazig": 1.10,
    "Erzincan": 1.95, "Erzurum": 1.65, "Eskisehir": 0.76, "Gaziantep": 0.96,
    "Giresun": 1.55, "Gumushane": 2.62, "Hakkari": 0.08, "Hatay": 1.26,
    "Igdir": 0.44, "Isparta": 2.06, "Istanbul-1": 0.65, "Istanbul-2": 0.58,
    "Istanbul-3": 0.66, "Izmir-1": 0.51, "Izmir-2": 0.58, "Kahramanmaras": 1.62,
    "Karabuk": 1.58, "Karaman": 1.79, "Kars": 0.53, "Kastamonu": 1.89,
    "Kayseri": 1.89, "Kirikkale": 2.15, "Kirklareli": 0.48, "Kirsehir": 1.47,
    "Kilis": 2.63, "Kocaeli": 0.84, "Konya": 1.42, "Kutahya": 1.29,
    "Malatya": 1.28, "Manisa": 1.43, "Mardin": 0.35, "Mersin": 1.19,
    "Mugla": 0.62, "Mus": 1.65, "Nevsehir": 2.01, "Nigde": 2.26,
    "Ordu": 1.26, "Osmaniye": 1.83, "Rize": 1.29, "Sakarya": 1.19,
    "Samsun": 1.19, "Sanliurfa": 0.94, "Siirt": 0.39, "Sinop": 0.91,
    "Sivas": 1.99, "Sirnak": 0.24, "Tekirdag": 0.64, "Tokat": 2.19,
    "Trabzon": 1.05, "Tunceli": 0.56, "Usak": 0.93, "Van": 0.09,
    "Yalova": 1.13, "Yozgat": 2.31, "Zonguldak": 0.86,
  };

  static const Map<String, double> gelecek = {
    "Adana": 0.64, "Adiyaman": 1.71, "Afyon": 1.05, "Agri": 1.96,
    "Aksaray": 0.93, "Amasya": 0.64, "Ankara-1": 0.46, "Ankara-2": 1.24,
    "Ankara-3": 0.98, "Antalya": 0.45, "Ardahan": 0.36, "Artvin": 0.85,
    "Aydin": 0.27, "Balikesir": 0.74, "Bartin": 0.64, "Batman": 0.40,
    "Bayburt": 1.06, "Bilecik": 1.19, "Bingol": 4.88, "Bitlis": 1.05,
    "Bolu": 0.27, "Burdur": 0.44, "Bursa-1": 1.14, "Bursa-2": 1.45,
    "Canakkale": 0.70, "Cankiri": 0.36, "Corum": 1.18, "Denizli": 0.49,
    "Diyarbakir": 0.79, "Duzce": 1.38, "Edirne": 0.25, "Elazig": 1.30,
    "Erzincan": 0.52, "Erzurum": 1.77, "Eskisehir": 0.51, "Gaziantep": 1.47,
    "Giresun": 0.89, "Gumushane": 0.96, "Hakkari": 0.65, "Hatay": 0.66,
    "Igdir": 1.57, "Isparta": 0.66, "Istanbul-1": 1.06, "Istanbul-2": 1.37,
    "Istanbul-3": 1.12, "Izmir-1": 0.30, "Izmir-2": 0.34, "Kahramanmaras": 1.95,
    "Karabuk": 2.95, "Karaman": 0.85, "Kars": 0.93, "Kastamonu": 1.45,
    "Kayseri": 1.25, "Kirikkale": 0.66, "Kirklareli": 0.24, "Kirsehir": 0.58,
    "Kilis": 0.84, "Kocaeli": 2.07, "Konya": 1.82, "Kutahya": 2.53,
    "Malatya": 3.31, "Manisa": 0.56, "Mardin": 0.41, "Mersin": 0.33,
    "Mugla": 0.23, "Mus": 1.20, "Nevsehir": 0.72, "Nigde": 0.94,
    "Ordu": 0.82, "Osmaniye": 0.71, "Rize": 1.81, "Sakarya": 1.42,
    "Samsun": 1.43, "Sanliurfa": 2.10, "Siirt": 0.85, "Sinop": 0.81,
    "Sivas": 1.23, "Sirnak": 0.62, "Tekirdag": 0.57, "Tokat": 0.91,
    "Trabzon": 1.62, "Tunceli": 0.09, "Usak": 0.51, "Van": 1.13,
    "Yalova": 0.76, "Yozgat": 1.58, "Zonguldak": 0.67,
  };

  static const Map<String, double> deva = {
    "Adana": 0.64, "Adiyaman": 1.71, "Afyon": 1.05, "Agri": 1.96,
    "Aksaray": 0.93, "Amasya": 0.64, "Ankara-1": 0.46, "Ankara-2": 1.24,
    "Ankara-3": 0.98, "Antalya": 0.45, "Ardahan": 0.36, "Artvin": 0.85,
    "Aydin": 0.27, "Balikesir": 0.74, "Bartin": 0.64, "Batman": 0.40,
    "Bayburt": 1.06, "Bilecik": 1.19, "Bingol": 4.88, "Bitlis": 1.05,
    "Bolu": 0.27, "Burdur": 0.44, "Bursa-1": 1.14, "Bursa-2": 1.45,
    "Canakkale": 0.70, "Cankiri": 0.36, "Corum": 1.18, "Denizli": 0.49,
    "Diyarbakir": 0.79, "Duzce": 1.38, "Edirne": 0.25, "Elazig": 1.30,
    "Erzincan": 0.52, "Erzurum": 1.77, "Eskisehir": 0.51, "Gaziantep": 1.47,
    "Giresun": 0.89, "Gumushane": 0.96, "Hakkari": 0.65, "Hatay": 0.66,
    "Igdir": 1.57, "Isparta": 0.66, "Istanbul-1": 1.06, "Istanbul-2": 1.37,
    "Istanbul-3": 1.12, "Izmir-1": 0.30, "Izmir-2": 0.34, "Kahramanmaras": 1.95,
    "Karabuk": 2.95, "Karaman": 0.85, "Kars": 0.93, "Kastamonu": 1.45,
    "Kayseri": 1.25, "Kirikkale": 0.66, "Kirklareli": 0.24, "Kirsehir": 0.58,
    "Kilis": 0.84, "Kocaeli": 2.07, "Konya": 1.82, "Kutahya": 2.53,
    "Malatya": 3.31, "Manisa": 0.56, "Mardin": 0.41, "Mersin": 0.33,
    "Mugla": 0.23, "Mus": 1.20, "Nevsehir": 0.72, "Nigde": 0.94,
    "Ordu": 0.82, "Osmaniye": 0.71, "Rize": 1.81, "Sakarya": 1.42,
    "Samsun": 1.43, "Sanliurfa": 2.10, "Siirt": 0.85, "Sinop": 0.81,
    "Sivas": 1.23, "Sirnak": 0.62, "Tekirdag": 0.57, "Tokat": 0.91,
    "Trabzon": 1.62, "Tunceli": 0.09, "Usak": 0.51, "Van": 1.13,
    "Yalova": 0.76, "Yozgat": 1.58, "Zonguldak": 0.67,
  };

  static const Map<String, double> diger = {
    "Adana": 1.0, "Adiyaman": 1.0, "Afyonkarahisar": 1.0, "Agri": 1.0,
    "Aksaray": 1.0, "Amasya": 1.0, "Ankara-1": 0.95, "Ankara-2": 0.90, "Ankara-3": 0.95,
    "Antalya": 1.0, "Ardahan": 1.0, "Artvin": 1.0, "Aydin": 1.0,
    "Balikesir": 1.0, "Bartin": 1.0, "Batman": 1.0, "Bayburt": 1.0,
    "Bilecik": 1.0, "Bingol": 1.0, "Bitlis": 1.0, "Bolu": 1.0,
    "Burdur": 1.0, "Bursa-1": 0.95, "Bursa-2": 0.90,
    "Canakkale": 1.0, "Cankiri": 1.0, "Corum": 1.0, "Denizli": 1.0,
    "Diyarbakir": 1.0, "Duzce": 1.0, "Edirne": 1.0, "Elazig": 1.0,
    "Erzincan": 1.0, "Erzurum": 1.0, "Eskisehir": 1.0, "Gaziantep": 1.0,
    "Giresun": 1.0, "Gumushane": 1.0, "Hakkari": 1.0, "Hatay": 1.0,
    "Igdir": 1.0, "Isparta": 1.0, "Istanbul-1": 0.85, "Istanbul-2": 0.80, "Istanbul-3": 0.85,
    "Izmir-1": 1.05, "Izmir-2": 1.10, "Kahramanmaras": 1.0, "Karabuk": 1.0,
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
final Map<String, double> tipStrength = PartyStrengths.tip;
final Map<String, double> emepStrength = PartyStrengths.emep;
final Map<String, double> solStrength = PartyStrengths.sol;
final Map<String, double> anahtarStrength = PartyStrengths.anahtar;
final Map<String, double> gelecekStrength = PartyStrengths.gelecek;
final Map<String, double> devaStrength = PartyStrengths.deva;
final Map<String, double> otherStrength = PartyStrengths.diger;

/// İl adını (ve varsa seçim bölgesi numarasını) güç katsayısı anahtarına çevirir
/// Örn: ("İstanbul", "İstanbul 2. Bölge", "34_2") -> "Istanbul-2"
String strengthKeyForRegion(String city, String regionName, {String? regionId}) {
  final asciiCity = _asciiCity(city);

  // Önce bölge adındaki numarayı dene
  final nameMatch = RegExp(r'(\\d+)').firstMatch(regionName);
  if (nameMatch != null) {
    return "$asciiCity-${nameMatch.group(1)}";
  }

  // Olmazsa id içinden numara çek (örn: 34_2 -> 2)
  if (regionId != null) {
    final idMatch = RegExp(r'_(\\d+)').firstMatch(regionId);
    if (idMatch != null) {
      return "$asciiCity-${idMatch.group(1)}";
    }
  }

  // Tek bölge ise sadece şehir adı
  return asciiCity;
}

String _asciiCity(String city) {
  const replacements = {
    'Ç': 'C', 'ç': 'c',
    'Ğ': 'G', 'ğ': 'g',
    'İ': 'I', 'I': 'I', 'ı': 'i',
    'Ö': 'O', 'ö': 'o',
    'Ş': 'S', 'ş': 's',
    'Ü': 'U', 'ü': 'u',
    'Â': 'A', 'â': 'a',
  };

  final buffer = StringBuffer();
  for (final char in city.runes) {
    final ch = String.fromCharCode(char);
    buffer.write(replacements[ch] ?? ch);
  }
  return buffer.toString();
}

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

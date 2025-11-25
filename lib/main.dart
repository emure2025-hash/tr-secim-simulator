import 'package:flutter/material.dart';
import 'map_page.dart';
import 'regions.dart';
import 'dhondt.dart';

void main() {
  runApp(const SecimApp());
}

class SecimApp extends StatelessWidget {
  const SecimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TR Seçim Simülatörü",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainController(),
    );
  }
}

/// ------------------------------------------------------------
/// Bu widget tüm uygulamanın yöneticisi.
/// Açılışta haritayı gösterir.
/// "Oy Oranlarını Gir" ekranından gelen sonucu tekrar MapPage'e gönderir.
/// ------------------------------------------------------------
class MainController extends StatefulWidget {
  const MainController({super.key});

  @override
  State<MainController> createState() => _MainControllerState();
}

class _MainControllerState extends State<MainController> {
  /// Henüz sonuç yok → harita gri gözükecek
  Map<String, int>? finalResult;

  /// Kullanıcı oy oranlarını girdiğinde burası güncellenecek
  void updateResult(Map<String, int> r) {
    setState(() {
      finalResult = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Harita daima ana ekranda
      body: MapPage(
        result: finalResult ?? {}, // boş ise gri harita
      ),

      /// Sağ alt buton → oy oranı ekranına gider
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VoteInputPage(),
            ),
          );

          /// VoteInputPage bir sonuç döndürürse haritayı renklendir
          if (result != null && result is Map<String, int>) {
            updateResult(result);
          }
        },
        label: const Text("Oy Oranlarını Gir"),
        icon: const Icon(Icons.settings),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// OY ORANLARI SAYFASI (Slider ekranı)
/// Daha profesyonel bir ekranı sonra tasarlarız.
/// Şimdilik basit, temiz ve çalışır.
/// ------------------------------------------------------------
class VoteInputPage extends StatefulWidget {
  @override
  State<VoteInputPage> createState() => _VoteInputPageState();
}

class PartyInput {
  String name;
  double vote;
  PartyInput(this.name, this.vote);
}

class _VoteInputPageState extends State<VoteInputPage> {
  List<PartyInput> parties = [
    PartyInput("CHP", 30),
    PartyInput("AKP", 28),
    PartyInput("MHP", 8),
    PartyInput("İYİ Parti", 7),
    PartyInput("HDP/DEM", 10),
    PartyInput("Diğer", 17),
  ];

  double threshold = 7.0;

  double get totalVotes =>
      parties.fold(0.0, (sum, p) => sum + p.vote);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Oy Oranları")),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...parties.map((p) => partySlider(p)).toList(),

          const SizedBox(height: 20),

          Text(
            "TOPLAM: %${totalVotes.toStringAsFixed(1)}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: totalVotes == 100 ? Colors.green : Colors.red,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "Baraj: %${threshold.toStringAsFixed(1)}",
            style: const TextStyle(fontSize: 18),
          ),
          Slider(
            value: threshold,
            min: 0,
            max: 20,
            divisions: 20,
            label: "%${threshold.toStringAsFixed(1)}",
            onChanged: (v) {
              setState(() => threshold = v);
            },
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: totalVotes == 100
                ? () {
                    /// Partilerin oy oranlarını almamız
                    final national = {
                      for (var p in parties) p.name: p.vote,
                    };

                    /// D’Hondt motorundan ulusal 600 MV dağılımı
                    final result = calculateDhondt(
                      national,
                      threshold,
                    );

                    /// Bu sayfayı kapat → sonucu geri gönder
                    Navigator.pop(context, result);
                  }
                : null,
            child: const Text("Simülasyonu Çalıştır"),
          ),
        ],
      ),
    );
  }

  Widget partySlider(PartyInput p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          p.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: p.vote,
          min: 0,
          max: 60,
          label: p.vote.toStringAsFixed(1),
          onChanged: (v) => setState(() => p.vote = v),
        ),
        Text("%${p.vote.toStringAsFixed(1)}"),
        const Divider(),
      ],
    );
  }
}

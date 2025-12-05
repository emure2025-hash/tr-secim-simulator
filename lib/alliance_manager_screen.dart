import 'package:flutter/material.dart';
import 'alliance.dart';
import 'color_engine.dart';

class AllianceManagerScreen extends StatefulWidget {
  final List<String> allParties;
  final List<Alliance> currentAlliances;
  final Function(List<Alliance>) onSave;

  const AllianceManagerScreen({
    super.key,
    required this.allParties,
    required this.currentAlliances,
    required this.onSave,
  });

  @override
  State<AllianceManagerScreen> createState() => _AllianceManagerScreenState();
}

class _AllianceManagerScreenState extends State<AllianceManagerScreen> {
  late List<Alliance> alliances;
  Set<String> usedParties = {};

  @override
  void initState() {
    super.initState();
    alliances = List.from(widget.currentAlliances);
    _updateUsedParties();
  }

  void _updateUsedParties() {
    usedParties.clear();
    for (final alliance in alliances) {
      usedParties.addAll(alliance.parties);
    }
  }

  void _createAlliance() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Yeni İttifak Oluştur"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "İttifak Adı",
            hintText: "örn: Cumhur İttifakı",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  alliances.add(Alliance(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    parties: [],
                  ));
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Oluştur"),
          ),
        ],
      ),
    );
  }

  void _deleteAlliance(int index) {
    setState(() {
      alliances.removeAt(index);
      _updateUsedParties();
    });
  }

  void _addPartyToAlliance(int allianceIndex, String party) {
    setState(() {
      alliances[allianceIndex] = alliances[allianceIndex].copyWith(
        parties: [...alliances[allianceIndex].parties, party],
      );
      _updateUsedParties();
    });
  }

  void _removePartyFromAlliance(int allianceIndex, String party) {
    setState(() {
      final newParties = List<String>.from(alliances[allianceIndex].parties)
        ..remove(party);
      alliances[allianceIndex] = alliances[allianceIndex].copyWith(
        parties: newParties,
      );
      _updateUsedParties();
    });
  }

  List<String> get availableParties =>
      widget.allParties.where((p) => !usedParties.contains(p)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("İttifak Yönetimi"),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              widget.onSave(alliances);
              Navigator.pop(context);
            },
            tooltip: "Kaydet",
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kullanılabilir Partiler
          if (availableParties.isNotEmpty)
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "İttifaksız Partiler (${availableParties.length})",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableParties.map((party) {
                        return Chip(
                          label: Text(party),
                          backgroundColor: colorForParty(party).withOpacity(0.2),
                          avatar: CircleAvatar(
                            backgroundColor: colorForParty(party),
                            radius: 8,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // İttifaklar
          ...alliances.asMap().entries.map((entry) {
            final index = entry.key;
            final alliance = entry.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alliance.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAlliance(index),
                          tooltip: "İttifakı Sil",
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // İttifaktaki Partiler
                    if (alliance.parties.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange),
                            SizedBox(width: 8),
                            Text("Bu ittifakta henüz parti yok"),
                          ],
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: alliance.parties.map((party) {
                          return Chip(
                            label: Text(party),
                            backgroundColor:
                                colorForParty(party).withOpacity(0.2),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => _removePartyFromAlliance(index, party),
                            avatar: CircleAvatar(
                              backgroundColor: colorForParty(party),
                              radius: 8,
                            ),
                          );
                        }).toList(),
                      ),

                    // Parti Ekle
                    if (availableParties.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("${alliance.name}'a Parti Ekle"),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: availableParties.map((party) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: colorForParty(party),
                                        radius: 12,
                                      ),
                                      title: Text(party),
                                      onTap: () {
                                        _addPartyToAlliance(index, party);
                                        Navigator.pop(context);
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("İptal"),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Parti Ekle"),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),

          // Yeni İttifak Oluştur
          ElevatedButton.icon(
            onPressed: _createAlliance,
            icon: const Icon(Icons.add),
            label: const Text("Yeni İttifak Oluştur"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/presentation/widgets/game_character.dart';

void main() {
  runApp(const ProviderScope(child: WardrobeSandboxApp()));
}

class WardrobeSandboxApp extends StatelessWidget {
  const WardrobeSandboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: Colors.grey.shade900,
      ),
      home: const SandboxScreen(),
    );
  }
}

class SandboxScreen extends StatefulWidget {
  const SandboxScreen({super.key});

  @override
  State<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends State<SandboxScreen> {
  Set<String> selectedItemIds = {'item_map_safari'};

  @override
  Widget build(BuildContext context) {
    final equipped = <String, String>{};
    for (final id in selectedItemIds) {
      try {
        final item = InventoryConfig.allItems.firstWhere((i) => i.id == id);
        equipped[item.slot] = item.id;
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Garderob Preview (Hot Reload redo)')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kontroller till vänster
            Container(
              width: 320,
              color: Colors.white10,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Välj föremål att testa', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Rensa alla', style: TextStyle(color: Colors.redAccent)),
                    leading: const Icon(Icons.clear, color: Colors.redAccent),
                    onTap: () => setState(() => selectedItemIds.clear()),
                  ),
                  const Divider(color: Colors.grey),
                  ...InventoryConfig.allItems.map((item) {
                    return CheckboxListTile(
                      title: Text('${item.name} (${item.slot})', style: const TextStyle(color: Colors.white)),
                      value: selectedItemIds.contains(item.id),
                      activeColor: Colors.greenAccent,
                      checkColor: Colors.black,
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) {
                            selectedItemIds.add(item.id);
                          } else {
                            selectedItemIds.remove(item.id);
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 32),
                  const Text('Så här gör du:', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('1. Håll det här fönstret öppet.\n2. Ändra renderScale och offset i inventory_item.dart i VS Code.\n3. Spara filen (Ctrl+S)\n4. Klart! Bilden uppdateras i realtid.', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            // Karaktär till höger
            Expanded(
              child: Center(
                child: Container(
                  height: 400,
                  width: 400,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green, width: 4),
                  ),
                  child: Center(
                    child: GameCharacter(
                      height: 250,
                      equippedItems: equipped,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

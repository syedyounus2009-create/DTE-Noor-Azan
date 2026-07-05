import 'package:flutter/material.dart';

/// V1 placeholder per architecture doc section 10.4 — UI shell is real;
/// the Overpass API integration is the next task (see README "What's
/// stubbed"). Keeping the screen wired into the router now means the
/// data layer can be dropped in later without touching navigation.
class MosquesScreen extends StatelessWidget {
  const MosquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby mosques'),
        actions: [
          IconButton(icon: const Icon(Icons.map_outlined), onPressed: () {}),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Mosque search connects to the Overpass API (OpenStreetMap) — '
            'wiring this up is the next task after this V1 shell.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

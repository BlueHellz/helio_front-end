import 'package:flutter/material.dart';
import 'package:kooyoh_app/core/content/content_registry.dart';

class WhitepaperPage extends StatelessWidget {
  const WhitepaperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(WhitepaperContent.pageTitle)),
      body: const Center(child: Text(WhitepaperContent.body)),
    );
  }
}

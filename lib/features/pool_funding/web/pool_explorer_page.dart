import 'package:flutter/material.dart';
import 'package:blacklight_app/core/content/content_registry.dart';

class PoolExplorerPage extends StatelessWidget {
  const PoolExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(PoolFundingContent.explorerTitle)),
      body: const Center(child: Text(PoolFundingContent.comingSoon)),
    );
  }
}

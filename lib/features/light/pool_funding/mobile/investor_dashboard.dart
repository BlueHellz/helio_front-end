import 'package:flutter/material.dart';
import 'package:blacklight_app/core/content/content_registry.dart';

class InvestorDashboard extends StatelessWidget {
  const InvestorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text(PoolFundingContent.investorDashboardTitle)),
      body: const Center(child: Text(PoolFundingContent.comingSoon)),
    );
  }
}

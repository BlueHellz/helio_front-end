import 'package:kooyoh_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';

/// Bottom navigation shell for authenticated homeowner (mobile).
class MobileHomeownerShell extends StatelessWidget {
  const MobileHomeownerShell({
    super.key,
    required this.activeIndex,
    required this.onNavTap,
    required this.child,
  });

  final int activeIndex;
  final ValueChanged<int> onNavTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: activeIndex,
        onDestinationSelected: onNavTap,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            label: NavigationContent.mobileProjects,
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_circle_outline),
            label: NavigationContent.mobileNew,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            label: HomeownerChatContent.pageTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: NavigationContent.mobileSettings,
          ),
        ],
      ),
    );
  }
}

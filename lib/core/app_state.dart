import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/project.dart';
import 'models/chat_message.dart';

// ─────────────────────────────────────────────
// Premium (XEÍTI) shell — UI/UX app state.
// Holds only the in-memory state required for navigation and form state.
// All real data (users, projects, transactions, leads, wallets, etc.)
// will come from the backend layer when wired.
// ─────────────────────────────────────────────

enum UserRole {
  homeowner,
  organization,
  none,
}

class BlackLightAppState extends ChangeNotifier {
  // Identity (filled by backend on sign-in)
  UserRole _role = UserRole.none;
  bool _isAuthenticated = false;
  String _userName = '';
  String _companyName = '';

  // Wallet (filled by wallet provider on connect)
  double _gueyBalance = 0.0;
  String? _walletAddress;

  // Navigation indices (UI-only)
  int _webSidebarIndex = 0;
  int _mobileNavIndex = 0;

  // Collections — empty until backend provides data
  final List<Project> _projects = [];
  final List<ChatMessage> _chatMessages = [];

  // Getters
  UserRole get role => _role;
  bool get isAuthenticated => _isAuthenticated;
  String get userName => _userName;
  String get companyName => _companyName;
  double get gueyBalance => _gueyBalance;
  String? get walletAddress => _walletAddress;
  int get webSidebarIndex => _webSidebarIndex;
  int get mobileNavIndex => _mobileNavIndex;
  List<Project> get projects => List.unmodifiable(_projects);
  List<ChatMessage> get chatMessages => List.unmodifiable(_chatMessages);

  // Auth — called by the auth screen with whatever the form / backend produced.
  // No defaults: empty inputs stay empty so we never render placeholder data.
  void signIn({
    required UserRole role,
    String name = '',
    String companyName = '',
  }) {
    _role = role;
    _isAuthenticated = true;
    _userName = name;
    _companyName = companyName;
    _webSidebarIndex = 0;
    _mobileNavIndex = 0;
    notifyListeners();
  }

  void signOut() {
    _role = UserRole.none;
    _isAuthenticated = false;
    _userName = '';
    _companyName = '';
    _gueyBalance = 0.0;
    _walletAddress = null;
    _projects.clear();
    _chatMessages.clear();
    notifyListeners();
  }

  // Navigation
  void setWebSidebarIndex(int index) {
    if (_webSidebarIndex != index) {
      _webSidebarIndex = index;
      notifyListeners();
    }
  }

  void setMobileNavIndex(int index) {
    if (_mobileNavIndex != index) {
      _mobileNavIndex = index;
      notifyListeners();
    }
  }

  // Projects
  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
  }

  // Chat
  void addChatMessage(ChatMessage message) {
    _chatMessages.add(message);
    notifyListeners();
  }

  void clearChat() {
    _chatMessages.clear();
    notifyListeners();
  }

  // Wallet — backend / wallet provider supplies the address.
  void connectWallet(String address) {
    if (address.isEmpty) return;
    _walletAddress = address;
    notifyListeners();
  }

  /// Local display name (until full profile API exists).
  void updateLocalProfile({String? userName, String? companyName}) {
    if (userName != null) _userName = userName;
    if (companyName != null) _companyName = companyName;
    notifyListeners();
  }
}

final blackLightAppStateProvider =
    ChangeNotifierProvider<BlackLightAppState>((ref) => BlackLightAppState());

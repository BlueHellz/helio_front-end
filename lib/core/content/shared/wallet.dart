// FILE: shared/wallet.dart
// Wallet chip, balance labels, and connect-wallet flows.

class WalletContent {
  /// Solana KOO-YOH Coin (KYH) — homeowner wallet balance after install / ledger sync.
  static const kyhBalanceLabel = 'KOO-YOH Coin balance';
  static const kyhTicker = 'KYH';
  static const demoBalanceAmount = '0.00';
  static const connectWallet = 'Connect Wallet';
  static const connectShort = 'Connect';
  static const manageWallet = 'Manage';
  static const landingWalletSnack =
      'Connect a wallet from your account page after you sign in.';

  static const dialogConnectWalletTitle = 'Connect wallet';
  static const dialogConnectWalletBody =
      'Enter a devnet or demo wallet address to save in this session. '
      'The full flow will use your real wallet with the app.';
  static const dialogWalletAddressHint =
      'e.g. 4Nd1...8pYq (Solana address)';
}

/// Placeholder copy for the native L1 GUEY Coin (EV charging and energy markets).
/// Balances are not shown in UI until backend support exists.
class GueyCoinContent {
  static const displayName = 'GUEY Coin';
  static const ticker = 'GUEY';
}

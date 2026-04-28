// FILE: shared/wallet.dart
// Wallet chip, balance labels, and connect-wallet flows.

class WalletContent {
  static const hlioBalanceLabel = 'HLIO Balance';
  static const hlioTicker = 'HLIO';
  static const demoBalanceAmount = '0.00';
  static const connectWallet = 'Connect Wallet';
  static const connectShort = 'Connect';
  static const manageWallet = 'Manage';
  static const landingWalletSnack =
      'Use Sign In to create an account. You can connect a wallet from your dashboard after you log in.';

  static const dialogConnectWalletTitle = 'Connect wallet';
  static const dialogConnectWalletBody =
      'Enter a devnet or demo wallet address to save in this session. '
      'The full flow will use your real wallet with the app.';
  static const dialogWalletAddressHint =
      'e.g. 4Nd1...8pYq (Solana address)';
}

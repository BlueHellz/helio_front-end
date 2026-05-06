// AI chat — save rooftop design delivery to homeowner email.

class DesignSaveEmailContent {
  DesignSaveEmailContent._();

  static const saveEmailDesignCta = 'Save & Email My Design';

  static const modalTitle =
      'Please enter your email to receive the design.';

  static const sendAction = 'Send';

  /// Snackbar after backend accepts delivery.
  static const successSnack = 'Design sent to your email!';

  /// When POST fails or payload is incomplete.
  static const sendFailed =
      'We couldn\'t email your design right now. Please try again.';
}

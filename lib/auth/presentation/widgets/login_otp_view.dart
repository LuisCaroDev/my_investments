import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class LoginOtpView extends StatelessWidget {
  final TextEditingController otpController;
  final bool isLoading;
  final String currentEmail;
  final VoidCallback onRequestOtp;
  final Function(String) onVerifyOtp;

  const LoginOtpView({
    super.key,
    required this.otpController,
    required this.isLoading,
    required this.currentEmail,
    required this.onRequestOtp,
    required this.onVerifyOtp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              RadixIcons.envelopeClosed,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const Gap(24),
        Text(
          l10n.auth_otp_view_title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const Gap(8),
        Text(
          l10n.auth_otp_view_subtitle(currentEmail),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.mutedForeground,
            fontSize: 16,
          ),
        ),
        const Gap(32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              RadixIcons.checkCircled,
              size: 16,
              color: theme.colorScheme.mutedForeground,
            ),
            const Gap(8),
            Text(
              l10n.auth_otp_label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
        const Gap(16),
        Center(
          child: InputOTP(
            children: [
              InputOTPChild.character(allowDigit: true),
              InputOTPChild.character(allowDigit: true),
              InputOTPChild.character(allowDigit: true),
              InputOTPChild.character(allowDigit: true),
              InputOTPChild.separator,
              InputOTPChild.character(allowDigit: true),
              InputOTPChild.character(allowDigit: true),
              InputOTPChild.character(allowDigit: true),
              InputOTPChild.character(allowDigit: true),
            ],
            onChanged: (code) {
              final textCode = code.otpToString();
              otpController.text = textCode;
              if (textCode.length == 8 && !isLoading) {
                onVerifyOtp(currentEmail);
              }
            },
          ),
        ),
        const Gap(8),
        Text(
          l10n.auth_otp_helper,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const Gap(32),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: otpController,
          builder: (context, value, child) {
            final isOtpFull = value.text.length == 8;
            return PrimaryButton(
              onPressed: (isLoading || !isOtpFull)
                  ? null
                  : () => onVerifyOtp(currentEmail),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    Text(l10n.auth_otp_verify_button),
                ],
              ),
            );
          },
        ),
        const Gap(24),
        GhostButton(
          onPressed: isLoading ? null : () => onRequestOtp(),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(RadixIcons.update, size: 16),
              const Gap(8),
              Text(l10n.auth_otp_resend_button),
            ],
          ),
        ),
        const Gap(8),
        Text(
          l10n.auth_otp_spam_helper,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }
}

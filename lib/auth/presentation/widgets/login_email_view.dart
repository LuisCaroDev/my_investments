import 'package:flutter/gestures.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:my_investments/l10n/app_localizations.dart';

class LoginEmailView extends StatelessWidget {
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onRequestOtp;
  final VoidCallback onTermsOfServiceTap;
  final VoidCallback onPrivacyPolicyTap;

  const LoginEmailView({
    super.key,
    required this.emailController,
    required this.isLoading,
    required this.onRequestOtp,
    required this.onTermsOfServiceTap,
    required this.onPrivacyPolicyTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(l10n.auth_email_view_title, style: theme.typography.h4),
        const Gap(8),
        Text(
          l10n.auth_email_view_subtitle,
          style: theme.typography.small.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(32),
        Text(
          l10n.auth_email_label,
          style: TextStyle(color: theme.colorScheme.mutedForeground),
        ).xSmall.bold,
        const Gap(8),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          placeholder: Text(l10n.auth_email_placeholder),
          enabled: !isLoading,
          onSubmitted: (_) => onRequestOtp(),
        ),
        const Gap(8),
        Text(
          l10n.auth_email_helper,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const Gap(24),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: emailController,
          builder: (context, value, child) {
            final isEmailNotEmpty = value.text.trim().isNotEmpty;
            return PrimaryButton(
              enabled: isEmailNotEmpty && !isLoading,
              onPressed: onRequestOtp,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    CircularProgressIndicator(
                      color: isLoading
                          ? theme.colorScheme.muted
                          : theme.colorScheme.primaryForeground,
                    )
                  else ...[
                    Text(l10n.auth_email_send_button),
                    const Gap(8),
                    const Icon(RadixIcons.arrowRight, size: 16),
                  ],
                ],
              ),
            );
          },
        ),
        const Gap(32),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                l10n.auth_continue_with,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const Gap(24),
        OutlineButton(
          onPressed: null, // Disabled
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(l10n.auth_continue_apple)],
          ),
        ),
        const Gap(16),
        OutlineButton(
          onPressed: null, // Disabled
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(l10n.auth_continue_google)],
          ),
        ),
        const Gap(48),
        _buildFooterTerms(context, l10n, theme),
      ],
    );
  }

  Widget _buildFooterTerms(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.mutedForeground,
        ),
        children: [
          TextSpan(text: l10n.auth_terms_prefix),
          TextSpan(
            text: l10n.auth_terms_service,
            style: TextStyle(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTermsOfServiceTap,
          ),
          TextSpan(text: l10n.auth_terms_and),
          TextSpan(
            text: l10n.auth_terms_privacy,
            style: TextStyle(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = onPrivacyPolicyTap,
          ),
          TextSpan(text: l10n.auth_terms_suffix),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

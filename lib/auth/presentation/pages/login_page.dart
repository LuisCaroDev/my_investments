import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_investments/core/widgets/responsive_container.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:my_investments/auth/presentation/bloc/auth_cubit.dart';
import 'package:my_investments/auth/presentation/bloc/auth_state.dart';
import 'package:my_investments/core/presentation/bloc/settings_cubit.dart';
import 'package:my_investments/core/widgets/app_back_button.dart';
import 'package:my_investments/auth/presentation/widgets/data_conflict_handler.dart';
import 'package:my_investments/auth/presentation/widgets/login_email_view.dart';
import 'package:my_investments/auth/presentation/widgets/login_otp_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_investments/auth/presentation/pages/home_gate.dart';
import 'package:my_investments/core/router/app_router.dart';
import 'package:my_investments/core/storage/profile_ids.dart';
import 'package:my_investments/l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  static const route = '/login';

  final bool fromSettings;

  const LoginPage({super.key, this.fromSettings = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpStep = false;
  bool _hasHandledAuth = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _requestOtp() {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    final locale = Localizations.localeOf(context).languageCode;
    context.read<AuthCubit>().requestOtp(email, data: {'lang': locale});
  }

  void _verifyOtp(String email) {
    final code = _otpController.text.trim();
    if (code.length < 8) return;
    context.read<AuthCubit>().verifyOtp(email, code);
  }

  Future<void> _handlePostAuthFlow(User user) async {
    if (_hasHandledAuth) return;
    _hasHandledAuth = true;

    // Show a loading dialog or just rely on the sync dialog overlaying.
    await DataConflictHandler.handleConflictOrSync(context, user);

    if (!mounted) return;
    await context.read<SettingsCubit>().setActiveProfileId(
      userProfileId(user.id),
    );
    await context.read<SettingsCubit>().setGuestMode(false);

    if (widget.fromSettings) {
      context.pop();
      final l10n = AppLocalizations.of(context)!;
      showToast(
        context: context,
        builder: (context, overlay) {
          return SurfaceCard(
            child: Basic(
              title: Text(l10n.auth_login_success_title),
              content: Text(l10n.auth_login_success),
            ),
          );
        },
      );
    } else {
      context.popToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthCubitState>(
      listener: (context, state) {
        if (state is AuthOtpRequested) {
          setState(() => _isOtpStep = true);
        } else if (state is Unauthenticated) {
          setState(() => _isOtpStep = false);
        } else if (state is Authenticated) {
          _handlePostAuthFlow(state.user);
        }
        if (state is AuthError) {
          final l10n = AppLocalizations.of(context)!;
          showToast(
            context: context,
            builder: (context, overlay) {
              return SurfaceCard(
                child: Basic(
                  title: Text(l10n.auth_login_error_title),
                  content: Text(state.message),
                ),
              );
            },
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final currentEmail = _emailController.text.trim();
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          headers: [
            AppBar(
              title: Text(
                _isOtpStep ? l10n.auth_verify_title : l10n.auth_login_title,
              ),
              leading: [...AppBackButton.render(context)],
            ),
            const Divider(height: 1),
          ],
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ResponsiveContainer(
                child: _isOtpStep
                    ? LoginOtpView(
                        otpController: _otpController,
                        isLoading: isLoading,
                        currentEmail: currentEmail,
                        onRequestOtp: _requestOtp,
                        onVerifyOtp: _verifyOtp,
                      )
                    : LoginEmailView(
                        emailController: _emailController,
                        isLoading: isLoading,
                        onRequestOtp: _requestOtp,
                        onTermsOfServiceTap: () {},
                        onPrivacyPolicyTap: () {},
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

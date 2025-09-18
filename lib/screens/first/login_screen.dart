import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocklet_source/app/core/core.dart';
import 'package:mocklet_source/app/data/app_constants.dart';
import '../../app_logger.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _forgotPasswordEmailController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _forgotPasswordFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isForgotPasswordLoading = false;
  bool _obscurePassword = true;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  StreamSubscription? _authEventsSubscription;

  bool isLoginLoading() {
    return _isLoading || _isGoogleLoading;
  }

  late AnimationController _titleAnimationController;
  late AnimationController _formAnimationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _titleScaleAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();

    _googleSignIn.initialize();
    _authEventsSubscription = _googleSignIn.authenticationEvents.listen(
      _onAuthenticationEvent,
      onError: _onAuthenticationError,
    );
  }

  Future<void> _onAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    final user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    if (user == null || !_isGoogleLoading) {
      if (_isGoogleLoading) {
        setState(() => _isGoogleLoading = false);
      }
      return;
    }

    try {
      final GoogleSignInAuthentication googleAuth = user.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      _showErrorSnackbar("sign_in_failed".tr());
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  void _onAuthenticationError(Object error) {
    if (!mounted) return;

    setState(() {
      _isGoogleLoading = false;
    });

    String message = 'An unknown error occurred during Google Sign-In.';
    if (error is GoogleSignInException) {
      message = switch (error.code) {
        GoogleSignInExceptionCode.canceled => 'Sign in was cancelled.',
        _ => 'Google Sign-In Error: ${error.code.name}',
      };
      AppLogger.info('Google Sign-In Error: ${error.description}');
    }
    _showErrorSnackbar(message);
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isGoogleLoading = true;
    });
    try {
      await _googleSignIn.authenticate();
    } catch (error) {
      _onAuthenticationError(error);
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    _forgotPasswordEmailController.text = _emailController.text;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'forgot_password'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _forgotPasswordFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'forgot_password_description'.tr(),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacityValue(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInputLabel('email'.tr(), context),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _forgotPasswordEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'enter_your_email'.tr(),
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (v) =>
                            v != null && EmailValidator.validate(v)
                            ? null
                            : 'please_enter_a_valid_email'.tr(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isForgotPasswordLoading
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: Text('cancel'.tr()),
                ),
                ElevatedButton(
                  onPressed: _isForgotPasswordLoading
                      ? null
                      : () async {
                          await _handleForgotPassword(setDialogState);
                        },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isForgotPasswordLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text('send_reset_link'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleForgotPassword(StateSetter setDialogState) async {
    if (!_forgotPasswordFormKey.currentState!.validate()) return;

    setDialogState(() {
      _isForgotPasswordLoading = true;
    });

    try {
      final email = _forgotPasswordEmailController.text.trim();
      final result = await ref.read(coreProvider).forgotPassword(email);

      if (result.success) {
        if (mounted) {
          Navigator.of(context).pop();
          _showSuccessSnackbar(result.message);
        }
      } else {
        if (mounted) {
          _showErrorSnackbar(result.message);
        }
      }
    } catch (e) {
      _showErrorSnackbar('forgot_password_error'.tr());
    } finally {
      if (mounted) {
        setDialogState(() {
          _isForgotPasswordLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotPasswordEmailController.dispose();
    _titleAnimationController.dispose();
    _formAnimationController.dispose();
    _buttonAnimationController.dispose();
    _authEventsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final result = await ref.read(coreProvider).login(email, password);

      if (result.success) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        if (mounted) {
          _showErrorSnackbar(result.message);
        }
      }
    } catch (e) {
      _showErrorSnackbar('Login failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAnimatedTitle(theme),
              const SizedBox(height: 48),
              AnimatedBuilder(
                animation: _formAnimationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _formFadeAnimation,
                    child: SlideTransition(
                      position: _formSlideAnimation,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 600),
                              tween: Tween(
                                begin: 0.0,
                                end: _formAnimationController.value,
                              ),
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: Column(
                                      children: [
                                        _buildInputLabel('email'.tr(), context),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            hintText: 'enter_your_email'.tr(),
                                          ),
                                          validator: (v) =>
                                              v != null &&
                                                  EmailValidator.validate(v)
                                              ? null
                                              : 'please_enter_a_valid_email'
                                                    .tr(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 600),
                              tween: Tween(
                                begin: 0.0,
                                end: (_formAnimationController.value - 0.2)
                                    .clamp(0.0, 1.0),
                              ),
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: Column(
                                      children: [
                                        _buildInputLabel(
                                          'password'.tr(),
                                          context,
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          decoration: InputDecoration(
                                            hintText: 'enter_your_password'
                                                .tr(),
                                            suffixIcon: IconButton(
                                              onPressed: () => setState(
                                                () => _obscurePassword =
                                                    !_obscurePassword,
                                              ),
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons
                                                          .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacityValue(0.5),
                                              ),
                                            ),
                                          ),
                                          validator: (v) =>
                                              v != null && v.length >= 6
                                              ? null
                                              : 'password_must_be_at_least_6_characters'
                                                    .tr(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _formAnimationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _formFadeAnimation,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: Text('forgot_password'.tr()),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _buttonAnimationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _buttonFadeAnimation,
                    child: SlideTransition(
                      position: _buttonSlideAnimation,
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: ElevatedButton(
                              onPressed: isLoginLoading() ? null : _handleLogin,
                              child: _isLoading
                                  ? _buildSpinner(Colors.white)
                                  : Text('login'.tr()),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'or'.tr(),
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withOpacityValue(0.5),
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: isLoginLoading()
                                ? null
                                : _handleGoogleLogin,
                            icon: Image.asset(
                              'assets/images/google_icon.png',
                              height: 20,
                            ),
                            label: _isGoogleLoading
                                ? _buildSpinner()
                                : Text('continue_with_google'.tr()),
                          ),
                          const SizedBox(height: 48),
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 800),
                            tween: Tween(
                              begin: 0.0,
                              end: _buttonAnimationController.value,
                            ),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "dont_have_an_account".tr(),
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withOpacityValue(0.7),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        Navigator.pushNamed(context, '/signup');
                                      },
                                      child: Text('register'.tr()),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpinner([Color? color]) {
    return SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacityValue(0.7),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle(ThemeData theme) {
    return AnimatedBuilder(
      animation: _titleAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _titleFadeAnimation,
          child: SlideTransition(
            position: _titleSlideAnimation,
            child: ScaleTransition(
              scale: _titleScaleAnimation,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/app_icon_login.png',
                    height: 64,
                    width: 64,
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _titleAnimationController,
                    builder: (context, child) {
                      const titleText = 'MOCKLET';
                      final charCount =
                          (_titleAnimationController.value * titleText.length)
                              .floor();
                      final visibleText = titleText.substring(
                        0,
                        charCount.clamp(0, titleText.length),
                      );

                      return RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: visibleText,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                                foreground: Paint()
                                  ..shader =
                                      LinearGradient(
                                        colors: [
                                          theme.colorScheme.primary,
                                          theme.colorScheme.secondary,
                                        ],
                                      ).createShader(
                                        const Rect.fromLTWH(0, 0, 200, 70),
                                      ),
                                shadows: [
                                  Shadow(
                                    color: theme.colorScheme.primary
                                        .withOpacityValue(0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            TextSpan(
                              text: titleText.substring(
                                charCount.clamp(0, titleText.length),
                              ),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                                color: Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _setupAnimations() {
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _titleAnimationController,
            curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
          ),
        );

    _titleScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _formSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _formAnimationController,
            curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  void _startAnimations() {
    _titleAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _formAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _buttonAnimationController.forward();
    });
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:country_flags/country_flags.dart';

import '../../app/data/app_constants.dart';
import '../../app/service/pref_service.dart';
import '../../models/runtime/language_model.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(
        AppConstants.welcomeVideo,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.setVolume(0.0);
      await _videoController!.play();
    } catch (_) {}
    setState(() {});
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacityValue(0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return SafeArea(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Container(
                        width: 60,
                        height: 6,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withOpacityValue(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                      child: Text(
                        'choose_your_pref_language',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ).tr(),
                    ),

                    // Language list
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ListView.separated(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: LanguageModel.supportedLanguages.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final lang =
                                LanguageModel.supportedLanguages[index];
                            final bool isSelected =
                                context.locale.languageCode == lang.code;

                            return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: isSelected
                                        ? colorScheme.primaryContainer
                                        : colorScheme.surface,
                                    border: Border.all(
                                      color: isSelected
                                          ? colorScheme.primary
                                                .withOpacityValue(0.4)
                                          : colorScheme.outline
                                                .withOpacityValue(0.1),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: colorScheme.primary
                                                  .withOpacityValue(0.15),
                                              blurRadius: 12,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacityValue(0.05),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () async {
                                        await context.setLocale(lang.locale);
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacityValue(0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child:
                                                    CountryFlag.fromCountryCode(
                                                      lang.flagCode,
                                                      height: 36,
                                                      width: 54,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: Text(
                                                lang.translatedName,
                                                style: theme
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      fontWeight: isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.w500,
                                                      color: isSelected
                                                          ? colorScheme
                                                                .onPrimaryContainer
                                                          : colorScheme
                                                                .onSurface,
                                                    ),
                                              ),
                                            ),
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              curve: Curves.easeInOutCubic,
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? colorScheme.primary
                                                    : Colors.transparent,
                                                shape: BoxShape.circle,
                                                border: !isSelected
                                                    ? Border.all(
                                                        color: colorScheme
                                                            .outline
                                                            .withOpacityValue(
                                                              0.4,
                                                            ),
                                                        width: 2,
                                                      )
                                                    : null,
                                              ),
                                              child: isSelected
                                                  ? Icon(
                                                      Icons.check_rounded,
                                                      color:
                                                          colorScheme.onPrimary,
                                                      size: 20,
                                                    )
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(
                                  delay: (100 * index).ms,
                                  duration: 500.ms,
                                  curve: Curves.easeOutCubic,
                                )
                                .slideX(
                                  begin: 0.3,
                                  duration: 500.ms,
                                  delay: (100 * index).ms,
                                  curve: Curves.easeOutCubic,
                                );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildOverlay(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Expanded(flex: 2, child: Center(child: _buildTitle(context))),
                  _buildControls(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    if (_videoController?.value.isInitialized ?? false) {
      return Positioned.fill(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
      );
    }
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacityValue(0.15),
              Colors.black.withOpacityValue(0.65),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
              'Mocklet',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -2,
                height: 0.9,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacityValue(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: 1000.ms, curve: Curves.easeOutCubic)
            .slideY(begin: -0.4, duration: 1000.ms, curve: Curves.easeOutCubic)
            .shimmer(duration: 2000.ms, delay: 500.ms),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacityValue(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacityValue(0.2),
              width: 1,
            ),
          ),
          child: Text(
            'welcome_subtitle',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacityValue(0.95),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ).tr(),
        ).animate().fadeIn(duration: 800.ms, delay: 600.ms).slideY(begin: 0.3),
      ],
    );
  }

  Widget _buildControls(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildLanguageButton(context)),
        const SizedBox(width: 20),
        _buildContinueButton(context),
      ],
    );
  }

  Widget _buildLanguageButton(BuildContext context) {
    final currentLocale = context.locale;
    final currentLangModel = LanguageModel.supportedLanguages.firstWhere(
      (lang) => lang.code == currentLocale.languageCode,
      orElse: () => LanguageModel.supportedLanguages.first,
    );

    return Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacityValue(0.2),
                Colors.white.withOpacityValue(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacityValue(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacityValue(0.15),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => _showLanguagePicker(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacityValue(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CountryFlag.fromCountryCode(
                          currentLangModel.flagCode,
                          height: 24,
                          width: 36,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        currentLangModel.translatedName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.expand_more_rounded,
                      color: Colors.white.withOpacityValue(0.9),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 700.ms, delay: 1400.ms, curve: Curves.easeOutCubic)
        .slideX(
          begin: -0.4,
          duration: 700.ms,
          delay: 1400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacityValue(0.9),
                Theme.of(context).colorScheme.secondary.withOpacityValue(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withOpacityValue(0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () {
                PrefService.setFirstRun(false);
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Center(
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 700.ms, delay: 1600.ms, curve: Curves.easeOutCubic)
        .slideX(
          begin: 0.4,
          duration: 700.ms,
          delay: 1600.ms,
          curve: Curves.easeOutCubic,
        )
        .then()
        .shimmer(duration: 1500.ms, delay: 500.ms);
  }
}

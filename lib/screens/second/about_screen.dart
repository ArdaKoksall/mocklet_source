import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocklet_source/app/data/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL() async {
    final Uri url = Uri.parse(AppConstants.githubUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "about".tr(),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withOpacityValue(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacityValue(
                      0.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outline.withOpacityValue(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "about_this_app".tr(),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "about_app_description".tr(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: colorScheme.onSurface.withOpacityValue(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacityValue(
                      0.3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outline.withOpacityValue(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star_outline_rounded,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "key_features".tr(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureItem(
                        context,
                        Icons.show_chart_rounded,
                        "feature_real_data_title".tr(),
                        "feature_real_data_desc".tr(),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        context,
                        Icons.account_balance_wallet_outlined,
                        "feature_virtual_portfolio_title".tr(),
                        "feature_virtual_portfolio_desc".tr(),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        context,
                        Icons.school_outlined,
                        "feature_risk_free_title".tr(),
                        "feature_risk_free_desc".tr(),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        context,
                        Icons.save,
                        "feature_local_data_title".tr(),
                        "feature_local_data_desc".tr(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacityValue(isDark ? 0.15 : 0.1),
                        Colors.red.withOpacityValue(isDark ? 0.15 : 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.orange.withOpacityValue(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade600,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "disclaimer_title".tr(),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _buildDisclaimerItem("disclaimer_item1".tr()),
                      _buildDisclaimerItem("disclaimer_item2".tr()),
                      _buildDisclaimerItem("disclaimer_item3".tr()),
                      _buildDisclaimerItem("disclaimer_item4".tr()),
                      _buildDisclaimerItem("disclaimer_item5".tr()),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _launchURL,
                    icon: Image.asset(
                      'assets/images/github_icon.png',
                      width: 24,
                      height: 24,
                      color: colorScheme.onPrimary,
                    ),
                    label: Text(
                      "view_source_code".tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      shadowColor: colorScheme.primary.withOpacityValue(0.3),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "version_info".tr(
                    namedArgs: {'version_number': AppConstants.versionNumber},
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacityValue(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacityValue(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacityValue(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.orange.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

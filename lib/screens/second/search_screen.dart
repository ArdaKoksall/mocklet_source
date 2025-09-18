import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mocklet_source/app/data/ad_constants.dart';
import 'package:mocklet_source/app/data/app_constants.dart';
import 'package:mocklet_source/models/runtime/crypto_preview.dart';
import 'package:mocklet_source/app/core/brain.dart';
import 'package:mocklet_source/models/cached/crypto/crypto.dart';
import 'package:mocklet_source/screens/second/crypto_detail/banner_ad_widget.dart';

import '../../app_logger.dart';
import 'coingecko_ref.dart';
import 'crypto_detail/crypto_detail_screen.dart';

enum SortType { rank, price, change }

enum SortDirection { asc, desc }

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSortExpanded = false;
  bool _showFavoritesOnly = false;

  late AnimationController _sortAnimationController;
  late Animation<double> _sortAnimation;
  final FocusNode searchFocusNode = FocusNode();

  SortType _activeSortType = SortType.rank;
  SortDirection _sortDirection = SortDirection.asc;

  final List<NativeAd?> _nativeAds = List.filled(
    AdConstants.maxAds,
    null,
    growable: false,
  );
  final List<bool> _isAdLoaded = List.filled(
    AdConstants.maxAds,
    false,
    growable: false,
  );

  @override
  void initState() {
    super.initState();
    _sortAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sortAnimation = CurvedAnimation(
      parent: _sortAnimationController,
      curve: Curves.easeInOut,
    );
    _loadAds();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _sortAnimationController.dispose();
    searchFocusNode.dispose();
    for (var ad in _nativeAds) {
      ad?.dispose();
    }
    super.dispose();
  }

  void _loadAds() {
    for (int i = 0; i < AdConstants.maxAds; i++) {
      if (_nativeAds[i] == null) {
        _nativeAds[i] = NativeAd(
          adUnitId: AdConstants.nativeAdvancedId,
          request: const AdRequest(),
          nativeTemplateStyle: NativeTemplateStyle(
            templateType: TemplateType.small,
            mainBackgroundColor: Colors.white,
          ),
          listener: NativeAdListener(
            onAdLoaded: (Ad ad) {
              AppLogger.info('Ad $i loaded successfully.');
              if (mounted) {
                setState(() {
                  _nativeAds[i] = ad as NativeAd;
                  _isAdLoaded[i] = true;
                });
              }
            },
            onAdFailedToLoad: (Ad ad, LoadAdError error) {
              AppLogger.warning(
                'Ad $i failed to load: $error',
                'search_screen',
              );
              ad.dispose();
            },
          ),
        );
        _nativeAds[i]!.load();
      }
    }
  }

  void _toggleSortExpansion() {
    setState(() {
      _isSortExpanded = !_isSortExpanded;
      if (_isSortExpanded) {
        _sortAnimationController.forward();
      } else {
        _sortAnimationController.reverse();
      }
    });
  }

  void _toggleFavoritesFilter() {
    setState(() {
      _showFavoritesOnly = !_showFavoritesOnly;
    });
  }

  void _handleSortTap(SortType tappedType) {
    setState(() {
      if (_activeSortType == tappedType) {
        _sortDirection = _sortDirection == SortDirection.asc
            ? SortDirection.desc
            : SortDirection.asc;
      } else {
        _activeSortType = tappedType;
        _sortDirection = (tappedType == SortType.rank)
            ? SortDirection.asc
            : SortDirection.desc;
      }
    });
  }

  List<CryptoPreview> _sortCryptoList(List<Crypto> cryptoList) {
    final previews = cryptoList.map((crypto) => crypto.getPreview()).toList();
    previews.sort((a, b) {
      int comparison;
      switch (_activeSortType) {
        case SortType.rank:
          comparison = a.marketCapRank.compareTo(b.marketCapRank);
          break;
        case SortType.price:
          comparison = a.currentPrice.compareTo(b.currentPrice);
          break;
        case SortType.change:
          comparison = a.priceChangePercentage24h.compareTo(
            b.priceChangePercentage24h,
          );
          break;
      }
      return _sortDirection == SortDirection.desc ? -comparison : comparison;
    });
    return previews;
  }

  @override
  Widget build(BuildContext context) {
    final cryptoList = ref.watch(brainProvider).cryptoList;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(10),
        child: AppBar(
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacityValue(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: _buildSearchField(theme),
                ),
                _buildSortSection(theme, isDark),
                buildPoweredBy(context),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                if (cryptoList == null)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (cryptoList.isEmpty)
                  SliverFillRemaining(child: _buildErrorScreen(theme, isDark))
                else
                  _buildCryptoSliverList(cryptoList, theme, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacityValue(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            focusNode: searchFocusNode,
            onChanged: (value) =>
                setState(() => _searchQuery = value.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'search_cryptocurrencies_hint'.tr(),
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withOpacityValue(0.7),
                fontSize: 16,
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacityValue(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        searchFocusNode.unfocus();
                      },
                    ),
                  IconButton(
                    icon: Icon(
                      _showFavoritesOnly
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: _showFavoritesOnly
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: _toggleFavoritesFilter,
                  ),
                ],
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacityValue(0.2),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacityValue(0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          BannerAdWidget(adId: AdConstants.searchScreenBannerAd),
        ],
      ),
    );
  }

  Widget _buildNoFavoritesScreen(ThemeData theme) => _buildStatusScreen(
    theme: theme,
    icon: Icons.star_border_rounded,
    iconColor: theme.colorScheme.secondary,
    title: 'no_favorites_title'.tr(),
    subtitle: 'no_favorites_subtitle'.tr(),
  );

  Widget _buildCryptoSliverList(
    List<Crypto> cryptoList,
    ThemeData theme,
    bool isDark,
  ) {
    final favoriteIds =
        ref.watch(brainProvider).userData?.favoriteCryptos ?? [];

    final List<Crypto> baseList;
    if (_showFavoritesOnly) {
      final favoriteIdSet = favoriteIds.toSet();
      baseList = cryptoList
          .where((crypto) => favoriteIdSet.contains(crypto.id))
          .toList();
    } else {
      baseList = cryptoList;
    }

    if (_showFavoritesOnly && baseList.isEmpty) {
      return SliverFillRemaining(child: _buildNoFavoritesScreen(theme));
    }

    final filteredList = _searchQuery.isEmpty
        ? baseList
        : baseList.where((crypto) {
            final preview = crypto.getPreview();
            return preview.name.toLowerCase().contains(_searchQuery) ||
                preview.symbol.toLowerCase().contains(_searchQuery);
          }).toList();

    if (filteredList.isEmpty && _searchQuery.isNotEmpty) {
      return SliverFillRemaining(child: _buildNoResultsScreen(theme, isDark));
    }

    final sortedPreviews = _sortCryptoList(filteredList);

    final List<Object> itemsWithAds = [];
    int adCounter = 0;
    for (int i = 0; i < sortedPreviews.length; i++) {
      if (i > 0 && i % AdConstants.adInterval == 0) {
        if (adCounter < AdConstants.maxAds && _isAdLoaded[adCounter]) {
          itemsWithAds.add(_nativeAds[adCounter]!);
          adCounter++;
        }
      }
      itemsWithAds.add(sortedPreviews[i]);
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = itemsWithAds[index];
          Widget card;

          if (item is NativeAd) {
            card = _buildAdCard(item, theme);
          } else if (item is CryptoPreview) {
            card = _buildCryptoCard(item, theme, isDark);
          } else {
            card = const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: card,
          );
        }, childCount: itemsWithAds.length),
      ),
    );
  }

  Widget _buildAdCard(NativeAd ad, ThemeData theme) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacityValue(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacityValue(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AdWidget(ad: ad),
    );
  }

  Widget _buildSortSection(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacityValue(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleSortExpansion,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${'sort_by'.tr()} ${_getVerboseSortDisplayName()}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _isSortExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _sortAnimation,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _buildSortControls(theme),
            ),
          ),
        ],
      ),
    );
  }

  String _getVerboseSortDisplayName() {
    switch (_activeSortType) {
      case SortType.rank:
        return _sortDirection == SortDirection.asc
            ? 'sort_rank_asc'.tr()
            : 'sort_rank_desc'.tr();
      case SortType.price:
        return _sortDirection == SortDirection.desc
            ? 'sort_price_desc'.tr()
            : 'sort_price_asc'.tr();
      case SortType.change:
        return _sortDirection == SortDirection.desc
            ? 'sort_change_desc'.tr()
            : 'sort_change_asc'.tr();
    }
  }

  Widget _buildSortChip({
    required ThemeData theme,
    required String label,
    required SortType type,
    required IconData icon,
  }) {
    final bool isActive = _activeSortType == type;
    final Color activeColor = theme.colorScheme.primary;
    final Color inactiveColor = theme.colorScheme.onSurfaceVariant;

    Widget labelWidget;
    if (isActive) {
      labelWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: activeColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 4),
          Icon(
            _sortDirection == SortDirection.asc
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 14,
            color: activeColor,
          ),
        ],
      );
    } else {
      labelWidget = Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: inactiveColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleSortTap(type),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withOpacityValue(0.12)
                  : theme.colorScheme.surfaceContainerHighest.withOpacityValue(
                      0.3,
                    ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? activeColor.withOpacityValue(0.3)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? activeColor : inactiveColor,
                ),
                const SizedBox(height: 6),
                labelWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortControls(ThemeData theme) {
    return Row(
      children: [
        _buildSortChip(
          theme: theme,
          label: 'rank'.tr(),
          type: SortType.rank,
          icon: Icons.leaderboard_outlined,
        ),
        const SizedBox(width: 12),
        _buildSortChip(
          theme: theme,
          label: 'price'.tr(),
          type: SortType.price,
          icon: Icons.attach_money_rounded,
        ),
        const SizedBox(width: 12),
        _buildSortChip(
          theme: theme,
          label: 'change_24h'.tr(),
          type: SortType.change,
          icon: Icons.show_chart_rounded,
        ),
      ],
    );
  }

  Widget _buildErrorScreen(ThemeData theme, bool isDark) => _buildStatusScreen(
    theme: theme,
    icon: Icons.cloud_off_rounded,
    iconColor: theme.colorScheme.error,
    title: 'unable_to_load_data_title'.tr(),
    subtitle: 'unable_to_load_data_subtitle'.tr(),
  );

  Widget _buildNoResultsScreen(ThemeData theme, bool isDark) =>
      _buildStatusScreen(
        theme: theme,
        icon: Icons.search_off_rounded,
        iconColor: theme.colorScheme.secondary,
        title: 'no_results_found_title'.tr(),
        subtitle: 'no_results_found_subtitle'.tr(
          namedArgs: {'query': _searchQuery},
        ),
      );

  Widget _buildStatusScreen({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: iconColor.withOpacityValue(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 48, color: iconColor),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCryptoCard(CryptoPreview preview, ThemeData theme, bool isDark) {
    final Color positiveColor = isDark
        ? Colors.greenAccent[400]!
        : Colors.green[600]!;
    final Color negativeColor = isDark
        ? Colors.redAccent[100]!
        : Colors.red[600]!;
    final priceChangeColor = preview.priceChangePercentage24h > 0
        ? positiveColor
        : (preview.priceChangePercentage24h < 0
              ? negativeColor
              : theme.colorScheme.onSurfaceVariant);
    final priceChangeIcon = preview.priceChangePercentage24h > 0
        ? Icons.trending_up_rounded
        : (preview.priceChangePercentage24h < 0
              ? Icons.trending_down_rounded
              : Icons.trending_flat_rounded);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacityValue(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacityValue(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            searchFocusNode.unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CryptoDetailScreen(cryptoId: preview.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CachedNetworkImage(
                  imageUrl: preview.image,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: RadialGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacityValue(0.2),
                          theme.colorScheme.surface,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Icon(
                      Icons.currency_bitcoin,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        preview.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary
                                  .withOpacityValue(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '#${preview.marketCapRank}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              preview.symbol.toUpperCase(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${_formatPrice(preview.currentPrice)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priceChangeColor.withOpacityValue(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            priceChangeIcon,
                            size: 16,
                            color: priceChangeColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${preview.priceChangePercentage24h.toStringAsFixed(2)}%',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: priceChangeColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1) {
      return price.toStringAsFixed(2);
    } else if (price > 0.000001) {
      return price.toStringAsFixed(6);
    } else {
      return price.toStringAsExponential(2);
    }
  }
}

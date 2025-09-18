import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocklet_source/app/core/brain.dart';
import 'package:mocklet_source/app/data/app_constants.dart';
import 'package:mocklet_source/screens/second/search_screen.dart';
import 'package:mocklet_source/screens/second/settings_screen.dart';
import 'package:mocklet_source/screens/second/wallet/wallet_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final PersistentTabController _controller = PersistentTabController(
    initialIndex: 0,
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initBrain();
  }

  Future<void> _initBrain() async {
    await ref.read(brainProvider).init();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    final inactiveColor = Colors.grey.withOpacityValue(0.7);

    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.wallet, size: 32),
        inactiveIcon: const Icon(Icons.wallet_outlined, size: 32),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: inactiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.search),
        inactiveIcon: const Icon(Icons.search_outlined),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: inactiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.settings),
        inactiveIcon: const Icon(Icons.settings_outlined),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: inactiveColor,
      ),
    ];
  }

  List<Widget> _buildScreens() {
    return [const WalletScreen(), const SearchScreen(), const SettingsScreen()];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarItems(),
        confineToSafeArea: true,
        backgroundColor: theme.colorScheme.surface,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        navBarHeight: 65,
        hideNavigationBarWhenKeyboardAppears: false,
        navBarStyle: NavBarStyle.style6,
        onItemSelected: (_) => FocusScope.of(context).unfocus(),
      ),
    );
  }
}

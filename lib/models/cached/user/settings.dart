import 'package:hive/hive.dart';

part 'settings.g.dart';

enum SettingField {
  showRecentTransactions,
  showTopHoldings,
  showRecentActivity,
}

@HiveType(typeId: 6)
class Settings extends HiveObject {
  @HiveField(0)
  bool showRecentTransactions;

  @HiveField(1)
  bool showTopHoldings;

  @HiveField(2)
  bool showRecentActivity;

  Settings({
    this.showRecentTransactions = true,
    this.showTopHoldings = true,
    this.showRecentActivity = true,
  });
}

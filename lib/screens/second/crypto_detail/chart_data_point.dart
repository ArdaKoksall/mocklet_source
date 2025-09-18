class ChartDataPoint {
  final DateTime x;
  final double y;

  ChartDataPoint(DateTime utcX, this.y) : x = utcX.toLocal();
}

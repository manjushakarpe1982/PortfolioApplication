import 'package:bold_portfolio/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartPage extends StatefulWidget {
  final List<ChartData> data;
  final String metal;
  final String selectedFilter;
  final bool errorOccurred;
  final VoidCallback? pressedRetry;
  final Color chartColor;

  const ChartPage({
    super.key,
    required this.data,
    required this.metal,
    required this.selectedFilter,
    required this.errorOccurred,
    required this.chartColor,
    this.pressedRetry,
  });

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  bool isLoading = false;
  List<ChartData> chartData = [];
  late String metalTitle;

  @override
  void initState() {
    super.initState();
    chartData = widget.data;
    metalTitle =
        "${widget.metal[0].toUpperCase()}${widget.metal.substring(1)} Spot Chart";
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  bool get _isShortRange =>
      widget.selectedFilter == "24H" || widget.selectedFilter == "1W";

  DateTime get _minX => widget.data.first.timestamp;
  DateTime get _maxX => widget.data.last.timestamp;

  // ✅ Dark border color per metal
  Color get _borderColor {
    switch (widget.metal) {
      case 'Gold':
        return const Color(0xFFFFC107); // dark amber/gold
      case 'Silver':
        return const Color(0xFF9E9E9E); // dark grey
      case 'Platinum':
        return const Color(0xFF3B82F6); // dark blue (darker than 0xFF93C5FD)
      case 'Palladium':
        return const Color(0xFF0D9488); // dark teal (darker than 0xFF2DD4BF)
      default:
        return const Color(0xFFFFC107);
    }
  }

  // ✅ Light gradient fill per metal — dark on top, very light at bottom
  LinearGradient get _areaGradient {
    switch (widget.metal) {
      case 'Gold':
        return LinearGradient(
          colors: [
            const Color(0xFFFFC107).withOpacity(0.6), // dark gold top
            const Color(0xFFFFF3CD).withOpacity(0.15), // light gold bottom
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'Silver':
        return LinearGradient(
          colors: [
            const Color(0xFF9E9E9E).withOpacity(0.6), // dark grey top
            const Color(0xFFE0E0E0).withOpacity(0.15), // light grey bottom
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'Platinum':
        return LinearGradient(
          colors: [
            const Color(0xFF3B82F6).withOpacity(0.6), // dark blue top
            const Color(
              0xFFDBEAFE,
            ).withOpacity(0.15), // light blue bottom (0xFFDBEAFE = blue-100)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'Palladium':
        return LinearGradient(
          colors: [
            const Color(0xFF0D9488).withOpacity(0.6), // dark teal top
            const Color(
              0xFFCCFBF1,
            ).withOpacity(0.15), // light teal bottom (0xFFCCFBF1 = teal-100)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      default:
        return LinearGradient(
          colors: [
            const Color(0xFFFFC107).withOpacity(0.6),
            const Color(0xFFFFF3CD).withOpacity(0.15),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }

  // ── X Axis ──────────────────────────────────────────────────────────────

  DateTimeAxis _buildXAxis() {
    switch (widget.selectedFilter) {
      case "24H":
        return DateTimeAxis(
          minimum: _minX,
          maximum: _maxX,
          intervalType: DateTimeIntervalType.hours,
          interval: 1,
          dateFormat: DateFormat('hh:mm a'),
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(width: 0),
          labelStyle: const TextStyle(fontSize: 12),
        );
      case "1W":
        return DateTimeAxis(
          intervalType: DateTimeIntervalType.days,
          interval: 1,
          dateFormat: DateFormat('dd MMM'),
        );
      case "1M":
      case "6M":
      case "1Y":
      case "YTD":
        return DateTimeAxis(
          intervalType: DateTimeIntervalType.months,
          interval: 1,
          dateFormat: DateFormat('MMM yyyy'),
        );
      case "5Y":
      case "All":
        return DateTimeAxis(
          intervalType: DateTimeIntervalType.years,
          interval: 1,
          dateFormat: DateFormat('yyyy'),
        );
      default:
        return DateTimeAxis();
    }
  }

  // ── Y Axis ───────────────────────────────────────────────────────────────

  NumericAxis _buildTightYAxis() {
    final min = widget.data.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    final max = widget.data.map((e) => e.price).reduce((a, b) => a > b ? a : b);
    final padding = (max - min) * 0.15;

    return NumericAxis(
      minimum: min - padding,
      maximum: max + padding,
      interval: (max - min) / 4,
      numberFormat: NumberFormat.currency(symbol: '\$'),
      majorGridLines: const MajorGridLines(width: 0),
      axisLine: const AxisLine(width: 0),
      labelStyle: const TextStyle(fontSize: 12),
    );
  }

  NumericAxis _buildWideYAxis() {
    final min = widget.data.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    final max = widget.data.map((e) => e.price).reduce((a, b) => a > b ? a : b);
    final range = max - min;
    final padding = range == 0 ? 1 : range * 0.2;

    return NumericAxis(
      minimum: (min - padding).clamp(0, double.infinity),
      maximum: max + padding,
      interval: range == 0 ? 1 : range / 4,
      numberFormat: NumberFormat.currency(symbol: '\$'),
      majorGridLines: const MajorGridLines(width: 0),
      axisLine: const AxisLine(width: 0),
      labelStyle: const TextStyle(fontSize: 12),
    );
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('EEEE, dd MMM • hh:mm a').format(date);
  }

  // ── Trackball ────────────────────────────────────────────────────────────

  TrackballBehavior get _trackballBehavior => TrackballBehavior(
    enable: true,
    activationMode: ActivationMode.singleTap,
    lineType: TrackballLineType.vertical,
    lineWidth: 1,
    lineColor: Colors.grey,
    tooltipSettings: const InteractiveTooltip(
      enable: true,
      color: Colors.transparent,
    ),
    markerSettings: const TrackballMarkerSettings(
      markerVisibility: TrackballVisibilityMode.visible,
      height: 8,
      width: 8,
    ),
    builder: (BuildContext context, TrackballDetails details) {
      if (details.pointIndex == null) return const SizedBox.shrink();

      final data = widget.data[details.pointIndex!];

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6),
              ],
            ),
            child: Text(
              '${widget.metal.toUpperCase()}  ${NumberFormat.currency(symbol: '\$').format(data.price)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _formatDateTime(data.timestamp),
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        ],
      );
    },
  );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(metalTitle)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.errorOccurred
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text.rich(
                    const TextSpan(
                      text: 'Reload Chart',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      widget.pressedRetry?.call();
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : chartData.isEmpty
          ? const Center(child: Text('No data available'))
          : SfCartesianChart(
              trackballBehavior: _trackballBehavior,
              plotAreaBorderWidth: 0,
              primaryXAxis: _buildXAxis(),
              primaryYAxis: _isShortRange
                  ? _buildTightYAxis()
                  : _buildWideYAxis(),
              series: <CartesianSeries>[
                AreaSeries<ChartData, DateTime>(
                  dataSource: widget.data,
                  xValueMapper: (d, _) => d.timestamp,
                  yValueMapper: (d, _) => d.price,
                  borderWidth: 2,
                  // ✅ Dark border color per metal
                  borderColor: _borderColor,
                  // ✅ Light inner gradient per metal
                  gradient: _areaGradient,
                ),
              ],
            ),
    );
  }
}

// ── Model ─────────────────────────────────────────────────────────────────

class ChartData {
  final DateTime timestamp;
  final double price;

  ChartData({required this.timestamp, required this.price});

  factory ChartData.fromJson(List<dynamic> item) {
    return ChartData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(item[0]),
      price: (item[1] as num).toDouble(),
    );
  }
}

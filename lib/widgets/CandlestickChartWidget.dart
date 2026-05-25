import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class CandleData {
  final DateTime x;
  final num open;
  final num high;
  final num low;
  final num close;

  CandleData(this.x, this.open, this.high, this.low, this.close);
}

class MetalCandleChart extends StatefulWidget {
  final List<MetalCandleChartEntry> candleChartData;
  final String selectedMetal;
  final bool showCombined;

  const MetalCandleChart({
    super.key,
    required this.candleChartData,
    required this.selectedMetal,
    this.showCombined = false,
  });

  @override
  _MetalCandleChartState createState() => _MetalCandleChartState();
}

class _MetalCandleChartState extends State<MetalCandleChart> {
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  late CrosshairBehavior _crosshairBehavior;

  List<CandleData> _goldData = [];
  List<CandleData> _silverData = [];
  List<CandleData> _platinumData = []; // ✅ NEW
  List<CandleData> _palladiumData = []; // ✅ NEW

  @override
  void initState() {
    super.initState();
    _buildAllSeriesData();

    _tooltipBehavior = TooltipBehavior(
      enable: true,
      shouldAlwaysShow: false,
      tooltipPosition: TooltipPosition.pointer,
      builder:
          (
            dynamic data,
            dynamic point,
            dynamic series,
            int pointIndex,
            int seriesIndex,
          ) {
            final CandleData candle = data as CandleData;
            final formattedDate = DateFormat(
              'MMM dd, hh:mm a',
            ).format(candle.x);
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Open: ${formatPrice(candle.open)}',
                    style: const TextStyle(color: Color(0xFF00cc00)),
                  ),
                  Text(
                    'High: ${formatPrice(candle.high)}',
                    style: const TextStyle(color: Color(0xFF00cc00)),
                  ),
                  Text(
                    'Low: ${formatPrice(candle.low)}',
                    style: const TextStyle(color: Color(0xFFff3333)),
                  ),
                  Text(
                    'Close: ${formatPrice(candle.close)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
    );

    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      zoomMode: ZoomMode.x,
    );

    _crosshairBehavior = CrosshairBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      lineColor: Colors.white,
      lineDashArray: [4, 4],
      shouldAlwaysShow: false,
    );
  }

  @override
  void didUpdateWidget(covariant MetalCandleChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.candleChartData != widget.candleChartData ||
        oldWidget.selectedMetal != widget.selectedMetal ||
        oldWidget.showCombined != widget.showCombined) {
      setState(() {
        _buildAllSeriesData();
      });
    }
  }

  // ✅ NEW — build all 4 metal series in one place
  void _buildAllSeriesData() {
    _goldData = _groupCandles(widget.candleChartData, 5, 'Gold');
    _silverData = _groupCandles(widget.candleChartData, 5, 'Silver');
    _platinumData = _groupCandles(widget.candleChartData, 5, 'Platinum');
    _palladiumData = _groupCandles(widget.candleChartData, 5, 'Palladium');
  }

  String formatPrice(num price) {
    return NumberFormat.simpleCurrency(locale: 'en_US').format(price);
  }

  String formatValue(num value) {
    final absValue = value.abs();
    if (absValue >= 1e9) return '${(value / 1e9).toStringAsFixed(1)}B';
    if (absValue >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
    if (absValue >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }

  // ✅ UPDATED — metalType string instead of useGold bool
  List<CandleData> _groupCandles(
    List<MetalCandleChartEntry> data,
    int groupSize,
    String metalType, // ✅ 'Gold' | 'Silver' | 'Platinum' | 'Palladium' | 'All'
  ) {
    final groupedData = <CandleData>[];

    for (int i = 0; i < data.length; i += groupSize) {
      final group = data.sublist(
        i,
        i + groupSize <= data.length ? i + groupSize : data.length,
      );

      if (group.isNotEmpty) {
        // ✅ open/close/high/low per metal
        num open;
        num close;
        Iterable<num> highValues;
        Iterable<num> lowValues;

        switch (metalType) {
          case 'Gold':
            open = group[0].openGold;
            close = group.last.closeGold != 0
                ? group.last.closeGold
                : group.last.openGold;
            highValues = group.map((d) => d.highGold).where((v) => v > 0);
            lowValues = group.map((d) => d.lowGold).where((v) => v > 0);
            break;
          case 'Silver':
            open = group[0].openSilver;
            close = group.last.closeSilver != 0
                ? group.last.closeSilver
                : group.last.openSilver;
            highValues = group.map((d) => d.highSilver).where((v) => v > 0);
            lowValues = group.map((d) => d.lowSilver).where((v) => v > 0);
            break;
          case 'Platinum': // ✅ NEW
            open = group[0].openPlatinum;
            close = group.last.closePlatinum != 0
                ? group.last.closePlatinum
                : group.last.openPlatinum;
            highValues = group.map((d) => d.highPlatinum).where((v) => v > 0);
            lowValues = group.map((d) => d.lowPlatinum).where((v) => v > 0);
            break;
          case 'Palladium': // ✅ NEW
            open = group[0].openPalladium;
            close = group.last.closePalladium != 0
                ? group.last.closePalladium
                : group.last.openPalladium;
            highValues = group.map((d) => d.highPalladium).where((v) => v > 0);
            lowValues = group.map((d) => d.lowPalladium).where((v) => v > 0);
            break;
          case 'All':
          default:
            open = group[0].openMetal;
            close = group.last.closeMetal != 0
                ? group.last.closeMetal
                : group.last.openMetal;
            highValues = group.map((d) => d.highMetal).where((v) => v > 0);
            lowValues = group.map((d) => d.lowMetal).where((v) => v > 0);
        }

        // ✅ NEW — cast to List<double> before reduce
        final highList = highValues.map((v) => v.toDouble()).toList();
        final lowList = lowValues.map((v) => v.toDouble()).toList();

        final high = highList.isNotEmpty
            ? highList.reduce((a, b) => a > b ? a : b)
            : open.toDouble();
        final low = lowList.isNotEmpty
            ? lowList.reduce((a, b) => a < b ? a : b)
            : open.toDouble();

        if (open > 0 && high > 0 && low > 0 && close > 0) {
          groupedData.add(
            CandleData(
              group.first.intervalStart,
              double.parse(open.toStringAsFixed(2)),
              double.parse(high.toStringAsFixed(2)),
              double.parse(low.toStringAsFixed(2)),
              double.parse(close.toStringAsFixed(2)),
            ),
          );
        }
      }
    }
    return groupedData;
  }

  // ✅ NEW — returns correct data source for selected metal
  List<CandleData> get _dataSource {
    switch (widget.selectedMetal) {
      case 'Gold':
        return _goldData;
      case 'Silver':
        return _silverData;
      case 'Platinum':
        return _platinumData;
      case 'Palladium':
        return _palladiumData;
      case 'All':
      default:
        return _silverData; // All uses combined metal data
    }
  }

  // ✅ NEW — dynamic chart title for all 4 metals
  String get _chartTitle {
    if (widget.showCombined) return 'Live All Holdings';
    switch (widget.selectedMetal) {
      case 'Gold':
        return 'Live Gold Holdings';
      case 'Silver':
        return 'Live Silver Holdings';
      case 'Platinum':
        return 'Live Platinum Holdings';
      case 'Palladium':
        return 'Live Palladium Holdings';
      default:
        return 'Live Holdings';
    }
  }

  Widget _buildChartButton(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2c2c2c),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 12),
          tooltip: tooltip,
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Uses _dataSource getter — covers all 4 metals
    final dataSource = _dataSource;

    const int visibleCandlesCount = 12;
    DateTime initialMin;
    DateTime initialMax;

    if (dataSource.isNotEmpty) {
      final dataLength = dataSource.length;

      if (dataLength > visibleCandlesCount) {
        initialMin = dataSource[dataLength - visibleCandlesCount].x;
        initialMax = dataSource.last.x;

        final candleInterval = dataSource[1].x.difference(dataSource[0].x);
        initialMin = initialMin.subtract(candleInterval * 1.5);
        initialMax = initialMax.add(candleInterval * 1.5);
      } else if (dataLength > 1) {
        initialMin = dataSource.first.x;
        initialMax = dataSource.last.x;

        final candleInterval = dataSource[1].x.difference(dataSource[0].x);
        initialMin = initialMin.subtract(candleInterval * 1.5);
        initialMax = initialMax.add(candleInterval * 1.5);
      } else {
        initialMin = dataSource.first.x.subtract(const Duration(minutes: 5));
        initialMax = dataSource.first.x.add(const Duration(minutes: 5));
      }
    } else {
      initialMin = DateTime.now().subtract(const Duration(minutes: 5));
      initialMax = DateTime.now().add(const Duration(minutes: 5));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Top bar ───────────────────────────────────────────────────────
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ Uses _chartTitle getter
              Text(
                _chartTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildChartButton(
                    Icons.add,
                    'Zoom In',
                    () => _zoomPanBehavior.zoomIn(),
                  ),
                  _buildChartButton(
                    Icons.remove,
                    'Zoom Out',
                    () => _zoomPanBehavior.zoomOut(),
                  ),
                  _buildChartButton(
                    Icons.home,
                    'Reset Zoom',
                    () => _zoomPanBehavior.reset(),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Chart ─────────────────────────────────────────────────────────
        Expanded(
          child: SfCartesianChart(
            backgroundColor: const Color(0xFF1a1a1a),
            plotAreaBorderWidth: 0,
            tooltipBehavior: _tooltipBehavior,
            zoomPanBehavior: _zoomPanBehavior,
            crosshairBehavior: _crosshairBehavior,
            onCrosshairPositionChanging: (CrosshairRenderArgs args) {
              if (args.axis is NumericAxis) {
                args.text = formatPrice(args.value);
              }
            },
            primaryXAxis: DateTimeAxis(
              intervalType: DateTimeIntervalType.minutes,
              dateFormat: DateFormat('hh:mm a'),
              initialVisibleMinimum: initialMin,
              initialVisibleMaximum: initialMax,
              majorGridLines: const MajorGridLines(
                color: Color(0xFF333333),
                dashArray: [4, 4],
              ),
            ),
            primaryYAxis: NumericAxis(
              decimalPlaces: 2,
              rangePadding: ChartRangePadding.additional,
              majorGridLines: const MajorGridLines(
                color: Color(0xFF333333),
                dashArray: [4, 4],
              ),
              majorTickLines: const MajorTickLines(color: Color(0xFF404040)),
              axisLine: const AxisLine(color: Color(0xFF404040)),
              labelStyle: TextStyle(
                color: const Color(0xFF8c8c8c),
                fontSize: MediaQuery.of(context).size.width < 768 ? 10 : 12,
              ),
              axisLabelFormatter: (AxisLabelRenderDetails details) {
                return ChartAxisLabel(
                  formatPrice(details.value),
                  const TextStyle(color: Color(0xFF8c8c8c)),
                );
              },
            ),
            series: <CartesianSeries>[
              CandleSeries<CandleData, DateTime>(
                dataSource: dataSource,
                xValueMapper: (CandleData data, _) => data.x,
                openValueMapper: (CandleData data, _) => data.open,
                highValueMapper: (CandleData data, _) => data.high,
                lowValueMapper: (CandleData data, _) => data.low,
                closeValueMapper: (CandleData data, _) => data.close,
                bullColor: const Color(0xFF00cc00),
                bearColor: const Color(0xFFff3333),
                enableSolidCandles: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

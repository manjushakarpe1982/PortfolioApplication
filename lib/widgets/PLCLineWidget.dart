import 'package:bold_portfolio/providers/portfolio_provider.dart';
import 'package:bold_portfolio/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../models/portfolio_model.dart';

class MetalHoldingsLineChartForPLC extends StatelessWidget {
  final List<MetalInOunces> metalInOuncesData;
  final bool isGoldView;
  final String metal;
  final String selectedRange;

  const MetalHoldingsLineChartForPLC({
    super.key,
    required this.metalInOuncesData,
    required this.isGoldView,
    required this.metal,
    required this.selectedRange,
  });

  // ── Legend helpers ──────────────────────────────────────────────────────
  Widget _buildLegendDot({required Color color}) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegendDot(color: color),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ✅ Returns the correct ounce value per metal
  double _getMetalValue(MetalInOunces data) {
    switch (metal) {
      case 'Gold':
        return data.totalGoldOunces;
      case 'Silver':
        return data.totalSilverOunces;
      case 'Platinum':
        return data.totalPlatinumOunces;
      case 'Palladium':
        return data.totalPalladiumOunces;
      default:
        return data.totalSilverOunces;
    }
  }

  // ✅ Returns line color per metal
  Color get _lineColor {
    switch (metal) {
      case 'Gold':
        return Colors.orangeAccent;
      case 'Silver':
        return const Color(0xFF808080);
      case 'Platinum':
        return const Color(0xFF93C5FD);
      case 'Palladium':
        return const Color(0xFF2DD4BF);
      default:
        return const Color(0xFF808080);
    }
  }

  // ✅ Returns label color per metal
  Color get _labelColor {
    switch (metal) {
      case 'Gold':
        return Colors.orangeAccent;
      case 'Silver':
        return const Color(0xFF808080);
      case 'Platinum':
        return const Color(0xFF93C5FD);
      case 'Palladium':
        return const Color(0xFF2DD4BF);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<MetalInOunces> actualData = metalInOuncesData;

    String formatValue(num value) {
      final absValue = value.abs();
      if (absValue >= 1e9) return '${(value / 1e9).toStringAsFixed(1)}B';
      if (absValue >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
      if (absValue >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
      return value.toStringAsFixed(0);
    }

    String formatPrice(num price) {
      return NumberFormat.simpleCurrency(locale: 'en_US').format(price);
    }

    // ✅ Compute min/max using _getMetalValue — works for all 4 metals
    final List<double> allValues = metalInOuncesData
        .map((d) => _getMetalValue(d))
        .toList();

    final double minVal = allValues.isNotEmpty
        ? allValues.reduce((a, b) => a < b ? a : b)
        : 0;
    final double maxVal = allValues.isNotEmpty
        ? allValues.reduce((a, b) => a > b ? a : b)
        : 0;
    final double yMin = minVal < 1 ? minVal : minVal - 1;
    final double yMax = maxVal + 1;

    return Card(
      elevation: 4,
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // ── Legend ────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildLegendDot(color: _labelColor),
                const SizedBox(width: 8),
                Text(
                  metal, // ✅ directly uses metal string — 'Gold'/'Silver'/'Platinum'/'Palladium'
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Chart ──────────────────────────────────────────────────────
            Expanded(
              child: actualData.isEmpty
                  ? const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : SfCartesianChart(
                      backgroundColor: Colors.transparent,
                      plotAreaBorderWidth: 1.0,
                      tooltipBehavior: TooltipBehavior(enable: false),
                      trackballBehavior: TrackballBehavior(
                        enable: true,
                        activationMode: ActivationMode.singleTap,
                        lineType: TrackballLineType.vertical,
                        lineColor: Colors.grey,
                        lineWidth: 1,
                        markerSettings: const TrackballMarkerSettings(
                          markerVisibility: TrackballVisibilityMode.visible,
                        ),
                        tooltipSettings: const InteractiveTooltip(enable: true),
                        tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
                        builder: (BuildContext context, TrackballDetails details) {
                          final groupingInfo = details.groupingModeInfo;
                          if (groupingInfo == null) return const SizedBox();

                          final List<dynamic>? visibleSeriesList =
                              groupingInfo.visibleSeriesList;
                          final List<CartesianChartPoint<dynamic>> points =
                              groupingInfo.points;

                          if (visibleSeriesList == null ||
                              visibleSeriesList.length != points.length) {
                            return const SizedBox();
                          }

                          final Map<String, MetalInOunces> seriesToData = {};
                          for (int i = 0; i < visibleSeriesList.length; i++) {
                            final seriesObj = visibleSeriesList[i];
                            final point = points[i];
                            final String? seriesName =
                                seriesObj.name as String?;
                            final List<dynamic>? ds = seriesObj.dataSource;

                            if (seriesName != null &&
                                ds != null &&
                                point.x != null) {
                              MetalInOunces? dp;
                              try {
                                dp =
                                    ds.firstWhere((e) => e.orderDate == point.x)
                                        as MetalInOunces;
                              } catch (_) {
                                dp = ds.isNotEmpty
                                    ? ds.first as MetalInOunces
                                    : null;
                              }
                              if (dp != null) seriesToData[seriesName] = dp;
                            }
                          }

                          if (seriesToData.isEmpty) return const SizedBox();

                          final provider = Provider.of<PortfolioProvider>(
                            context,
                            listen: false,
                          );
                          final MetalInOunces firstDp =
                              seriesToData.values.first;
                          final String date = provider.frequency == '1D'
                              ? DateFormat(
                                  'MMM dd hh:mm a',
                                ).format(firstDp.orderDate)
                              : DateFormat(
                                  'MMM d, yyyy',
                                ).format(firstDp.orderDate);

                          final List<Widget> content = [
                            Text(
                              date,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ];

                          const TextStyle baseStyle = TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          );

                          // ✅ Tooltip covers all 4 metals
                          seriesToData.forEach((seriesName, dp) {
                            if (seriesName == 'Gold') {
                              content.add(
                                Text(
                                  "Gold: ${formatPrice(dp.totalGoldOunces)}",
                                  style: baseStyle,
                                ),
                              );
                            } else if (seriesName == 'Silver') {
                              content.add(
                                Text(
                                  "Silver: ${formatPrice(dp.totalSilverOunces)}",
                                  style: baseStyle,
                                ),
                              );
                            } else if (seriesName == 'Platinum') {
                              // ✅ NEW
                              content.add(
                                Text(
                                  "Platinum: ${formatPrice(dp.totalPlatinumOunces)}",
                                  style: baseStyle,
                                ),
                              );
                            } else if (seriesName == 'Palladium') {
                              // ✅ NEW
                              content.add(
                                Text(
                                  "Palladium: ${formatPrice(dp.totalPalladiumOunces)}",
                                  style: baseStyle,
                                ),
                              );
                            }
                          });

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: content,
                            ),
                          );
                        },
                      ),
                      annotations: const <CartesianChartAnnotation>[],
                      primaryXAxis: DateTimeAxis(
                        dateFormat: DateFormat.MMMd(),
                        intervalType: DateTimeIntervalType.auto,
                        majorGridLines: const MajorGridLines(width: 0),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                      ),
                      primaryYAxis: NumericAxis(
                        axisLabelFormatter: (AxisLabelRenderDetails details) {
                          return ChartAxisLabel(
                            '\$${formatValue(details.value)}',
                            const TextStyle(color: Colors.black),
                          );
                        },
                        majorGridLines: const MajorGridLines(width: 0.5),
                        // ✅ min/max now uses _getMetalValue — correct for all 4 metals
                        minimum: yMin,
                        maximum: yMax,
                      ),
                      series: <CartesianSeries<MetalInOunces, DateTime>>[
                        AreaSeries<MetalInOunces, DateTime>(
                          key: ValueKey('$metal $selectedRange'),
                          dataSource: actualData,
                          xValueMapper: (MetalInOunces data, _) =>
                              data.orderDate,
                          // ✅ yValueMapper uses _getMetalValue — all 4 metals
                          yValueMapper: (MetalInOunces data, _) =>
                              _getMetalValue(data),
                          color: _lineColor,
                          borderWidth: 2,
                          gradient: LinearGradient(
                            colors: [
                              _lineColor.withOpacity(0.7),
                              _lineColor.withOpacity(0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            tileMode: TileMode.clamp,
                          ),
                          // ✅ Series name = metal string directly
                          name: metal,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

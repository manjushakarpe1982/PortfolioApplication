import 'dart:math';

import 'package:bold_portfolio/providers/portfolio_provider.dart';
import 'package:bold_portfolio/widgets/PredictionPopup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../models/portfolio_model.dart';

class MetalHoldingsLineChart extends StatelessWidget {
  final List<MetalInOunces> metalInOuncesData;
  final ValueChanged<bool> onToggleView;
  final bool isPredictionView;
  final bool isGoldView;
  final bool isTotalHoldingsView;
  final bool isPlatinumView;
  final bool isPalladiumView;
  final String selectedTab;

  const MetalHoldingsLineChart({
    super.key,
    required this.metalInOuncesData,
    required this.onToggleView,
    required this.isPredictionView,
    required this.isGoldView,
    required this.isTotalHoldingsView,
    required this.isPlatinumView,
    required this.isPalladiumView,
    required this.selectedTab,
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

  // ── Value helpers ───────────────────────────────────────────────────────
  double getCurrentValue(MetalInOunces data) {
    if (isTotalHoldingsView) return data.totalOunces;
    if (isGoldView) return data.totalGoldOunces;
    if (isPlatinumView) return data.totalPlatinumOunces;
    if (isPalladiumView) return data.totalPalladiumOunces;
    return data.totalSilverOunces;
  }

  double getPredictionMax(MetalInOunces data) {
    if (isPredictionView) {
      if (isTotalHoldingsView) return data.totalOunces;
      if (isGoldView) {
        return max(
          data.totalGoldOunces,
          max(data.totalGoldWorstPrediction, data.totalGoldOptimalPrediction),
        );
      }
      if (isPlatinumView) {
        return max(
          data.totalPlatinumOunces,
          max(
            data.totalPlatinumWorstPrediction,
            data.totalPlatinumOptimalPrediction,
          ),
        );
      }
      if (isPalladiumView) {
        return max(
          data.totalPalladiumOunces,
          max(
            data.totalPalladiumWorstPrediction,
            data.totalPalladiumOptimalPrediction,
          ),
        );
      }
      return max(
        data.totalSilverOunces,
        max(data.totalSilverWorstPrediction, data.totalSilverOptimalPrediction),
      );
    }
    return getCurrentValue(data);
  }

  double getPredictionMin(MetalInOunces data) {
    if (isPredictionView) {
      if (isTotalHoldingsView) return data.totalOunces;

      if (isGoldView) {
        final worst = data.totalGoldWorstPrediction > 0
            ? data.totalGoldWorstPrediction
            : data.totalGoldOunces;
        final optimal = data.totalGoldOptimalPrediction > 0
            ? data.totalGoldOptimalPrediction
            : data.totalGoldOunces;
        return min(data.totalGoldOunces, min(worst, optimal));
      }

      if (isPlatinumView) {
        final worst = data.totalPlatinumWorstPrediction > 0
            ? data.totalPlatinumWorstPrediction
            : data.totalPlatinumOunces;
        final optimal = data.totalPlatinumOptimalPrediction > 0
            ? data.totalPlatinumOptimalPrediction
            : data.totalPlatinumOunces;
        return min(data.totalPlatinumOunces, min(worst, optimal));
      }

      if (isPalladiumView) {
        final worst = data.totalPalladiumWorstPrediction > 0
            ? data.totalPalladiumWorstPrediction
            : data.totalPalladiumOunces;
        final optimal = data.totalPalladiumOptimalPrediction > 0
            ? data.totalPalladiumOptimalPrediction
            : data.totalPalladiumOunces;
        return min(data.totalPalladiumOunces, min(worst, optimal));
      }

      return min(
        data.totalSilverOunces,
        min(data.totalSilverWorstPrediction, data.totalSilverOptimalPrediction),
      );
    }
    return getCurrentValue(data);
  }

  double getMinY(
    List<MetalInOunces> actualData,
    List<MetalInOunces> predictionData,
  ) {
    final List<double> allValues = isPredictionView
        ? [
            ...actualData
                .where((d) => getCurrentValue(d) >= 0)
                .map(getCurrentValue),
            ...predictionData.map((d) => getPredictionMin(d)),
          ]
        : [
            ...actualData
                .where((d) => getCurrentValue(d) >= 0)
                .map(getCurrentValue),
          ];

    final minValue = allValues.reduce(min);
    return minValue - 1;
  }

  double getMaxY(
    List<MetalInOunces> actualData,
    List<MetalInOunces> predictionData,
  ) {
    final List<double> allValues = isPredictionView
        ? [
            ...actualData.map(getCurrentValue),
            ...predictionData.map((d) => getPredictionMax(d)),
          ]
        : [...actualData.map(getCurrentValue)];
    return allValues.reduce(max) + 1;
  }

  // ── Worst prediction value ──────────────────────────────────────────────
  double getWorstPrediction(MetalInOunces data) {
    if (isGoldView) return data.totalGoldWorstPrediction;
    if (isPlatinumView) return data.totalPlatinumWorstPrediction;
    if (isPalladiumView) return data.totalPalladiumWorstPrediction;
    return data.totalSilverWorstPrediction;
  }

  // ── Optimal prediction value ────────────────────────────────────────────
  double getOptimalPrediction(MetalInOunces data) {
    if (isGoldView) return data.totalGoldOptimalPrediction;
    if (isPlatinumView) return data.totalPlatinumOptimalPrediction;
    if (isPalladiumView) return data.totalPalladiumOptimalPrediction;
    return data.totalSilverOptimalPrediction;
  }

  // ── Metal label helper ──────────────────────────────────────────────────
  String get metalLabel {
    if (isGoldView) return 'Gold';
    if (isPlatinumView) return 'Platinum';
    if (isPalladiumView) return 'Palladium';
    return 'Silver';
  }

  @override
  Widget build(BuildContext context) {
    // ── Filter actual vs prediction ─────────────────────────────────────
    final List<MetalInOunces> actualData = metalInOuncesData
        .where((data) => data.type == 'Actual')
        .toList();
    final List<MetalInOunces> predictionData = metalInOuncesData
        .where((data) => data.type == 'Prediction')
        .toList();

    final MetalInOunces lastActualPoint = actualData.last;
    final List<MetalInOunces> connectedPredictionData = [
      lastActualPoint,
      ...predictionData,
    ];

    // ── Colors ──────────────────────────────────────────────────────────
    Color actualLineColor;
    if (isGoldView) {
      actualLineColor = Colors.orangeAccent;
    } else if (isPlatinumView) {
      actualLineColor = const Color(0xFF93C5FD);
    } else if (isPalladiumView) {
      actualLineColor = const Color(0xFF2DD4BF);
    } else {
      actualLineColor = const Color(0xFF808080);
    }

    const Color predictionLineColor = Color(0xFF97FF00);
    const Color totalLineColor = Color(0xFF0000FF);
    final Color lineColor = isTotalHoldingsView
        ? totalLineColor
        : actualLineColor;

    // ── Labels ──────────────────────────────────────────────────────────
    String labelText;
    Color labelColor;
    switch (selectedTab) {
      case 'Gold Holdings':
        labelText = 'Gold';
        labelColor = Colors.orangeAccent;
        break;
      case 'Silver Holdings':
        labelText = 'Silver';
        labelColor = const Color(0xFF808080);
        break;
      case 'Total Holdings':
        labelText = 'Silver & Gold';
        labelColor = const Color(0xFF0000FF);
        break;
      case 'Platinum Holdings':
        labelText = 'Platinum';
        labelColor = const Color(0xFF93C5FD);
        break;
      case 'Palladium Holdings':
        labelText = 'Palladium';
        labelColor = const Color(0xFF2DD4BF);
        break;
      default:
        labelText = '';
        labelColor = Colors.white;
    }

    // ── Series name ──────────────────────────────────────────────────────
    String seriesName;
    if (isTotalHoldingsView) {
      seriesName = 'Total Holdings';
    } else if (isGoldView) {
      seriesName = 'Gold Holdings';
    } else if (isPlatinumView) {
      seriesName = 'Platinum Holdings';
    } else if (isPalladiumView) {
      seriesName = 'Palladium Holdings';
    } else {
      seriesName = 'Silver Holdings';
    }

    // ── Chart title ──────────────────────────────────────────────────────
    String chartTitle;
    if (isTotalHoldingsView) {
      chartTitle = 'Total Holdings';
    } else if (isGoldView) {
      chartTitle = 'Gold Holdings';
    } else if (isPlatinumView) {
      chartTitle = 'Platinum Holdings';
    } else if (isPalladiumView) {
      chartTitle = 'Palladium Holdings';
    } else {
      chartTitle = 'Silver Holdings';
    }

    // ── Formatters ───────────────────────────────────────────────────────
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

    // ── Combined data ────────────────────────────────────────────────────
    final List<MetalInOunces> combinedData = isPredictionView
        ? [...actualData, ...predictionData]
        : actualData;

    // ── Prediction render flags ──────────────────────────────────────────
    final bool shouldRenderWorstPrediction = combinedData.any((item) {
      if (item.type != 'Prediction') return false;
      return getWorstPrediction(item) > 0;
    });

    final bool shouldRenderOptimalPrediction = combinedData.any((item) {
      if (item.type != 'Prediction') return false;
      return getOptimalPrediction(item) > 0;
    });

    // ✅ All metals now support prediction toggle
    final bool showPredictionToggle = !isTotalHoldingsView;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // ── Header row ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  chartTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showPredictionToggle) ...[
                  Switch(
                    value: isPredictionView,
                    onChanged: onToggleView,
                    activeThumbColor: Colors.blue,
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => PredictionPopup(),
                        );
                      },
                      style: TextButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Prediction',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // ── Legend ───────────────────────────────────────────────────
            if (isPredictionView && !isTotalHoldingsView)
              Wrap(
                spacing: 12.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children: [
                  _buildLegendItem(actualLineColor, metalLabel),
                  _buildLegendItem(
                    predictionLineColor,
                    'Market Analyst Prediction',
                  ),
                  if (shouldRenderWorstPrediction)
                    _buildLegendItem(Colors.red, '$metalLabel Worst'),
                  if (shouldRenderOptimalPrediction)
                    _buildLegendItem(Colors.blue, '$metalLabel Optimal'),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildLegendDot(color: labelColor),
                  const SizedBox(width: 8),
                  Text(
                    labelText,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // ── Chart ────────────────────────────────────────────────────
            Expanded(
              child: combinedData.isEmpty
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

                          final visibleSeriesList =
                              groupingInfo.visibleSeriesList;
                          final points = groupingInfo.points;

                          if (visibleSeriesList == null ||
                              visibleSeriesList.length != points.length) {
                            return const SizedBox();
                          }

                          final Map<String, MetalInOunces> seriesToData = {};
                          for (int i = 0; i < visibleSeriesList.length; i++) {
                            final seriesObj = visibleSeriesList[i];
                            final point = points[i];
                            final String? sName = seriesObj.name as String?;
                            final List<dynamic>? ds = seriesObj.dataSource;

                            if (sName != null &&
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
                              if (dp != null) seriesToData[sName] = dp;
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

                          seriesToData.forEach((sName, dp) {
                            if (sName == 'Silver Holdings') {
                              content.add(
                                Text(
                                  "Silver: ${formatPrice(dp.totalSilverOunces)}",
                                  style: baseStyle,
                                ),
                              );
                            } else if (sName == 'Gold Holdings') {
                              content.add(
                                Text(
                                  "Gold: ${formatPrice(dp.totalGoldOunces)}",
                                  style: baseStyle,
                                ),
                              );
                            } else if (sName == 'Total Holdings') {
                              content.add(
                                Text(
                                  "Total: ${formatPrice(dp.totalOunces)}",
                                  style: baseStyle,
                                ),
                              );
                            } else if (sName == 'Platinum Holdings') {
                              content.add(
                                Text(
                                  "Platinum: ${formatPrice(dp.totalPlatinumOunces)}",
                                  style: baseStyle,
                                ),
                              );
                            } else if (sName == 'Palladium Holdings') {
                              content.add(
                                Text(
                                  "Palladium: ${formatPrice(dp.totalPalladiumOunces)}",
                                  style: baseStyle,
                                ),
                              );
                            } else if (sName == 'Market Prediction') {
                              content.add(
                                Text(
                                  "Market Prediction: \$${getCurrentValue(dp)}",
                                  style: const TextStyle(
                                    color: Colors.lightGreen,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            } else if (sName == 'Worst Prediction') {
                              content.add(
                                Text(
                                  "$metalLabel Worst: \$${getWorstPrediction(dp)}",
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            } else if (sName == 'Optimal Prediction') {
                              content.add(
                                Text(
                                  "$metalLabel Optimal: \$${getOptimalPrediction(dp)}",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
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
                        minimum: getMinY(actualData, predictionData),
                        maximum: getMaxY(actualData, predictionData),
                      ),
                      series: <CartesianSeries<MetalInOunces, DateTime>>[
                        // ── Main actual area series ───────────────────────
                        AreaSeries<MetalInOunces, DateTime>(
                          key: ValueKey(selectedTab),
                          dataSource: actualData,
                          xValueMapper: (MetalInOunces data, _) =>
                              data.orderDate,
                          yValueMapper: (MetalInOunces data, _) =>
                              getCurrentValue(data),
                          color: lineColor,
                          borderWidth: 2,
                          gradient: LinearGradient(
                            colors: [
                              lineColor.withOpacity(0.7),
                              lineColor.withOpacity(0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            tileMode: TileMode.clamp,
                          ),
                          name: seriesName,
                        ),

                        // ── Prediction series ─────────────────────────────
                        if (isPredictionView && showPredictionToggle) ...[
                          AreaSeries<MetalInOunces, DateTime>(
                            key: ValueKey('${selectedTab}_prediction'),
                            dataSource: connectedPredictionData,
                            xValueMapper: (d, _) => d.orderDate,
                            yValueMapper: (d, _) => getCurrentValue(d),
                            color: predictionLineColor.withOpacity(0.4),
                            gradient: LinearGradient(
                              colors: [
                                predictionLineColor.withOpacity(0.7),
                                predictionLineColor.withOpacity(0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              tileMode: TileMode.clamp,
                            ),
                            borderWidth: 0,
                          ),
                          LineSeries<MetalInOunces, DateTime>(
                            key: ValueKey('${selectedTab}_linepredictions'),
                            dataSource: connectedPredictionData,
                            xValueMapper: (d, _) => d.orderDate,
                            yValueMapper: (d, _) => getCurrentValue(d),
                            color: predictionLineColor,
                            width: 1.5,
                            name: 'Market Prediction',
                          ),
                        ],

                        // ── Worst prediction series ───────────────────────
                        if (shouldRenderWorstPrediction &&
                            isPredictionView &&
                            showPredictionToggle) ...[
                          AreaSeries<MetalInOunces, DateTime>(
                            key: ValueKey('${selectedTab}_worstPrediction'),
                            dataSource: connectedPredictionData,
                            xValueMapper: (d, _) => d.orderDate,
                            yValueMapper: (d, _) => getWorstPrediction(d),
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.withOpacity(0.7),
                                Colors.red.withOpacity(0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              tileMode: TileMode.clamp,
                            ),
                            borderWidth: 0,
                          ),
                          LineSeries<MetalInOunces, DateTime>(
                            key: ValueKey('${selectedTab}_lineworstPrediction'),
                            dataSource: connectedPredictionData,
                            xValueMapper: (d, _) => d.orderDate,
                            yValueMapper: (d, _) => getWorstPrediction(d),
                            color: Colors.red,
                            width: 1.5,
                            name: 'Worst Prediction',
                          ),
                        ],

                        // ── Optimal prediction series ─────────────────────
                        if (shouldRenderOptimalPrediction &&
                            isPredictionView &&
                            showPredictionToggle) ...[
                          AreaSeries<MetalInOunces, DateTime>(
                            key: ValueKey('${selectedTab}_Optimalprediction'),
                            dataSource: connectedPredictionData,
                            xValueMapper: (d, _) => d.orderDate,
                            yValueMapper: (d, _) => getOptimalPrediction(d),
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.withOpacity(0.7),
                                Colors.blue.withOpacity(0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              tileMode: TileMode.clamp,
                            ),
                            borderWidth: 0,
                          ),
                          LineSeries<MetalInOunces, DateTime>(
                            key: ValueKey(
                              '${selectedTab}_LineOptimalprediction',
                            ),
                            dataSource: connectedPredictionData,
                            xValueMapper: (d, _) => d.orderDate,
                            yValueMapper: (d, _) => getOptimalPrediction(d),
                            color: Colors.blue,
                            width: 1.5,
                            name: 'Optimal Prediction',
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

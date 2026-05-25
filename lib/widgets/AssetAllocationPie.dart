import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AssetAllocationPieChart extends StatelessWidget {
  final double goldPercentage;
  final double silverPercentage;
  final double platinumPercentage;
  final double palladiumPercentage;

  const AssetAllocationPieChart({
    super.key,
    required this.goldPercentage,
    required this.silverPercentage,
    this.platinumPercentage = 0,
    this.palladiumPercentage = 0,
  });

  @override
  Widget build(BuildContext context) {
    final List<_PieData> data = [
      if (goldPercentage > 0)
        _PieData('Gold', goldPercentage, const Color(0xFFFFD700)),
      if (silverPercentage > 0)
        _PieData('Silver', silverPercentage, const Color(0xFFC0C0C0)),
      if (platinumPercentage > 0)
        _PieData('Platinum', platinumPercentage, const Color(0xFF93C5FD)),
      if (palladiumPercentage > 0)
        _PieData('Palladium', palladiumPercentage, const Color(0xFF2DD4BF)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Asset Allocation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),

        // ── Pie Chart ──────────────────────────────────────────
        SizedBox(
          height: 280,
          child: SfCircularChart(
            margin: EdgeInsets.zero,
            series: <CircularSeries>[
              PieSeries<_PieData, String>(
                dataSource: data,
                xValueMapper: (_PieData d, _) => d.name,
                yValueMapper: (_PieData d, _) => d.value,
                pointColorMapper: (_PieData d, _) => d.color,
                radius: '70%',
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  // ✅ CORRECT property name
                  labelIntersectAction: LabelIntersectAction.shift,
                  connectorLineSettings: const ConnectorLineSettings(
                    type: ConnectorType.line,
                    length: '20%',
                    width: 1.5,
                  ),
                  useSeriesColor: true,
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                dataLabelMapper: (_PieData d, _) =>
                    '${d.name}\n${d.value.toStringAsFixed(2)}%',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Permanent Legend ───────────────────────────────────
        // ✅ Always visible — guarantees all 4 values shown even if labels overlap
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: data.map((item) {
            // ✅ Gold & Silver are too light for colored text — use black
            final bool isLightColor =
                item.color == const Color(0xFFFFD700) ||
                item.color == const Color(0xFFC0C0C0);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                    border: isLightColor
                        ? Border.all(color: Colors.black26, width: 0.5)
                        : null,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.name}  ${item.value.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isLightColor ? Colors.black87 : item.color,
                  ),
                ),
              ],
            );
          }).toList(),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

class _PieData {
  final String name;
  final double value;
  final Color color;

  _PieData(this.name, this.value, this.color);
}

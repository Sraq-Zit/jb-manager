import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/theme/color_palette.dart';
import 'package:flutter_app/theme/sizes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum Variation { axis, rods }

class BarChartCard extends StatefulWidget {
  late final String title;
  late final IconData icon;
  late final Color color;
  late final BarChartData barChartData;
  late final List<String>? legendLabels;
  late final List<String>? axisLabels;
  late final bool showLegends;
  late final Variation variation;
  late final double? barWidth;

  BarChartCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.barChartData,
    this.legendLabels,
    this.axisLabels,
    this.showLegends = true,
    this.variation = Variation.axis,
    this.barWidth,
  }) : super(key: key);

  @override
  _BarChartCardState createState() => _BarChartCardState();
}

class _BarChartCardState extends State<BarChartCard> {
  late final String title;
  late final IconData icon;
  late final Color color;
  late final BarChartData barChartData;
  late final List<String>? legendLabels;
  late final List<String>? axisLabels;
  late final bool showLegends;
  late final Variation variation;
  late final double? barWidth;

  late double _maxY;

  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    title = widget.title;
    icon = widget.icon;
    color = widget.color;
    barChartData = widget.barChartData;
    legendLabels = widget.legendLabels;
    axisLabels = widget.axisLabels;
    showLegends = widget.showLegends;
    variation = widget.variation;
    barWidth = widget.barWidth;

    _maxY = barChartData.barGroups
        .map((g) => g.barRods.map((r) => r.toY).reduce((a, b) => a + b))
        .reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(title),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0.5) {
          setState(() {
            _isVisible = true;
          });
        }
      },

      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(icon, color: color, size: 22),
                    ),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      text: title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (showLegends && (legendLabels != null || axisLabels != null))
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: (legendLabels ?? axisLabels)!.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final label = entry.value;
                    final color = ColorPalette
                        .chartColors[index % ColorPalette.chartColors.length];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _buildLegendItem(color, label),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  barChartData.copyWith(
                    // maxY: _isVisible ? null : _maxY * 10,
                    barGroups: barChartData.barGroups.asMap().entries.map((
                      entry,
                    ) {
                      final index = entry.key;
                      final group = entry.value;
                      return group.copyWith(
                        barRods: group.barRods.asMap().entries.map((entry) {
                          final rod = entry.value;
                          final rodIndex = entry.key;
                          final i = variation == Variation.axis
                              ? index
                              : rodIndex;
                          return rod.copyWith(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            width: barWidth,
                            color:
                                ColorPalette.chartColors[i %
                                    ColorPalette.chartColors.length],
                          );
                        }).toList(),
                      );
                    }).toList(),
                    borderData: barChartData.borderData.copyWith(
                      border: Border.all(width: 0),
                    ),
                    titlesData: barChartData.titlesData.copyWith(
                      rightTitles: AxisTitles(drawBelowEverything: false),
                      topTitles: AxisTitles(drawBelowEverything: false),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return RichText(
                              textAlign: TextAlign.right,
                              text: TextSpan(
                                text: NumberFormat.compact().format(value),
                                style: GoogleFonts.inter(
                                  fontSize: Sizes.textSm,
                                  fontWeight: Sizes.weightMedium,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final style = TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.bold,
                              fontSize: Sizes.textSm,
                            );
                            final label = axisLabels == null
                                ? value.toInt().toString()
                                : (value.toInt() < axisLabels!.length
                                      ? axisLabels![value.toInt()]
                                      : '');
                            return Text(label, style: style);
                          },
                        ),
                      ),
                    ),
                    gridData: barChartData.gridData.copyWith(
                      verticalInterval: 2,
                      getDrawingHorizontalLine: (v) =>
                          FlLine(color: Colors.grey.shade100),
                    ),
                  ),
                  duration: const Duration(seconds: 1),
                  curve: Curves.fastLinearToSlowEaseIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: Sizes.weightBold)),
      ],
    );
  }
}

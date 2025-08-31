import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_app/theme/sizes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/theme/color_palette.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum Unit { currency, percentage }

class PieChartCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<String> legends;
  final List<double> data;
  final String totalLabel;
  final String subTitle;
  final String subValue;
  final Unit unit;
  final String currency;

  final double _pieRadius = 35;

  const PieChartCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.legends,
    required this.data,
    this.totalLabel = 'Total',
    this.subTitle = '',
    this.subValue = '',
    this.unit = Unit.currency,
    this.currency = 'DH',
  }) : super(key: key);

  @override
  _PieChartCardState createState() => _PieChartCardState();
}

class _PieChartCardState extends State<PieChartCard> {
  late double _sum;
  late List<double> _percents;
  bool _isVisible = false;
  List<double> _animatedData = [];

  @override
  void initState() {
    super.initState();

    _sum = widget.data.reduce((a, b) => a + b);
    _percents = widget.data.map((v) => v / _sum).toList();
    _animatedData = widget.data + [_sum * 100];
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.title),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0.5 && !_isVisible) {
          setState(() {
            _isVisible = true;
            _animatedData.last = 0;
          });
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Icon(widget.icon, size: 22, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      text: widget.title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 45,
                        sectionsSpace: 4,
                        sections: _animatedData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final value = entry.value;
                          final colors = ColorPalette.chartColors;
                          final color = index < widget.data.length
                              ? colors[index % colors.length]
                              : Colors.transparent;
                          return PieChartSectionData(
                            color: color,
                            value: value,
                            radius: widget._pieRadius,
                            title: '',
                          );
                        }).toList(),
                      ),
                      duration: const Duration(seconds: 5),
                      curve: Curves.fastLinearToSlowEaseIn,
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: NumberFormat.compact().format(
                                widget.data.reduce((a, b) => a + b),
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: widget.totalLabel,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: widget.data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  final colors = [Colors.blue, Colors.orange];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: _buildDetailTile(
                      title: widget.legends[index % widget.legends.length],
                      value: value,
                      percentage: _percents[index] * 100,
                      color: colors[index % colors.length],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              if (widget.subValue.isNotEmpty && widget.subTitle.isNotEmpty)
                Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        text: widget.subTitle,
                        style: GoogleFonts.inter(
                          fontSize: Sizes.textSm,
                          fontWeight: Sizes.weightMedium,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        text: widget.subValue,
                        style: GoogleFonts.inter(
                          fontSize: Sizes.textXl,
                          fontWeight: Sizes.weightExtraBold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required String title,
    required double value,
    required double percentage,
    required Color color,
  }) {
    final legendSize = 16.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: legendSize,
                height: legendSize,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          Row(
            children: [
              RichText(
                text: TextSpan(
                  text: NumberFormat.compact().format(value),
                  style: GoogleFonts.inter(
                    fontSize: Sizes.textLg,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 32,
                child: Text(
                  widget.unit == Unit.currency
                      ? widget.currency
                      : '${percentage.round().toString()}%',
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

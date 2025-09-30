import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jbmanager/models/home_data.dart';
import 'package:jbmanager/theme/color_palette.dart';
import 'package:jbmanager/theme/sizes.dart';
import 'package:jbmanager/providers/home_provider.dart';
import 'package:jbmanager/widgets/loader.dart';
import 'package:provider/provider.dart';
import 'package:jbmanager/widgets/bar_chart_card.dart';
import 'package:jbmanager/widgets/custom_card.dart';
import 'package:jbmanager/widgets/pie_chart_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider()..fetchHomeData(),
      builder: (context, _) {
        // return Container();
        final provider = Provider.of<HomeProvider>(context);
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   if (!provider.isInit) {
        //     provider.isInit = true;
        //     // provider.refreshKey.currentState?.show();
        //     provider.fetchHomeData();
        //   }
        // });
        final homeData = provider.homeData ?? HomeData.sample;
        final tags = ['+12%', '+8%', 'Reçus', 'En cours'];
        final tagColors = [Colors.green, Colors.blue];
        final salesAnalysis = homeData.salesAnalysis.getLastMonths();
        final summaryData = homeData.summary
            .asMap()
            .entries
            .map(
              (e) => _buildCard(
                context,
                provider.homeData == null,

                icon: LucideIcons.euro,
                title: e.value.title,
                value: e.value.value.replaceFirst(' DH', ''),
                tag: tags[e.key % tags.length],
                tagColor: tagColors[e.key % tagColors.length],
                color: ColorPalette
                    .chartColors[e.key % ColorPalette.chartColors.length],
                footerName: e.value.footerName,
                footerValue: e.value.footerValue,
              ),
            )
            .toList();

        return provider.homeData == null
            ? Center(child: Loader())
            : RefreshIndicator(
                key: provider.refreshKey,
                onRefresh: () {
                  return provider.fetchHomeData();
                },

                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(Sizes.sapcing4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Grid Cards
                        Column(
                          spacing: Sizes.sapcing4,
                          children: [
                            for (int i = 0; i < summaryData.length; i += 2)
                              Row(
                                spacing: Sizes.sapcing4,
                                children: [
                                  Expanded(child: summaryData[i]),
                                  if (i + 1 < summaryData.length)
                                    Expanded(child: summaryData[i + 1])
                                  else
                                    Expanded(child: SizedBox()),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: Sizes.sapcing6),

                        // PieChartCard 1
                        provider.homeData == null
                            ? _buildSkeleton(height: 200)
                            : PieChartCard(
                                title: 'Recette',
                                icon: LucideIcons.euro,
                                legends: homeData.incomeStats.legendLabels,
                                data: homeData.incomeStats.legendValues,
                                totalLabel: 'Variation',
                                subTitle: homeData.incomeStats.footer.textKey,
                                subValue: homeData.incomeStats.footer.textValue,
                              ),
                        const SizedBox(height: Sizes.sapcing6),

                        // BarChartCard 1
                        provider.homeData == null
                            ? _buildSkeleton(height: 250)
                            : BarChartCard(
                                title: 'Chiffre d\'affaires',
                                icon: LucideIcons.barChart3,
                                color: Colors.purple.shade700,
                                axisLabels: homeData.salesStats.labels,
                                showLegends: false,
                                barWidth: 40,
                                barChartData: BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  barGroups: homeData.salesStats.values
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) => BarChartGroupData(
                                          x: entry.key,
                                          barRods: [
                                            BarChartRodData(toY: entry.value),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                        const SizedBox(height: Sizes.sapcing6),

                        // PieChartCard 2
                        provider.homeData == null
                            ? _buildSkeleton(height: 200)
                            : PieChartCard(
                                title: 'Facture clients',
                                icon: LucideIcons.fileText,
                                legends: homeData.invoicesStats.legendLabels,
                                data: homeData.invoicesStats.legendValues,
                                subTitle: homeData.invoicesStats.footer.textKey,
                                subValue:
                                    homeData.invoicesStats.footer.textValue,
                                unit: Unit.percentage,
                              ),
                        const SizedBox(height: Sizes.sapcing6),

                        // BarChartCard 2
                        provider.homeData == null
                            ? _buildSkeleton(height: 250)
                            : BarChartCard(
                                title: 'Évolution du chiffre d\'affaires',
                                icon: LucideIcons.trendingUp,
                                height: 300,
                                color: Colors.blue.shade700,
                                legendLabels: salesAnalysis.legendLabels,
                                axisLabels: salesAnalysis.axisLabels,
                                showLegends: true,
                                variation: Variation.rods,
                                barWidth: min(
                                  40.0,
                                  110 / salesAnalysis.values.length,
                                ),
                                barChartData: BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  barGroups: salesAnalysis.values
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) => BarChartGroupData(
                                          x: entry.key,
                                          barRods: entry.value
                                              .asMap()
                                              .entries
                                              .map(
                                                (e) => BarChartRodData(
                                                  toY: e.value ?? 0,
                                                  color:
                                                      ColorPalette.chartColors[e
                                                              .key %
                                                          ColorPalette
                                                              .chartColors
                                                              .length],
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              );
      },
    );
  }

  // Helper for grid cards
  Widget _buildCard(
    BuildContext context,
    bool isLoading, {
    required IconData icon,
    required String title,
    required String value,
    required String tag,
    required Color color,
    Color? tagColor,
    required String footerName,
    required String footerValue,
  }) {
    if (isLoading) {
      return _buildSkeleton(height: 120);
    }
    return CustomCard(
      icon: icon,
      title: title,
      value: value,
      subtitle: tag,
      color: color,
      subColor: tagColor ?? Colors.green,
      footerName: footerName,
      footerValue: footerValue,
    );
  }

  // Generic skeleton placeholder
  Widget _buildSkeleton({double height = 100}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

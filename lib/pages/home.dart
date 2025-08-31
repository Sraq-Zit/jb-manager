import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/theme/sizes.dart';
import 'package:flutter_app/providers/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/widgets/bar_chart_card.dart';
import 'package:flutter_app/widgets/custom_card.dart';
import 'package:flutter_app/widgets/pie_chart_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: Consumer<HomeProvider>(
        builder: (context, homeProvider, _) {
          return HomeContent(provider: homeProvider);
        },
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final HomeProvider provider;

  const HomeContent({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.sapcing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: Sizes.sapcing4,
              mainAxisSpacing: Sizes.sapcing4,
              children: const [
                CustomCard(
                  icon: LucideIcons.euro,
                  title: 'CA 2025',
                  value: '1,445,744.28',
                  subtitle: '+12%',
                  color: Colors.blue,
                  footerName: 'Solde',
                  footerValue: '357 140.36 DH',
                ),
                CustomCard(
                  icon: LucideIcons.trendingUp,
                  title: 'CA 08-2025',
                  value: '76,661.20',
                  subtitle: '+8%',
                  color: Colors.green,
                  subColor: Colors.blue,
                  footerName: 'Ventes',
                  footerValue: '19',
                ),
                CustomCard(
                  icon: LucideIcons.checkCircle,
                  title: 'ENCAISSEMENTS',
                  value: '1,796,109.38',
                  subtitle: 'Reçus',
                  color: Colors.purple,
                  footerName: 'Portef',
                  footerValue: '14 316.00 DH',
                ),
                CustomCard(
                  icon: LucideIcons.clock,
                  title: 'ENCOURS',
                  value: '371,456.36',
                  subtitle: 'En cours',
                  color: Colors.orange,
                  subColor: Colors.blue,
                  footerName: 'Taux Recouvr',
                  footerValue: '124 %',
                ),
              ],
            ),
            const SizedBox(height: Sizes.sapcing6),
            PieChartCard(
              title: 'Recette',
              icon: LucideIcons.euro,
              legends: const ['Encaissements', 'Décaissements'],
              data: const [369_645.048, 246_430.032],
              totalLabel: "Variation",
              subTitle: "Variation totale",
              subValue: "616 075.08 DH",
            ),
            const SizedBox(height: Sizes.sapcing6),
            BarChartCard(
              title: 'Chiffre d\'affaires',
              icon: LucideIcons.barChart3,
              color: Colors.purple.shade700,
              axisLabels: const ['MG', 'Rég', 'FA', 'Ac', 'Pr', 'DV'],
              showLegends: false,
              barWidth: 40,
              barChartData: BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [BarChartRodData(toY: 903492)],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [BarChartRodData(toY: 580000)],
                  ),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 0)]),
                  BarChartGroupData(
                    x: 3,
                    barRods: [BarChartRodData(toY: 1300000)],
                  ),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 0)]),
                  BarChartGroupData(
                    x: 5,
                    barRods: [BarChartRodData(toY: 2003000)],
                  ),
                ],
              ),
            ),
            PieChartCard(
              title: 'Facture clients',
              icon: LucideIcons.fileText,
              legends: const ['En retard', 'Non réglées', 'Réglées', 'Avoirs'],
              data: const [18, 3, 77, 3],
              subTitle: "Restant dû",
              subValue: "357 140.36 DH",
              unit: Unit.percentage,
            ),
            const SizedBox(height: Sizes.sapcing6),
            BarChartCard(
              title: 'Évolution du chiffre d\'affaires',
              icon: LucideIcons.trendingUp,
              color: Colors.blue.shade700,
              legendLabels: const ['2025', '2024'],
              axisLabels: [
                'Jan',
                'Feb',
                'Mar',
                'Avr',
                'Mai',
                'Jun',
                'Jul',
                'Aoû',
              ],
              showLegends: true,
              variation: Variation.rods,
              barWidth: 20,
              barChartData: BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(toY: 290000),
                      BarChartRodData(toY: 230000),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(toY: 200000),
                      BarChartRodData(toY: 150000),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(toY: 100000),
                      BarChartRodData(toY: 80000),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(toY: 450000),
                      BarChartRodData(toY: 300000),
                    ],
                  ),
                  BarChartGroupData(
                    x: 4,
                    barRods: [
                      BarChartRodData(toY: 300000),
                      BarChartRodData(toY: 200000),
                    ],
                  ),
                  BarChartGroupData(
                    x: 5,
                    barRods: [
                      BarChartRodData(toY: 600000),
                      BarChartRodData(toY: 400000),
                    ],
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

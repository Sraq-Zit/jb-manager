import 'dart:math';

class HomeData {
  final List<Summary> summary;
  final IncomeStats incomeStats;
  final InvoicesStats invoicesStats;
  final SalesStats salesStats;
  final SalesAnalysis salesAnalysis;

  const HomeData({
    required this.summary,
    required this.incomeStats,
    required this.invoicesStats,
    required this.salesStats,
    required this.salesAnalysis,
  });

  static const HomeData sample = HomeData(
    summary: [
      Summary(
        value: '1 800.00 DH',
        title: 'CA 2025',
        footerName: 'Solde',
        footerValue: '1 800.00 DH',
      ),
      Summary(
        value: '0.00 DH',
        title: 'CA 09-2025',
        footerName: 'Ventes',
        footerValue: '0',
      ),
      Summary(
        value: '20 000.00 DH',
        title: 'Encaissements',
        footerName: 'En Portef.',
        footerValue: '0.00 DH',
      ),
      Summary(
        value: '1 800.00 DH',
        title: 'Encours',
        footerName: 'Taux Recouvr.',
        footerValue: '11.11 %',
      ),
    ],
    incomeStats: IncomeStats.sample,
    invoicesStats: InvoicesStats.sample,
    salesStats: SalesStats.sample,
    salesAnalysis: SalesAnalysis.sample,
  );

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      summary: (json['summary'] as List)
          .map((item) => Summary.fromJson(item))
          .toList(),
      incomeStats: IncomeStats.fromJson(json['incomeStats']),
      invoicesStats: InvoicesStats.fromJson(json['invoicesStats']),
      salesStats: SalesStats.fromJson(json['salesStats']),
      salesAnalysis: SalesAnalysis.fromJson(
        (json['salesAnalysis'] as Map<String, dynamic>).map(
          (year, value) => MapEntry(
            year,
            (value as Map<String, dynamic>).map(
              (month, v) => MapEntry(month, double.tryParse(v.toString()) ?? 0),
            ),
          ),
        ),
      ),
    );
  }
}

class Summary {
  final String value;
  final String title;
  final String footerName;
  final String footerValue;

  const Summary({
    required this.value,
    required this.title,
    required this.footerName,
    required this.footerValue,
  });

  static const Summary sample = Summary(
    value: '1 800.00 DH',
    title: 'CA 2025',
    footerName: 'Solde',
    footerValue: '1 800.00 DH',
  );

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      value: json['text1'],
      title: json['text2'],
      footerName: json['text3'],
      footerValue: json['text4'],
    );
  }
}

class IncomeStats {
  final List<NameValue> values;
  final Footer footer;

  List<String> get legendLabels => values.map((e) => e.name).toList();
  List<double> get legendValues => values.map((e) => e.value).toList();

  const IncomeStats({required this.values, required this.footer});

  static const IncomeStats sample = IncomeStats(
    values: [
      NameValue(name: 'Encaissements', value: 20000),
      NameValue(name: 'Décaissements', value: 0),
    ],
    footer: Footer(text: 'Variation : 20 000.00 DH', color: '0,255,0'),
  );

  factory IncomeStats.fromJson(Map<String, dynamic> json) {
    return IncomeStats(
      values: (json['values'] as List)
          .map((item) => NameValue.fromJson(item))
          .toList(),
      footer: Footer.fromJson(json['footer']),
    );
  }
}

class NameValue {
  final String name;
  final double value;

  const NameValue({required this.name, required this.value});

  static const NameValue sample = NameValue(name: 'Sales', value: 1000.0);

  factory NameValue.fromJson(Map<String, dynamic> json) {
    return NameValue(
      name: json['name'],
      value: double.tryParse(json['value'].toString()) ?? 0,
    );
  }
}

class Footer {
  final String text;
  final String color;

  String get textKey => text.split(' : ').first;
  String get textValue => text.split(' : ').last;

  const Footer({required this.text, required this.color});

  static const Footer sample = Footer(text: 'Good Performance', color: 'green');

  factory Footer.fromJson(Map<String, dynamic> json) {
    return Footer(text: json['text'], color: json['color']);
  }
}

class InvoicesStats {
  final List<TypeNameValue> values;
  final Footer footer;

  List<String> get legendLabels => values.map((e) => e.name).toList();
  List<double> get legendValues => values.map((e) => e.value).toList();

  const InvoicesStats({required this.values, required this.footer});

  static const InvoicesStats sample = InvoicesStats(
    values: [TypeNameValue(type: 'FNR', name: 'Non réglées', value: 1800.00)],
    footer: Footer(text: 'Restant dû : 1 800.00 DH', color: '0,0,0'),
  );

  factory InvoicesStats.fromJson(Map<String, dynamic> json) {
    return InvoicesStats(
      values: (json['values'] as List)
          .map((item) => TypeNameValue.fromJson(item))
          .toList(),
      footer: Footer.fromJson(json['footer']),
    );
  }
}

class TypeNameValue {
  final String type;
  final String name;
  final double value;

  const TypeNameValue({
    required this.type,
    required this.name,
    required this.value,
  });

  static const TypeNameValue sample = TypeNameValue(
    type: 'Invoice',
    name: 'January',
    value: 500,
  );

  factory TypeNameValue.fromJson(Map<String, dynamic> json) {
    return TypeNameValue(
      type: json['type'],
      name: json['name'],
      value: double.tryParse(json['value'].toString()) ?? 0,
    );
  }
}

class SalesStats {
  final List<String> labels;
  final List<double> values;

  const SalesStats({required this.labels, required this.values});

  static const SalesStats sample = SalesStats(
    labels: ['DV', 'AC', 'BL', 'FA', 'MG', 'Rég'],
    values: [2003000, 1300000, 0, 903492, 580000, 0],
  );

  factory SalesStats.fromJson(Map<String, dynamic> json) {
    return SalesStats(
      labels: json.keys.toList(),
      values: json.values
          .map<double>((v) => double.tryParse(v.toString()) ?? 0)
          .toList(),
    );
  }
}

class SalesAnalysis {
  static const months = {
    "01": "Jan",
    "02": "Feb",
    "03": "Mar",
    "04": "Apr",
    "05": "May",
    "06": "Jun",
    "07": "Jul",
    "08": "Aug",
    "09": "Sep",
    "10": "Oct",
    "11": "Nov",
    "12": "Dec",
  };

  final List<String> axisLabels;
  final List<String> legendLabels;
  final List<List<double?>> values;

  const SalesAnalysis({
    required this.axisLabels,
    required this.values,
    required this.legendLabels,
  });

  SalesAnalysis getLastMonths({int months = 6}) {
    int maxIndex = 0;
    values.asMap().forEach((index, value) {
      if (value.any((element) => element != null)) {
        maxIndex = index;
      }
    });
    maxIndex = max(maxIndex, months);
    return SalesAnalysis(
      axisLabels: axisLabels.sublist(
        max(0, maxIndex - months),
        min(axisLabels.length, maxIndex),
      ),
      values: values.sublist(
        max(0, maxIndex - months),
        min(values.length, maxIndex),
      ),
      legendLabels: legendLabels,
    );
  }

  factory SalesAnalysis.fromJson(Map<String, dynamic> json) {
    final legendLabels = json.keys.toList();
    final monthsSet = <String>{};
    final tempValues = <String, Map<String, double>>{};

    for (var year in legendLabels) {
      final yearData = json[year] as Map<String, dynamic>;
      yearData.forEach((month, value) {
        month = month.split('-').first;
        monthsSet.add(month);
        tempValues.putIfAbsent(month, () => {});
        tempValues[month]![year] = double.tryParse(value.toString()) ?? 0;
      });
    }

    final axisLabels = monthsSet.toList()..sort();
    final values = axisLabels.map((month) {
      return legendLabels.map((year) {
        return tempValues[month]?[year] ?? null;
      }).toList();
    }).toList();

    return SalesAnalysis(
      axisLabels: axisLabels.map((m) => months[m] ?? m).toList(),
      legendLabels: legendLabels,
      values: values,
    );
  }

  static const SalesAnalysis sample = SalesAnalysis(
    legendLabels: ['2024', '2025'],
    axisLabels: [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ],
    values: [
      [119760, 0],
      [0, 1800],
      [903492, 0],
      [800000, 0],
      [119760, 0],
      [0, 1800],
      [903492, 0],
      [800000, 0],
      [119760, 0],
      [0, 1800],
      [903492, 0],
      [800000, 0],
    ],
  );
}

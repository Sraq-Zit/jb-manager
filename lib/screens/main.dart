import 'package:flutter/material.dart';
import 'package:flutter_app/theme/sizes.dart';
import 'package:flutter_app/widgets/pie_chart_card.dart';
import 'package:flutter_app/widgets/custom_drawer.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/custom_card.dart';
import '../pages/home.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Map<String, dynamic>?> _navOptions = const [
    {'icon': LucideIcons.barChart3, 'label': 'Accueil'},
    {'icon': LucideIcons.users, 'label': 'Clients'},
    null,
    {'icon': LucideIcons.fileText, 'label': 'Devis'},
    {'icon': LucideIcons.trendingUp, 'label': 'Stats'},
  ];

  late List<bool> _navTapDown;
  int _currentNav = 0;

  @override
  void initState() {
    super.initState();

    _navTapDown = List<bool>.filled(_navOptions.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JB Manager'),
        surfaceTintColor: Colors.white,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(LucideIcons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: CustomDrawer(
        onOptionSelected: (option) {
          setState(
            () => _currentNav = _navOptions.indexWhere(
              (item) => item?['label'] == option,
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 32 - Sizes.sapcing4),
        child: Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            border: Border.all(color: Colors.white, width: 5),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                spreadRadius: 1,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: InkWell(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                highlightColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
                splashColor: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(100),
                onTap: () {},
                child: const Center(
                  child: Icon(Icons.add, size: 20, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),

      body: const HomeBody(),
      bottomNavigationBar: BottomAppBar(
        height: 65,
        padding: const EdgeInsets.all(0.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            spacing: 0,
            children: _navOptions.asMap().entries.map<Expanded>((entry) {
              final index = entry.key;
              final option = entry.value;
              if (option == null) return Expanded(child: Container());
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Container(
                    // make rounded borders
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: _currentNav == index
                          ? Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      child: InkWell(
                        onTapDown: (_) =>
                            setState(() => _navTapDown[index] = true),
                        onTapCancel: () =>
                            setState(() => _navTapDown[index] = false),
                        onTapUp: (_) =>
                            setState(() => _navTapDown[index] = false),

                        onTap: () => setState(() => _currentNav = index),
                        highlightColor: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.15),
                        splashColor: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.2),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              option['icon'],
                              size: 16,
                              weight: 20,
                              color: _navTapDown[index] || _currentNav == index
                                  ? Theme.of(context).colorScheme.secondary
                                  : Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              option['label'],
                              style: TextStyle(
                                color:
                                    _navTapDown[index] || _currentNav == index
                                    ? Theme.of(context).colorScheme.secondary
                                    : Colors.grey,
                                fontWeight: Sizes.weightBold,
                                fontSize: Sizes.textXs,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

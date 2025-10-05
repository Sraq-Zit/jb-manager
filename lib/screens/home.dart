import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jbmanager/providers/auth_provider.dart';
import 'package:jbmanager/providers/ui_provider.dart';
import 'package:jbmanager/theme/sizes.dart';
import 'package:jbmanager/widgets/appbar.dart';
import 'package:jbmanager/widgets/custom_drawer.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _navOptions = const [
    (LucideIcons.barChart3, 'Accueil', MenuOption.dashboard),
    (LucideIcons.shoppingCart, 'Ventes', MenuOption.sales),
    null,
    (LucideIcons.package, 'Achats', MenuOption.purchases),
    (LucideIcons.trendingUp, 'Activités', MenuOption.activities),
  ];

  late List<bool> _navTapDown;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UiProvider(),
      builder: (context, _) {
        final provider = Provider.of<UiProvider>(context);
        final jbAppBar = JBAppBar(
          onSearch: !menusWithSearchIcon.contains(provider.currentMenuOption)
              ? null
              : provider.search,
        );
        return Scaffold(
          appBar: jbAppBar.build(context),
          drawer: _buildDrawer(context),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildFAB(context),
          body: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            behavior: HitTestBehavior.translucent,
            child: provider.buildBody(),
          ),
          // body: BlobCreator(),
          bottomNavigationBar: _buildBottomNav(context),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _navTapDown = List<bool>.filled(_navOptions.length, false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomAppBar(
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
        child: Consumer<UiProvider>(
          builder: (context, uiProvider, _) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            spacing: 0,
            children: _navOptions.asMap().entries.map<Expanded>((entry) {
              final index = entry.key;
              final option = entry.value;
              if (option == null) return Expanded(child: Container());

              final icon = option.$1;
              final label = option.$2;
              final menuOption = option.$3;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: uiProvider.currentMenuOption == menuOption
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
                        onTap: () => setState(
                          () => uiProvider.selectMenuOption(menuOption),
                        ),
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
                              icon,
                              size: 16,
                              weight: 20,
                              color:
                                  _navTapDown[index] ||
                                      uiProvider.currentMenuOption == menuOption
                                  ? Theme.of(context).colorScheme.secondary
                                  : Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              label,
                              style: TextStyle(
                                color:
                                    _navTapDown[index] ||
                                        uiProvider.currentMenuOption ==
                                            menuOption
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

  Widget _buildDrawer(BuildContext context) {
    return CustomDrawer(
      onOptionSelected: (option) {
        if (option == MenuOption.logout) {
          showDialog(
            context: context,
            builder: (BuildContext drawerContext) {
              return AlertDialog(
                title: Text('Confirmation'),
                content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(drawerContext).pop(),
                    child: Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(drawerContext).pop();
                      Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).logout();
                    },
                    child: Text('Confirmer'),
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Transform.translate(
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
    );
  }
}

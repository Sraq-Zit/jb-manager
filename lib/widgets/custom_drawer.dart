import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jbmanager/constants/assets.dart';
import 'package:jbmanager/providers/ui_provider.dart';
import 'package:jbmanager/theme/app_theme.dart';
import 'package:jbmanager/theme/sizes.dart';
import 'package:jbmanager/widgets/frozen_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  final Function(MenuOption) onOptionSelected;
  static const options = [
    (MenuOption.dashboard, LucideIcons.barChart3, 'Tableau de bord'),
    (MenuOption.sales, LucideIcons.shoppingCart, 'Ventes'),
    (MenuOption.purchases, LucideIcons.package, 'Achats'),
    (MenuOption.activities, LucideIcons.trendingUp, 'Activités'),
    null,
    (MenuOption.settings, LucideIcons.settings, 'Paramètres'),
    (MenuOption.help, LucideIcons.helpCircle, 'Aide'),
  ];

  const CustomDrawer({super.key, required this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    const paddingV = Sizes.sapcing8;
    const paddingH = Sizes.sapcing4;
    // return Drawer(child: Container());
    return Drawer(
      width: 340,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FrozenWidget(
                identifier: 'drawer_header',
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  padding:
                      EdgeInsets.symmetric(
                        horizontal: paddingH,
                        vertical: paddingV,
                      ).add(
                        EdgeInsets.only(
                          top: max(
                            paddingV,
                            MediaQuery.of(context).padding.top,
                          ),
                        ),
                      ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                                child: Center(
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundImage: AssetImage(Assets.appLogo),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: 'JB Manager',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: Sizes.textXl,
                                        fontWeight: Sizes.weightBold,
                                      ),
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Gestion Commerciale',
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: Sizes.textSm,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Consumer<UiProvider>(
                  builder: (context, uiProvider, child) {
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(
                        vertical: Sizes.sapcing6,
                        horizontal: Sizes.sapcing4,
                      ),
                      itemBuilder: (context, index) {
                        final option = options[index];

                        if (option == null) {
                          return Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                            height: Sizes.sapcing4 * 2,
                          );
                        }

                        final isSelected =
                            option.$1 == uiProvider.currentMenuOption;

                        return Container(
                          clipBehavior: isSelected ? Clip.none : Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Material(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: InkWell(
                                onTap: isSelected
                                    ? null
                                    : () {
                                        uiProvider.selectMenuOption(option.$1);
                                        Navigator.of(context).pop();
                                        onOptionSelected(option.$1);
                                      },
                                child: FrozenWidget(
                                  identifier:
                                      'drawer_option_${option.$1}_selected_$isSelected',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: !isSelected
                                          ? null
                                          : LinearGradient(
                                              colors: [
                                                Color.lerp(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: 0.1),
                                                  Colors.white,
                                                  0.9,
                                                )!,
                                                Color.lerp(
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.secondary,
                                                  Colors.white,
                                                  0.95,
                                                )!,
                                              ],
                                            ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: !isSelected
                                          ? null
                                          : Border(
                                              left: BorderSide(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                width: 4.5,
                                              ),
                                            ),
                                      boxShadow: !isSelected
                                          ? null
                                          : [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF2196F3,
                                                ).withValues(alpha: 0.15),
                                                offset: const Offset(0, 4),
                                                blurRadius: 12,
                                              ),
                                            ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          option.$2,
                                          color: !isSelected
                                              ? Colors.grey.shade700
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          option.$3,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: !isSelected
                                                ? Colors.grey.shade700
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: Sizes.sapcing2),
                      itemCount: options.length,
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: Sizes.sapcing8,
                    vertical: Sizes.sapcing3,
                  ),
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: RichText(
                    text: TextSpan(
                      text: 'Déconnexion',
                      style: GoogleFonts.inter(
                        color: Colors.red,
                        fontWeight: Sizes.weightBold,
                      ),
                    ),
                  ),
                  onTap: () => onOptionSelected(MenuOption.logout),
                ),
              ),
            ],
          ),
          Positioned(
            top: max(paddingV, MediaQuery.of(context).padding.top) + 32,
            right: 18,
            child: IconButton(
              icon: const Icon(LucideIcons.x, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

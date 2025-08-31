import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/theme/sizes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomDrawer extends StatelessWidget {
  final Function(String) onOptionSelected;
  static const options = [
    (LucideIcons.barChart3, 'Tableau de bord'),
    (LucideIcons.users, 'Clients'),
    (LucideIcons.fileText, 'Devis'),
    (LucideIcons.trendingUp, 'Statistiques'),
    null,
    (LucideIcons.settings, 'Paramètres'),
    (LucideIcons.helpCircle, 'Aide'),
  ];

  const CustomDrawer({Key? key, required this.onOptionSelected})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paddingV = Sizes.sapcing8;
    final paddingH = Sizes.sapcing4;
    return Drawer(
      width: 340,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
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
                    top: max(paddingV, MediaQuery.of(context).padding.top),
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
                            child: Image.network(
                              'https://app.jbmanager.com/themes/default/images/rlogo.png',
                              width: 36,
                              height: 36,
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
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                vertical: Sizes.sapcing6,
                horizontal: Sizes.sapcing4,
              ),
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = index == 0;

                if (option == null) {
                  return Divider(
                    color: Colors.grey.shade300,
                    thickness: 1,
                    height: Sizes.sapcing4 * 2,
                  );
                }
                return Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        onTap: () => onOptionSelected(option.$2),
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
                                        Theme.of(context).colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        Colors.white,
                                        0.9,
                                      )!,
                                      Color.lerp(
                                        Theme.of(context).colorScheme.secondary,
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
                                      ).withOpacity(0.15),
                                      offset: const Offset(0, 4),
                                      blurRadius: 12,
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                option.$1,
                                color: !isSelected
                                    ? Colors.grey.shade700
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 10),
                              Text(
                                option.$2,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: !isSelected
                                      ? Colors.grey.shade700
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
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
            ),
          ),
          Container(
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
              onTap: () => onOptionSelected('Déconnexion'),
            ),
          ),
        ],
      ),
    );
  }
}

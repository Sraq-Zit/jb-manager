import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jbmanager/models/document.dart';
import 'package:jbmanager/providers/document_provider.dart';
import 'package:jbmanager/screens/detail_screen.dart';
import 'package:jbmanager/theme/color_palette.dart';
import 'package:jbmanager/theme/sizes.dart';
import 'package:jbmanager/widgets/loader.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class DocumentsPage extends StatefulWidget {
  final DocumentCategory category;
  const DocumentsPage({super.key, required this.category});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

enum Action {
  view(LucideIcons.fileText, 'Voir le document', Colors.blue),
  download(LucideIcons.download, 'Télécharger la facture PDF'),
  edit(LucideIcons.edit, 'Modifier le statut'),
  delete(LucideIcons.trash2, 'Supprimer la facture', Colors.red);

  final IconData icon;
  final String label;
  final MaterialColor? color;

  const Action(this.icon, this.label, [this.color]);
}

class _DocumentsPageState extends State<DocumentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _filters = [
    'Tous',
    'Ce mois',
    'Payé',
    'En attente',
    'En retard',
  ];
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: DocumentOption.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          DocumentProvider(_tabController, widget.category)..getDocuments(),
      builder: (context, _) {
        final provider = Provider.of<DocumentProvider>(context);
        return Scaffold(
          body: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  textScaler: TextScaler.linear(1.2),
                  indicatorWeight: 10,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: EdgeInsets.only(top: 4.0),
                  unselectedLabelStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  indicator: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                    ),
                  ),
                  tabs: DocumentOption.values
                      .map((tab) => Tab(text: tab.label))
                      .toList(),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 6.0,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    spacing: Sizes.sapcing2,
                    children: _filters
                        .asMap()
                        .entries
                        .map(
                          (entity) => FilterChip(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            side: BorderSide(
                              width: 1.3,
                              color: _selectedFilter == entity.key
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface
                                        .withValues(alpha: 0.2),
                            ),
                            label: Text(
                              entity.value,
                              style: TextStyle(
                                color: _selectedFilter == entity.key
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                fontWeight: Sizes.weightBold,
                              ),
                            ),
                            onSelected: (isSelected) {
                              if (isSelected) {
                                setState(() {
                                  _selectedFilter = entity.key;
                                });
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              SizedBox(height: Sizes.sapcing2),
              Expanded(
                child: provider.isLoading
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 90.0),
                        child: Loader(),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.getDocuments(force: true),
                        child: ListView(
                          children: provider.documents!.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final item = entry.value;
                            return GestureDetector(
                              onTap: () => _navigateToDetail(item.idDocument),
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 6.0,
                                ),

                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: Sizes.sapcing4),
                                      CircleAvatar(
                                        backgroundColor:
                                            ColorPalette.chartColors[index %
                                                ColorPalette
                                                    .chartColors
                                                    .length],
                                        radius: 26,
                                        child: Text(
                                          item.societe[0],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: Sizes.sapcing4),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.idDocument,
                                              style: TextStyle(
                                                color: Colors.grey.shade900,
                                                fontSize: Sizes.textSm,
                                                fontWeight: Sizes.weightBold,
                                              ),
                                            ),
                                            SizedBox(height: 2.0),
                                            Text(
                                              item.societe,
                                              style: TextStyle(
                                                color: Colors.grey.shade800,
                                                fontSize: Sizes.textSm,
                                              ),
                                            ),
                                            SizedBox(height: 4.0),
                                            Text(
                                              DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(item.dateDocument),
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: Sizes.textXs,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              RichText(
                                                text: TextSpan(
                                                  text: item.montantHtFormatted,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade900,
                                                    fontSize: Sizes.textLg,
                                                    fontWeight:
                                                        Sizes.weightBold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 6.0),
                                              Chip(
                                                label: Text(
                                                  item.documentStatus.name,
                                                ),
                                                backgroundColor: item
                                                    .documentStatus
                                                    .color
                                                    .withValues(alpha: 0.15),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                labelStyle: TextStyle(
                                                  color:
                                                      item.documentStatus.color,
                                                  fontSize: Sizes.textXs,
                                                  fontWeight: Sizes.weightBold,
                                                ),
                                                labelPadding: EdgeInsets.zero,
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  20,
                                                                ),
                                                          ),
                                                    ),
                                                    builder: (modalContext) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              20.0,
                                                            ),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          spacing:
                                                              Sizes.sapcing3,
                                                          children: [
                                                            Container(
                                                              width: 40,
                                                              height: 5,
                                                              margin:
                                                                  EdgeInsets.only(
                                                                    bottom: 20,
                                                                  ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                    color: Colors
                                                                        .grey,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          10,
                                                                        ),
                                                                  ),
                                                            ),
                                                            ...Action.values.map(
                                                              (
                                                                action,
                                                              ) => ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  elevation: 0,
                                                                  textStyle: TextStyle(
                                                                    fontSize: Sizes
                                                                        .textMd,
                                                                  ),
                                                                  backgroundColor:
                                                                      (action.color ??
                                                                              Colors.grey)
                                                                          .shade100
                                                                          .withValues(
                                                                            alpha:
                                                                                0.5,
                                                                          ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          15,
                                                                        ),
                                                                  ),
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                    modalContext,
                                                                  );
                                                                  _doAction(
                                                                    action,
                                                                    item.idDocument,
                                                                  );
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            18.0,
                                                                      ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        action
                                                                            .icon,
                                                                        color:
                                                                            (action.color ??
                                                                                    Colors.grey)
                                                                                .shade800,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                        action
                                                                            .label,
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              Sizes.textMd,
                                                                          color:
                                                                              (action.color ??
                                                                                      Colors.grey)
                                                                                  .shade800,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: MediaQuery.of(
                                                                modalContext,
                                                              ).padding.bottom,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.more_vert,
                                                  color: Colors.grey,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _doAction(Action action, String documentId) {
    // Implement action handling logic here
    if (action == Action.view) return _navigateToDetail(documentId);
  }

  void _navigateToDetail(String documentId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DetailScreen(documentId: documentId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart' hide Action;
import 'package:intl/intl.dart';
import 'package:jbmanager/constants/document_states.dart';
import 'package:jbmanager/constants/document_types.dart';
import 'package:jbmanager/models/document.dart';
import 'package:jbmanager/providers/document_provider.dart';
import 'package:jbmanager/providers/ui_provider.dart';
import 'package:jbmanager/screens/detail.dart';
import 'package:jbmanager/services/api_service.dart';
import 'package:jbmanager/theme/color_palette.dart';
import 'package:jbmanager/theme/sizes.dart';
import 'package:jbmanager/widgets/loader.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

class DocumentsPage extends StatefulWidget {
  final DocumentCategory category;
  const DocumentsPage({super.key, required this.category});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DocumentProvider _provider;

  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  List<int> _selectedFilter = [];

  List<DocumentOption> _docOptions = [];

  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _docOptions = documentTypes.keys
        .where((key) => key.$1 == widget.category)
        .map((key) => key.$2)
        .toList();
    _tabController = TabController(length: _docOptions.length, vsync: this);
    _selectedFilter = List<int>.filled(_docOptions.length, -1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uiProvider = Provider.of<UiProvider>(context, listen: false);
      uiProvider.searchNotifier.addListener(() {
        _provider.getDocuments(
          query: uiProvider.searchNotifier.value,
          status: _selectedFilter[_tabController.index],
          force: true,
          reset: true,
        );
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DocumentProvider(_tabController, widget.category)
        ..getDocuments(status: _selectedFilter[_tabController.index])
        ..addScrollListener(
          (provider) => provider.getDocuments(
            status: _selectedFilter[_tabController.index],
            scroll: true,
          ),
        ),
      builder: (context, _) {
        _provider = Provider.of<DocumentProvider>(context);
        final uiProvider = Provider.of<UiProvider>(context);
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
                  tabs: _docOptions.map((tab) => Tab(text: tab.label)).toList(),
                ),
              ),
              Container(
                width: double.infinity,
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
                    children:
                        (documentStates.values
                                .where(
                                  (s) =>
                                      s.documentTypeId ==
                                      _provider.documentType.id,
                                )
                                .map((s) => MapEntry(s.id, s.name))
                                .toList()
                                .asMap()
                                .entries
                                .toList()
                                .where((entry) => entry.key < 5)
                                .map((e) => e.value)
                                .toList()
                              ..insertAll(0, [MapEntry(-1, "Tous")]))
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
                                  color:
                                      _selectedFilter[_tabController.index] ==
                                          entity.key
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface
                                            .withValues(alpha: 0.2),
                                ),
                                label: Text(
                                  entity.value,
                                  style: TextStyle(
                                    color:
                                        _selectedFilter[_tabController.index] ==
                                            entity.key
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.5),
                                    fontWeight: Sizes.weightBold,
                                  ),
                                ),
                                onSelected: (isSelected) {
                                  if (isSelected) {
                                    setState(() {
                                      _selectedFilter[_tabController.index] =
                                          entity.key;
                                    });
                                    _refreshKey.currentState?.show();
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
                child: _provider.isLoading
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 90.0),
                        child: Loader(),
                      )
                    : RefreshIndicator(
                        key: _refreshKey,
                        onRefresh: () => _provider.getDocuments(
                          query: uiProvider.searchNotifier.value,
                          status: _selectedFilter[_tabController.index],
                          force: true,
                        ),
                        child: _provider.documents!.isEmpty
                            ? Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  'Aucun document trouvé.',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: Sizes.textMd,
                                  ),
                                ),
                              )
                            : ListView(
                                controller: _provider.scrollController,
                                children:
                                    _provider.documents!.asMap().entries.map<Widget>((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final item = entry.value;
                                      return GestureDetector(
                                        onTap: () =>
                                            DocumentProvider.navigateToDocumentDetail(
                                              context,
                                              () => _provider.getDocuments(
                                                query: uiProvider
                                                    .searchNotifier
                                                    .value,
                                                status:
                                                    _selectedFilter[_tabController
                                                        .index],
                                                reset: true,
                                                force: true,
                                              ),
                                              item,
                                              ColorPalette.chartColors[index %
                                                  ColorPalette
                                                      .chartColors
                                                      .length],
                                            ),

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
                                                  backgroundColor: item.color,
                                                  radius: 26,
                                                  child: Text(
                                                    item.societe[0],
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: Sizes.sapcing4),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.idDocument,
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey
                                                              .shade900,
                                                          fontSize:
                                                              Sizes.textSm,
                                                          fontWeight:
                                                              Sizes.weightBold,
                                                        ),
                                                      ),
                                                      SizedBox(height: 2.0),
                                                      Text(
                                                        item.societe,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey
                                                              .shade800,
                                                          fontSize:
                                                              Sizes.textSm,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4.0),
                                                      Text(
                                                        DateFormat(
                                                          'dd/MM/yyyy',
                                                        ).format(
                                                          item.dateDocument,
                                                        ),
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey
                                                              .shade600,
                                                          fontSize:
                                                              Sizes.textXs,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: Sizes.sapcing4),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        RichText(
                                                          text: TextSpan(
                                                            text: item
                                                                .montantHtFormatted,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey
                                                                  .shade900,
                                                              fontSize:
                                                                  Sizes.textLg,
                                                              fontWeight: Sizes
                                                                  .weightBold,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 6.0),
                                                        Chip(
                                                          label: Text(
                                                            item
                                                                .documentStatus
                                                                .name,
                                                          ),
                                                          backgroundColor: item
                                                              .documentStatus
                                                              .color
                                                              .withValues(
                                                                alpha: 0.15,
                                                              ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20,
                                                                ),
                                                          ),
                                                          labelStyle: TextStyle(
                                                            color: item
                                                                .documentStatus
                                                                .color,
                                                            fontSize:
                                                                Sizes.textXs,
                                                            fontWeight: Sizes
                                                                .weightBold,
                                                          ),
                                                          labelPadding:
                                                              EdgeInsets.zero,
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
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
                                                                return StatefulBuilder(
                                                                  builder:
                                                                      (
                                                                        stateModalContext,
                                                                        setModalState,
                                                                      ) {
                                                                        return Padding(
                                                                          padding: const EdgeInsets.all(
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
                                                                                margin: EdgeInsets.only(
                                                                                  bottom: 20,
                                                                                ),
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.grey,
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    10,
                                                                                  ),
                                                                                ),
                                                                              ),

                                                                              if (_isActionLoading)
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(
                                                                                    vertical: 10.0,
                                                                                  ),
                                                                                  child: Center(
                                                                                    child: CircularProgressIndicator(),
                                                                                  ),
                                                                                ),

                                                                              if (!_isActionLoading)
                                                                                ...item.actions.map(
                                                                                  (
                                                                                    action,
                                                                                  ) => ElevatedButton(
                                                                                    style: ElevatedButton.styleFrom(
                                                                                      shadowColor: Colors.transparent,
                                                                                      elevation: 0,
                                                                                      textStyle: TextStyle(
                                                                                        fontSize: Sizes.textMd,
                                                                                      ),
                                                                                      backgroundColor:
                                                                                          (action.color ??
                                                                                                  Colors.grey)
                                                                                              .shade100
                                                                                              .withValues(
                                                                                                alpha: 0.5,
                                                                                              ),
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(
                                                                                          15,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    onPressed: () async {
                                                                                      final docId = await DocumentProvider.doAction(
                                                                                        context,
                                                                                        action,
                                                                                        item.id,
                                                                                        (
                                                                                          isLoading,
                                                                                        ) => setModalState(
                                                                                          () => _isActionLoading = isLoading,
                                                                                        ),
                                                                                      );
                                                                                      _isActionLoading = false;
                                                                                      if (context.mounted) {
                                                                                        Navigator.popUntil(
                                                                                          context,
                                                                                          (
                                                                                            route,
                                                                                          ) => route.isFirst,
                                                                                        );
                                                                                        if (modalContext.mounted) {
                                                                                          setModalState(
                                                                                            () {},
                                                                                          );
                                                                                        }
                                                                                        if (docId !=
                                                                                            null) {
                                                                                          DocumentProvider.navigateToDocumentDetail(
                                                                                            context,
                                                                                            () => _provider.getDocuments(
                                                                                              query: uiProvider.searchNotifier.value,
                                                                                              status: _selectedFilter[_tabController.index],
                                                                                              reset: true,
                                                                                              force: true,
                                                                                            ),
                                                                                            DocumentItem(
                                                                                              id: docId,
                                                                                              idDocument: '',
                                                                                              idContact: '',
                                                                                              societe: '',
                                                                                              dateDocument: '',
                                                                                              montantHt: '-1',
                                                                                              montantTtc: '-1',
                                                                                              solde: '',
                                                                                              documentStatus: '0',
                                                                                              actions: [],
                                                                                            ),
                                                                                            Colors.blue,
                                                                                          );
                                                                                        }

                                                                                        _provider.getDocuments(
                                                                                          query: uiProvider.searchNotifier.value,
                                                                                          status: _selectedFilter[_tabController.index],
                                                                                          force: true,
                                                                                          reset: true,
                                                                                        );
                                                                                      }
                                                                                    },
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.symmetric(
                                                                                        vertical: 18.0,
                                                                                      ),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Icon(
                                                                                            action.icon,
                                                                                            color:
                                                                                                (action.color ??
                                                                                                        Colors.grey)
                                                                                                    .shade800,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: 8,
                                                                                          ),
                                                                                          Text(
                                                                                            action.text,
                                                                                            style: TextStyle(
                                                                                              fontSize: Sizes.textMd,
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
                                    }).toList()..add(
                                      _provider.isFetchingScroll
                                          ? SizedBox(
                                              height: 80,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            )
                                          : SizedBox(),
                                    ),
                              ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

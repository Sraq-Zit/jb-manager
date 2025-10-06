import 'package:flutter/material.dart' hide Action;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jbmanager/exceptions/http_exception.dart';
import 'package:jbmanager/models/document.dart';
import 'package:jbmanager/providers/document_provider.dart';
import 'package:jbmanager/providers/ui_provider.dart';
import 'package:jbmanager/screens/home.dart';
import 'package:jbmanager/theme/color_palette.dart';
import 'package:jbmanager/theme/sizes.dart';
import 'package:jbmanager/widgets/appbar.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class InvoiceItemCard extends StatelessWidget {
  final String type;
  final String code;
  final String title;
  final String unitPrice;
  final String quantity;
  final String unit;
  final String total;
  final String tva;
  final String tvaRate;

  const InvoiceItemCard({
    super.key,
    required this.type,
    required this.code,
    required this.title,
    required this.unitPrice,
    required this.quantity,
    required this.unit,
    required this.total,
    required this.tva,
    required this.tvaRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          // Title + Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      children: [
                        if (code.isNotEmpty || type == "commentaire")
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.blue.shade800.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            child: Text(
                              code.isNotEmpty ? code : "Commentaire",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: Sizes.weightBold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                        if (type != "commentaire" && tvaRate.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey.shade100,
                            ),
                            child: Text(
                              "TVA $tvaRate%",
                              style: TextStyle(
                                fontSize: Sizes.textXs,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    FractionallySizedBox(
                      widthFactor: type != "commentaire" ? 0.9 : 1,
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: Sizes.textSm,
                          fontWeight: Sizes.weightBold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Right (Price)
              if (type != "commentaire")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      total,
                      style: const TextStyle(
                        fontSize: Sizes.textSm,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "DH",
                      style: TextStyle(
                        fontSize: Sizes.textXs,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (type != "commentaire")
            Divider(color: Colors.black12.withValues(alpha: 0.05)),
          if (type != "commentaire")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      unitPrice,
                      style: TextStyle(
                        fontSize: Sizes.textSm,
                        color: Colors.grey.shade800,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text("×"),
                    const SizedBox(width: 16),
                    Text(
                      "$quantity$unit",
                      style: const TextStyle(
                        fontSize: Sizes.textSm,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
                Text(
                  "TVA: $tva",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final DocumentItem documentItem;
  final Function onDocumentUpdated;
  final MaterialColor color;

  const DetailScreen({
    super.key,
    required this.documentItem,
    required this.onDocumentUpdated,
    required this.color,
  });
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isDetailed = false;
  bool _isActionLoading = false;
  DocumentDetails? document;
  late DocumentItem documentItem;
  late JBAppBar _jbAppBar;

  void _fetchDocumentDetails() async {
    DocumentProvider.getDocumentDetail(documentItem.id).then((doc) {
      setState(() {
        document = doc;
      });
    });
    // .catchError((error) {
    //   if ((error is! HttpException)) {
    //     print(error);
    //   }
    //   error = error is HttpException
    //       ? error.message
    //       : 'Une erreur est survenue, merci de réessayer.';
    //
    //   if (mounted) Fluttertoast.showToast(msg: error);
    //   if (mounted) Navigator.of(context).pop();
    //   return null;
    // });
  }

  @override
  void initState() {
    super.initState();
    documentItem = widget.documentItem;
    _fetchDocumentDetails();
    _jbAppBar = JBAppBar(
      notificationAction: false,
      onSearch: (query) => setState(() {
        document?.itemsFilter = query;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    String tvaRate = document != null && document!.tvaRateId.isNotEmpty
        ? DocumentProvider.getTvaRate(context, document!.tvaRateId)
        : "";
    if (tvaRate.isNotEmpty) tvaRate = "($tvaRate%)";
    _jbAppBar.actions = [
      IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: document == null
            ? null
            : () => showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (modalContext) {
                  return StatefulBuilder(
                    builder: (modalContext, setModalState) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: Sizes.sapcing3,
                          children: [
                            Container(
                              width: 40,
                              height: 5,
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10),
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

                            if (!_isActionLoading && document != null)
                              ...document!.actions.map(
                                (action) => ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    textStyle: TextStyle(
                                      fontSize: Sizes.textMd,
                                    ),
                                    backgroundColor:
                                        (action.color ?? Colors.grey).shade100
                                            .withValues(alpha: 0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final docId =
                                        await DocumentProvider.doAction(
                                          context,
                                          action,
                                          document!.id,
                                          (isLoading) => setModalState(
                                            () => _isActionLoading = isLoading,
                                          ),
                                        );
                                    _isActionLoading = false;
                                    if (modalContext.mounted) {
                                      setModalState(() {});
                                      Navigator.pop(modalContext);
                                    }
                                    widget.onDocumentUpdated();
                                    if (docId != null) {
                                      setState(() {
                                        document = null;
                                      });
                                      documentItem = DocumentItem(
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
                                      );
                                      _fetchDocumentDetails();
                                    } else {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          action.icon,
                                          color: (action.color ?? Colors.grey)
                                              .shade800,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          action.text,
                                          style: TextStyle(
                                            fontSize: Sizes.textMd,
                                            color: (action.color ?? Colors.grey)
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
              ),
      ),
    ];

    return Scaffold(
      appBar: _jbAppBar.build(context),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Row: Icon + Title + Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.blue, Colors.blueAccent],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 3),
                              ],
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Facture",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              Skeletonizer(
                                enabled:
                                    document == null &&
                                    documentItem.idDocument.isEmpty,
                                child: Text(
                                  document?.idDocument ??
                                      (documentItem.idDocument.isEmpty
                                          ? '.' * 20
                                          : documentItem.idDocument),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Skeletonizer(
                        enabled:
                            document?.documentStatus == null &&
                            documentItem.documentStatus.name.isEmpty,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (document?.documentStatus ??
                                        documentItem.documentStatus)
                                    .color
                                    .shade50,
                            borderRadius: BorderRadius.circular(50),

                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 1,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: RichText(
                            text: TextSpan(
                              text:
                                  document?.documentStatus.name ??
                                  (documentItem.documentStatus.name.isEmpty
                                      ? 'status_name'
                                      : documentItem.documentStatus.name),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: Sizes.weightBold,
                                color:
                                    (document?.documentStatus ??
                                            documentItem.documentStatus)
                                        .color
                                        .shade800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Client Info + Dates
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Skeletonizer(
                                enabled:
                                    document == null &&
                                    documentItem.societe.isEmpty,
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  child: Text(
                                    document?.contact ??
                                        (documentItem.societe.isEmpty
                                            ? '.' * 40
                                            : documentItem.societe),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      backgroundColor: Colors.transparent,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                document?.validity == null
                                    ? '.' * 20
                                    : DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(document!.validity),
                                style: TextStyle(
                                  fontSize: Sizes.textXs,
                                  color: document?.validity == null
                                      ? Colors.grey.shade200
                                      : Colors.grey.shade800,
                                  backgroundColor: document?.validity == null
                                      ? Colors.grey.shade200
                                      : Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Échéance",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: document?.dateDocument == null
                                  ? DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(documentItem.dateDocument)
                                  : DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(document!.dateDocument),
                              style: TextStyle(
                                fontSize: Sizes.textSm,
                                fontWeight: Sizes.weightBold,
                                color: Colors.black,
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Details button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: document == null
                          ? null
                          : () => setState(() {
                              _isDetailed = !_isDetailed;
                            }),
                      style: OutlinedButton.styleFrom(
                        iconAlignment: IconAlignment.end,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      label: Text(
                        _isDetailed ? "Masquer" : "Plus de détails",
                        style: TextStyle(
                          fontSize: 14,
                          color: document == null
                              ? Colors.grey.shade400
                              : Colors.grey.shade800,
                        ),
                      ),
                      icon: Icon(
                        _isDetailed
                            ? LucideIcons.chevronUp
                            : LucideIcons.chevronDown,
                        size: Sizes.textXl,
                        color: document == null
                            ? Colors.grey.shade400
                            : Colors.grey.shade800,
                      ),
                    ),
                  ),
                  if (_isDetailed)
                    _buildDetails(
                      DateFormat('dd/MM/yyyy').format(document!.validity),
                      DateFormat('dd/MM/yyyy').format(document!.dateDocument),
                      document!.contact,
                      document!.phone,
                      document!.adresse,
                      document!.email,
                    ),
                ],
              ),
            ),

            // ===== LIST ITEMS =====
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                physics: document == null
                    ? const NeverScrollableScrollPhysics()
                    : null,
                children:
                    document?.items
                        .map(
                          (item) => Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: InvoiceItemCard(
                              type: item.type,
                              code: item.reference,
                              title: item.description,
                              unitPrice: item.puFormatted,
                              quantity: item.quantity.round().toString(),
                              unit: DocumentProvider.getUnit(
                                context,
                                item.idUnit,
                              ),
                              total: item.totalHtFormatted,
                              tva: item.totalTvaFormatted,
                              tvaRate: DocumentProvider.getTvaRate(
                                context,
                                item.idTva,
                              ),
                            ),
                          ),
                        )
                        .toList() ??
                    List.generate(
                      10,
                      (index) => Skeletonizer(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: InvoiceItemCard(
                            type: 'type',
                            code: 'NNNNNN',
                            title:
                                'lipsum dolor sit amet, consectetur adipiscing',
                            unitPrice: '00000000',
                            quantity: '00',
                            unit: 'P',
                            total: '00000000',
                            tva: '000000',
                            tvaRate: '00',
                          ),
                        ),
                      ),
                    ),
              ),
            ),

            // ===== FIXED FOOTER =====
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Sous-total HT",
                        style: TextStyle(
                          fontSize: Sizes.textSm,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Skeletonizer(
                        enabled:
                            document == null &&
                            documentItem.montantHtFormatted.isEmpty,
                        child: Text(
                          document?.montantHtFormatted ??
                              (documentItem.montantHtFormatted.isEmpty
                                  ? '0000000000 DH'
                                  : documentItem.montantHtFormatted),
                          style: TextStyle(
                            fontSize: Sizes.textSm,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "TVA $tvaRate",
                        style: TextStyle(
                          fontSize: Sizes.textSm,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Skeletonizer(
                        enabled:
                            document == null &&
                            documentItem.calculatedTvaFormatted.isEmpty,
                        child: Text(
                          document?.montantTvaFormatted ??
                              (documentItem.calculatedTvaFormatted.isEmpty
                                  ? '00000000 DH'
                                  : documentItem.calculatedTvaFormatted),
                          style: TextStyle(
                            fontSize: Sizes.textSm,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: Colors.black12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total TTC",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Skeletonizer(
                        enabled:
                            document == null &&
                            documentItem.montantTtcFormatted.isEmpty,
                        child: Text(
                          document?.montantTtcFormatted ??
                              (documentItem.montantTtcFormatted.isEmpty
                                  ? '0000000000 DH'
                                  : documentItem.montantTtcFormatted),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
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

  Widget _buildDetails(
    String issuedDate,
    String dueDate,
    String contactName,
    String phone,
    String address,
    String email,
  ) {
    final info1 = [
      (LucideIcons.calendar, "ÉMISSION", issuedDate, Colors.blue),
      (LucideIcons.calendar, "ÉCHÉANCE", dueDate, Colors.deepOrange),
      (LucideIcons.user, "CONTACT", contactName, Colors.green),
      (LucideIcons.phone, "TÉLÉPHONE", phone, Colors.purple),
    ];
    final info2 = [
      (LucideIcons.mapPin, "ADRESSE", address, Colors.grey),
      (LucideIcons.mail, "EMAIL", email, Colors.indigo),
    ];

    infoBloc(IconData icon, String label, String value, MaterialColor color) =>
        value.isEmpty
        ? Container()
        : Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.shade100.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: Sizes.weightBold,
                        color: color.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Column(
              spacing: 8,
              children: [
                for (int i = 0; i < info1.length; i += 2)
                  IntrinsicHeight(
                    child: Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: infoBloc(
                            info1[i].$1,
                            info1[i].$2,
                            info1[i].$3,
                            info1[i].$4,
                          ),
                        ),
                        if (i + 1 < info1.length)
                          Expanded(
                            child: infoBloc(
                              info1[i + 1].$1,
                              info1[i + 1].$2,
                              info1[i + 1].$3,
                              info1[i + 1].$4,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              spacing: 8,
              children: [
                for (int i = 0; i < info2.length; i++)
                  infoBloc(info2[i].$1, info2[i].$2, info2[i].$3, info2[i].$4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

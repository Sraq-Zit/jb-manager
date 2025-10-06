import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jbmanager/constants/document_states.dart';
import 'package:jbmanager/constants/document_types.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum DocumentCategory { sales, purchases, activities }

enum DocumentOption {
  invoice('Devis'),
  order('Cmds'),
  delivery('Livraison'),
  receipt('Réceptions'),
  quote('Factures'),

  info('Info'),
  action('Action'),
  rdv('RDV');

  final String label;
  const DocumentOption(this.label);
}

class DocumentStatus {
  final int id;
  final int documentTypeId;
  final String name;
  final MaterialColor color;

  const DocumentStatus(this.id, this.documentTypeId, this.name, this.color);

  static DocumentStatus fromId(int id) {
    return documentStates[id]!;
  }
}

class DocumentType {
  final int id;
  final DocumentCategory category;
  final DocumentOption option;

  const DocumentType(this.id, this.category, this.option);

  static DocumentType get(DocumentCategory category, DocumentOption option) {
    return documentTypes[(category, option)]!;
  }
}

class Action {
  final String text;
  final String url;
  final String action;
  final bool alert;
  final bool download;

  String urlFormatted(String id) => url.replaceAll('{ID}', id);

  MaterialColor? get color {
    if (alert) return Colors.red;

    return null;
  }

  IconData get icon {
    switch (action) {
      case 'duplicate':
        return LucideIcons.copy;
      case 'print':
        return LucideIcons.printer;
      case 'delete':
        return LucideIcons.trash2;
      default:
        return LucideIcons.activity;
    }
  }

  const Action({
    required this.text,
    required this.url,
    required this.action,
    required this.alert,
    required this.download,
  });

  factory Action.fromJson(Map<String, dynamic> json) {
    return Action(
      text: json['text'],
      url: json['url'],
      action: json['action'],
      alert: json['alert'] ?? false,
      download: json['download'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {'text': text, 'url': url, 'action': action};
}

class DocumentItem {
  final String id;
  final String idDocument;
  final String idContact;
  final String societe;
  final double montantHt;
  final double montantTtc;
  final double solde;
  final DateTime dateDocument;
  final DocumentStatus documentStatus;
  final List<Action> actions;

  Color color = Colors.grey;

  String get montantHtFormatted => montantHt < 0
      ? ''
      : "${NumberFormat('#,###', 'fr_FR').format(montantHt.round())} DH";
  String get montantTtcFormatted => montantTtc < 0
      ? ''
      : "${NumberFormat('#,###', 'fr_FR').format(montantTtc.round())} DH";
  String get soldeFormatted => solde < 0
      ? ''
      : "${NumberFormat('#,###', 'fr_FR').format(solde.round())} DH";

  String get calculatedTvaFormatted {
    if (montantHt <= 0 || montantTtc <= 0) return '';
    final tva = montantTtc - montantHt;
    return "${NumberFormat('#,###', 'fr_FR').format(tva.round())} DH";
  }

  DocumentItem({
    required this.id,
    required this.idDocument,
    required this.idContact,
    required this.societe,
    required String montantHt,
    required String montantTtc,
    required String solde,
    required String dateDocument,
    required String documentStatus,
    List<Action>? actions,
  }) : montantHt = double.tryParse(montantHt) ?? 0.0,
       actions = actions ?? [],
       montantTtc = double.tryParse(montantTtc) ?? 0.0,
       solde = double.tryParse(solde) ?? 0.0,
       dateDocument = DateTime.fromMillisecondsSinceEpoch(
         (int.tryParse(dateDocument) ??
                 (DateTime.now().millisecondsSinceEpoch ~/ 1000)) *
             1000,
       ),
       documentStatus = DocumentStatus.fromId(
         int.tryParse(documentStatus) ?? 0,
       );
  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'],
      idDocument: json['id_document'],
      idContact: json['id_contact'],
      societe: json['societe'],
      montantHt: json['montant_ht'],
      montantTtc: json['montant_ttc'],
      solde: json['solde'],
      dateDocument: json['date_document'],
      documentStatus: json['document_status'],
      actions:
          (json['actions'] as List<dynamic>?)
              ?.map((e) => Action.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_document': idDocument,
      'id_contact': idContact,
      'societe': societe,
      'montant_ht': montantHt,
      'montant_ttc': montantTtc,
      'solde': solde,
      'date_document': dateDocument,
      'document_status': documentStatus,
      'actions': actions,
    };
  }
}

class DocumentDetails {
  final String id;
  final String idDocument;
  final DocumentStatus documentStatus;
  final String idType;
  final DateTime dateDocument;
  final String idContact;
  final String idDevise;
  final String refExt;
  final String subject;
  final String idCommercial;
  final double montantHt;
  final double montantTtc;
  final double montantTva;
  final double solde;
  final DateTime validity;
  final String iText1;
  final String iText2;
  final String iText3;
  final String iText4;
  final String iText5;
  final String contact;
  final String adresse;
  final String adresse2;
  final String phone;
  final String zip;
  final String city;
  final String country;
  final String ice;
  final String email;
  final List<DocumentDetailCard> _items;
  final List<Action> actions;

  String itemsFilter = '';

  List<DocumentDetailCard> get items {
    if (itemsFilter.isEmpty) {
      return _items;
    }
    return _items
        .where(
          (item) =>
              item.description.toLowerCase().contains(
                itemsFilter.toLowerCase(),
              ) ||
              item.reference.toLowerCase().contains(itemsFilter.toLowerCase()),
        )
        .toList();
  }

  String get tvaRateId {
    String? rate;
    for (var item in items) {
      if (rate == null) {
        rate = item.idTva;
      } else if (rate != item.idTva) {
        return ""; // Multiple rates
      }
    }
    return rate ?? "";
  }

  String get montantHtFormatted =>
      "${NumberFormat('#,###', 'fr_FR').format(montantHt.round())} DH";
  String get montantTtcFormatted =>
      "${NumberFormat('#,###', 'fr_FR').format(montantTtc.round())} DH";
  String get montantTvaFormatted =>
      "${NumberFormat('#,###', 'fr_FR').format(montantTva.round())} DH";
  String get soldeFormatted =>
      "${NumberFormat('#,###', 'fr_FR').format(solde.round())} DH";

  DocumentDetails({
    required this.id,
    required this.idDocument,
    required this.documentStatus,
    required this.idType,
    required this.dateDocument,
    required this.idContact,
    required this.idDevise,
    required this.refExt,
    required this.subject,
    required this.idCommercial,
    required this.montantHt,
    required this.montantTtc,
    required this.montantTva,
    required this.solde,
    required this.validity,
    required this.iText1,
    required this.iText2,
    required this.iText3,
    required this.iText4,
    required this.iText5,
    required this.contact,
    required this.adresse,
    required this.adresse2,
    required this.phone,
    required this.zip,
    required this.city,
    required this.country,
    required this.ice,
    required this.email,
    items,
    required this.actions,
  }) : _items = items ?? [];

  factory DocumentDetails.fromJson(Map<String, dynamic> json) {
    return DocumentDetails(
      id: json['id'],
      idDocument: json['id_document'],
      documentStatus: DocumentStatus.fromId(
        int.tryParse(json['document_status']) ?? 0,
      ),
      idType: json['id_type'],
      dateDocument: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['date_document']) * 1000,
      ),
      idContact: json['id_contact'],
      idDevise: json['id_devise'],
      refExt: json['ref_ext'],
      subject: json['subject'],
      idCommercial: json['id_commercial'],
      montantHt: double.parse(json['montant_ht']),
      montantTtc: double.parse(json['montant_ttc']),
      montantTva: double.parse(json['montant_tva']),
      solde: double.parse(json['solde']),
      validity: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['validity']) * 1000,
      ),
      iText1: json['i_text1'],
      iText2: json['i_text2'],
      iText3: json['i_text3'],
      iText4: json['i_text4'],
      iText5: json['i_text5'],
      contact: json['contact'],
      adresse: json['adresse'],
      adresse2: json['adresse2'],
      phone: json['phone'],
      zip: json['zip'],
      city: json['city'],
      country: json['country'],
      ice: json['ice'],
      email: json['email'],
      items: (json['items'] as List<dynamic>)
          .map((e) => DocumentDetailCard.fromJson(e))
          .toList(),
      actions: (json['actions'] as List<dynamic>)
          .map((e) => Action.fromJson(e))
          .toList(),
    );
  }
}

class DocumentDetailCard {
  final String validateDocument;
  final String idItem;
  final String idProduct;
  final String reference;
  final String description;
  final double quantity;
  final double pu;
  final double puTtc;
  final String idUnit;
  final double discount;
  final String type;
  final String idTva;
  final double totalHt;
  final double totalTtc;
  final double totalTva;
  final double prev;

  String get puFormatted =>
      "${NumberFormat('#,###', 'fr_FR').format(pu.round())} DH";
  String get puTtcFormatted =>
      "${NumberFormat('#,###', 'fr_FR').format(puTtc.round())} DH";
  String get totalHtFormatted =>
      NumberFormat('#,###', 'fr_FR').format(totalHt.round());
  String get totalTtcFormatted =>
      "${NumberFormat('#,###', 'fr_FR').format(totalTtc.round())} DH";
  String get totalTvaFormatted =>
      "${NumberFormat('#,###', 'fr_FR').format(totalTva.round())} DH";

  DocumentDetailCard({
    required this.validateDocument,
    required this.idItem,
    required this.idProduct,
    required this.reference,
    required this.description,
    required this.quantity,
    required this.pu,
    required this.puTtc,
    required this.idUnit,
    required this.discount,
    required this.type,
    required this.idTva,
    required this.totalHt,
    required this.totalTtc,
    required this.totalTva,
    required this.prev,
  });

  factory DocumentDetailCard.fromJson(Map<String, dynamic> json) {
    for (var field in [
      'quantity',
      'pu',
      'pu_ttc',
      'discount',
      'total_ht',
      'total_ttc',
      'total_tva',
      'prev',
    ]) {
      if (json[field] == null || json[field].toString().isEmpty) {
        json[field] = '0';
      }
    }
    return DocumentDetailCard(
      validateDocument: json['validate_document'],
      idItem: json['id_item'],
      idProduct: json['id_product'],
      reference: json['reference'],
      description: json['description'],
      quantity: double.parse(json['quantity']),
      pu: double.parse(json['pu']),
      puTtc: double.parse(json['pu_ttc']),
      idUnit: json['id_unit'],
      discount: double.parse(json['discount']),
      type: json['type'],
      idTva: json['id_tva'],
      totalHt: double.parse(json['total_ht']),
      totalTtc: double.parse(json['total_ttc']),
      totalTva: double.parse(json['total_tva']),
      prev: double.parse(json['prev']),
    );
  }
}

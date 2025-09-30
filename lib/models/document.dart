import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jbmanager/constants/document_states.dart';
import 'package:jbmanager/constants/document_types.dart';

enum DocumentCategory { sales, purchases }

enum DocumentOption {
  invoice('Devis'),
  order('Cmds'),
  delivery('Livraison'),
  quote('Factures');

  final String label;
  const DocumentOption(this.label);
}

class DocumentStatus {
  final int id;
  final int documentTypeId;
  final String name;
  final Color color;

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

class Document {
  final String id;
  final String idDocument;
  final String idContact;
  final String societe;
  final double montantHt;
  final double montantTtc;
  final double solde;
  final DateTime dateDocument;
  final DocumentStatus documentStatus;

  String get soldeFormatted =>
      "${NumberFormat('#,###', 'fr_FR').format(solde.round())} DH";
  String get montantHtFormatted =>
      "${NumberFormat('#,###', 'fr_FR').format(montantHt.round())} DH";

  Document({
    required this.id,
    required this.idDocument,
    required this.idContact,
    required this.societe,
    required String montantHt,
    required String montantTtc,
    required String solde,
    required String dateDocument,
    required String documentStatus,
  }) : montantHt = double.tryParse(montantHt) ?? 0.0,
       montantTtc = double.tryParse(montantTtc) ?? 0.0,
       solde = double.tryParse(solde) ?? 0.0,
       dateDocument = DateTime.fromMillisecondsSinceEpoch(
         int.parse(dateDocument) * 1000,
       ),
       documentStatus = DocumentStatus.fromId(
         int.tryParse(documentStatus) ?? 0,
       );
  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      idDocument: json['id_document'],
      idContact: json['id_contact'],
      societe: json['societe'],
      montantHt: json['montant_ht'],
      montantTtc: json['montant_ttc'],
      solde: json['solde'],
      dateDocument: json['date_document'],
      documentStatus: json['document_status'],
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
    };
  }
}

import 'package:jbmanager/models/document.dart';

typedef C = DocumentCategory;
typedef O = DocumentOption;

const documentTypes = {
  (C.sales, O.quote): DocumentType(8, C.sales, O.quote),
  (C.sales, O.order): DocumentType(6, C.sales, O.order),
  (C.sales, O.delivery): DocumentType(7, C.sales, O.delivery),
  (C.sales, O.invoice): DocumentType(5, C.sales, O.invoice),

  (C.purchases, O.quote): DocumentType(16, C.purchases, O.quote),
  (C.purchases, O.order): DocumentType(14, C.purchases, O.order),
  (C.purchases, O.receipt): DocumentType(15, C.purchases, O.receipt),
  (C.purchases, O.invoice): DocumentType(13, C.purchases, O.invoice),

  (C.activities, O.info): DocumentType(-1, C.purchases, O.invoice),
  (C.activities, O.action): DocumentType(-1, C.purchases, O.invoice),
  (C.activities, O.rdv): DocumentType(-1, C.purchases, O.invoice),
};

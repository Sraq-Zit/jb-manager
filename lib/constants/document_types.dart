import 'package:jbmanager/models/document.dart';

typedef C = DocumentCategory;
typedef O = DocumentOption;

const documentTypes = {
  (C.sales, O.quote): DocumentType(5, C.sales, O.quote),
  (C.sales, O.invoice): DocumentType(8, C.sales, O.quote),

  // TODO: this is only for testing purposes, need to change this later
  (C.sales, O.order): DocumentType(5, C.sales, O.quote),
  (C.sales, O.delivery): DocumentType(8, C.sales, O.quote),
  (C.purchases, O.quote): DocumentType(5, C.sales, O.quote),
  (C.purchases, O.invoice): DocumentType(8, C.sales, O.quote),
  (C.purchases, O.order): DocumentType(5, C.sales, O.quote),
  (C.purchases, O.delivery): DocumentType(8, C.sales, O.quote),
};

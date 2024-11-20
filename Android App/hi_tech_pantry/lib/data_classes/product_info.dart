class ProductInfo {
  ProductInfo({
    required this.eancode,
    required this.name,
    required this.finishedEditing,
    required this.quantity,
    required this.expiryDate,
    this.docId = ""
  });

  final String eancode;
  final String name;
  final bool finishedEditing;
  final int quantity;
  final DateTime? expiryDate;
  String docId = "";

  Map<String, dynamic> toFirestore() {
    return {
      'eancode': eancode,
      'name': name,
      'finishedEditing': finishedEditing,
      'quantity': quantity,
      'expiryDate': expiryDate
    };
  }

  ProductInfo.fromMap(Map<dynamic, dynamic> data)
    : eancode = data['eancode'],
      name = data['name'],
      finishedEditing = data['finishedEditing'],
      quantity = data['quantity'],
      expiryDate = data['expiryDate'] == null ? null : DateTime.fromMillisecondsSinceEpoch(data['expiryDate'].seconds * 1000);
}
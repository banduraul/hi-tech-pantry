class ProductInfo {
  ProductInfo({required this.eancode, required this.name});

  final String eancode;
  final String name;
  bool finishedEditing = false;
  bool isExpired = false;
  int quantity = 1;
  DateTime? expiryDate;

  Map<String, dynamic> toFirestore() {
    return {
      'eancode': eancode,
      'name': name,
      'finishedEditing': finishedEditing,
      'quantity': quantity,
      'expiryDate': expiryDate,
      'isExpired': isExpired
    };
  }
}
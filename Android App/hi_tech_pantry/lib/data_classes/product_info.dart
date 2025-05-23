class ProductInfo {
  ProductInfo({
    required this.eancode,
    required this.name,
    required this.categories,
    required this.finishedEditing,
    required this.quantity,
    required this.expiryDate,
    required this.imageURL,
    this.docId = "",
    required this.isExpired
  });

  final String eancode;
  final String name;
  final List<String> categories;
  final bool finishedEditing;
  String imageURL;
  final int quantity;
  final DateTime? expiryDate;
  String docId = "";
  final bool isExpired;

  Map<String, dynamic> toFirestore() {
    return {
      'eancode': eancode,
      'name': name,
      'categories': categories,
      'finishedEditing': finishedEditing,
      'quantity': quantity,
      'expiryDate': expiryDate,
      'imageURL': imageURL,
      'isExpired': isExpired
    };
  }
}
class ProductModel {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double price;
  final double originalPrice;
  final String sellerName;
  final double rating;
  final int ratingCount;
  final bool inStock;
  final List<String> cropCompatibility;
  final String dosage;
  final String specifications;
  final bool isGovtCertified;
  final String description;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.price,
    required this.originalPrice,
    required this.sellerName,
    this.rating = 4.5,
    this.ratingCount = 128,
    this.inStock = true,
    required this.cropCompatibility,
    required this.dosage,
    required this.specifications,
    this.isGovtCertified = false,
    required this.description,
  });

  int get discountPercentage {
    if (originalPrice <= price) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/product_model.dart';

final selectedProductCategoryProvider = StateProvider<String>((ref) => 'All');
final cartItemCountProvider = StateProvider<int>((ref) => 0);

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = const [
    'All',
    'Seeds',
    'Fertilizers',
    'Pesticides',
    'Machinery',
    'Equipment',
    'Tools',
    'Organic',
    'Animal Feed',
    'Govt Certified',
  ];

  final List<ProductModel> _sampleProducts = const [
    ProductModel(
      id: 'p1',
      name: 'Hybrid Bt Cotton Seeds (Rasi 659)',
      category: 'Seeds',
      imageUrl: 'https://images.unsplash.com/photo-1595855759920-86582396756a?w=500',
      price: 860.0,
      originalPrice: 950.0,
      sellerName: 'Rasi Seeds Pvt Ltd',
      rating: 4.8,
      ratingCount: 340,
      inStock: true,
      cropCompatibility: ['Cotton'],
      dosage: '2 Packets / Acre (475g packet)',
      specifications: 'Bollworm resistant, High yield potential in rainfed condition',
      isGovtCertified: true,
      description: 'Top-performing hybrid cotton seeds with high sucking-pest tolerance and dense boll load.',
    ),
    ProductModel(
      id: 'p2',
      name: 'IFFCO Nano Urea (Liquid 500ml)',
      category: 'Fertilizers',
      imageUrl: 'https://images.unsplash.com/photo-1628352081506-83c43123ed6d?w=500',
      price: 240.0,
      originalPrice: 260.0,
      sellerName: 'IFFCO Farmers Co-op',
      rating: 4.9,
      ratingCount: 1250,
      inStock: true,
      cropCompatibility: ['Paddy', 'Cotton', 'Chilli', 'Wheat', 'Maize'],
      dosage: '2-4 ml per Litre of water (Spray at tillering stage)',
      specifications: '4% Nitrogen Nanoparticles, Eco-friendly replacement for 1 bag granular urea',
      isGovtCertified: true,
      description: 'Revolutionary nanotechnology liquid nitrogen fertilizer delivering 80%+ nitrogen use efficiency.',
    ),
    ProductModel(
      id: 'p3',
      name: 'Bayer Coragen Insecticide (150ml)',
      category: 'Pesticides',
      imageUrl: 'https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?w=500',
      price: 1850.0,
      originalPrice: 2100.0,
      sellerName: 'Bayer CropScience',
      rating: 4.7,
      ratingCount: 520,
      inStock: true,
      cropCompatibility: ['Paddy', 'Sugarcane', 'Cotton', 'Chilli'],
      dosage: '60 ml per Acre in 200L water',
      specifications: 'Active Ingredient: Rynaxypyr 18.5% SC. Long duration protection (21 days)',
      isGovtCertified: true,
      description: 'Broad-spectrum anthranilic diamide insecticide providing superior control over Stem Borer and Fruit Borer.',
    ),
    ProductModel(
      id: 'p4',
      name: 'Neptune 12V 12Ah Battery Sprayer (16L)',
      category: 'Equipment',
      imageUrl: 'https://images.unsplash.com/photo-1592417817098-8f3d6ef23a85?w=500',
      price: 2890.0,
      originalPrice: 3500.0,
      sellerName: 'Neptune Agri Tools',
      rating: 4.6,
      ratingCount: 210,
      inStock: true,
      cropCompatibility: ['All Crops'],
      dosage: 'N/A',
      specifications: '16L Tank, Heavy Duty Dual Pump, Stainless Telescopic Lance with 4 Nozzles',
      isGovtCertified: false,
      description: 'Ergonomic backpack battery sprayer with adjustable pressure control dial.',
    ),
    ProductModel(
      id: 'p5',
      name: 'Trichoderma Viride Organic Bio-Fungicide (1kg)',
      category: 'Organic',
      imageUrl: 'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?w=500',
      price: 190.0,
      originalPrice: 230.0,
      sellerName: 'National Bio-Fertilizer Board',
      rating: 4.8,
      ratingCount: 180,
      inStock: true,
      cropCompatibility: ['Chilli', 'Groundnut', 'Pulses', 'Vegetables'],
      dosage: '2.5 kg / Acre mixed with FYM / Vermicompost',
      specifications: 'CFU: 2x10^6 per gram. Controls Root Rot, Wilt, and Damping Off',
      isGovtCertified: true,
      description: 'Eco-friendly bio-control fungus effectively preventing soil-borne fungal pathogens.',
    ),
    ProductModel(
      id: 'p6',
      name: 'Submersible Solar Water Pump (3 HP)',
      category: 'Machinery',
      imageUrl: 'https://images.unsplash.com/photo-1509391365360-2e959784a276?w=500',
      price: 45000.0,
      originalPrice: 58000.0,
      sellerName: 'PM-KUSUM Approved Vendor',
      rating: 4.9,
      ratingCount: 95,
      inStock: true,
      cropCompatibility: ['All Crops'],
      dosage: 'N/A',
      specifications: '3 HP DC Submersible Pump + 3000W Mono PERC Solar Panels (60% Subsidy Eligible)',
      isGovtCertified: true,
      description: 'High-efficiency solar irrigation pump set backed by PM-KUSUM government subsidy scheme.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProductDetailsModal(ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.82,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image & Badges
                      Stack(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.inventory_2_rounded, size: 80, color: Colors.green),
                          ),
                          if (product.isGovtCertified)
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(color: Colors.green.shade800, borderRadius: BorderRadius.circular(20)),
                                child: const Row(
                                  children: [
                                    Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text('Govt Certified', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Seller: ${product.sellerName}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Text('₹${product.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                          const SizedBox(width: 10),
                          Text('₹${product.originalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                            child: Text('${product.discountPercentage}% OFF', style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(product.description, style: TextStyle(color: Colors.grey.shade800, fontSize: 13)),
                      const SizedBox(height: 14),

                      const Text('Recommended Dosage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.amber.shade300)),
                        child: Text(product.dosage, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                      ),
                      const SizedBox(height: 14),

                      const Text('Crop Compatibility', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: product.cropCompatibility.map((crop) {
                          return Chip(
                            avatar: const Icon(Icons.eco_rounded, size: 16, color: Colors.green),
                            label: Text(crop, style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.green.shade50,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      const Text('Specifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(product.specifications, style: TextStyle(color: Colors.grey.shade800, fontSize: 13)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(cartItemCountProvider.notifier).state++;
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🛒 ${product.name} added to cart!'),
                      backgroundColor: Colors.green.shade800,
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_checkout_rounded),
                label: const Text('Add to Shopping Cart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCategory = ref.watch(selectedProductCategoryProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    final filteredProducts = _sampleProducts.where((p) {
      final matchesCategory = selectedCategory == 'All' ||
          (selectedCategory == 'Govt Certified' ? p.isGovtCertified : p.category == selectedCategory);
      final matchesSearch = _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.storefront_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('Agri Marketplace'),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cart contains $cartCount items. Ready for checkout.')),
                  );
                },
              ),
              if (cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Search Seeds, Fertilizers, Machinery...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
            ),
          ),

          // Horizontal Category Filter Pills
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (ctx, idx) {
                final cat = _categories[idx];
                final isSelected = cat == selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: Colors.green,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                    onSelected: (val) {
                      ref.read(selectedProductCategoryProvider.notifier).state = cat;
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Product Grid
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text('No agri products found matching "$_searchQuery"', style: TextStyle(color: Colors.grey.shade700)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (ctx, idx) {
                      final p = filteredProducts[idx];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          onTap: () => _showProductDetailsModal(p),
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image Placeholder Header
                              Expanded(
                                flex: 5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      p.category == 'Machinery'
                                          ? Icons.agriculture_rounded
                                          : (p.category == 'Seeds' ? Icons.grass_rounded : Icons.opacity_rounded),
                                      size: 48,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ),

                              // Product Info
                              Expanded(
                                flex: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (p.isGovtCertified)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          margin: const EdgeInsets.only(bottom: 4),
                                          decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(6)),
                                          child: Text('Govt Certified', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green.shade900)),
                                        ),
                                      Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                          Text(' ${p.rating} ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          Text('(${p.ratingCount})', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text('₹${p.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15)),
                                          const SizedBox(width: 6),
                                          if (p.discountPercentage > 0)
                                            Text('${p.discountPercentage}% OFF', style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

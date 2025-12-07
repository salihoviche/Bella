import 'package:flutter/material.dart';
import 'package:bella_desktop/layouts/master_screen.dart';
import 'package:bella_desktop/model/product.dart';
import 'package:bella_desktop/model/search_result.dart';
import 'package:bella_desktop/model/category.dart';
import 'package:bella_desktop/model/manufacturer.dart';
import 'package:bella_desktop/providers/product_provider.dart';
import 'package:bella_desktop/providers/category_provider.dart';
import 'package:bella_desktop/providers/manufacturer_provider.dart';
import 'package:bella_desktop/screens/product_details_screen.dart';
import 'package:bella_desktop/screens/product_edit_screen.dart';
import 'package:bella_desktop/utils/base_table.dart';
import 'package:bella_desktop/utils/base_pagination.dart';
import 'package:bella_desktop/utils/base_textfield.dart';
import 'package:bella_desktop/utils/base_picture_cover.dart';
import 'package:bella_desktop/utils/base_dropdown.dart';
import 'package:provider/provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late ProductProvider productProvider;
  late CategoryProvider categoryProvider;
  late ManufacturerProvider manufacturerProvider;
  
  TextEditingController nameController = TextEditingController();
  Category? selectedCategory;
  Manufacturer? selectedManufacturer;
  
  List<Category> _categories = [];
  List<Manufacturer> _manufacturers = [];

  SearchResult<Product>? products;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      productProvider = context.read<ProductProvider>();
      categoryProvider = context.read<CategoryProvider>();
      manufacturerProvider = context.read<ManufacturerProvider>();
      
      await _loadCategories();
      await _loadManufacturers();
      await _performSearch(page: 0);
    });
  }

  Future<void> _loadCategories() async {
    try {
      final result = await categoryProvider.get(filter: {
        'isActive': true,
        'pageSize': 1000,
      });
      setState(() {
        _categories = result.items ?? [];
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadManufacturers() async {
    try {
      final result = await manufacturerProvider.get(filter: {
        'isActive': true,
        'pageSize': 1000,
      });
      setState(() {
        _manufacturers = result.items ?? [];
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    final filter = {
      if (nameController.text.isNotEmpty) 'name': nameController.text,
      if (selectedCategory != null) 'categoryId': selectedCategory!.id,
      if (selectedManufacturer != null) 'manufacturerId': selectedManufacturer!.id,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };
    var productsResult = await productProvider.get(filter: filter);
    setState(() {
      this.products = productsResult;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  Future<void> _deactivateProduct(Product product) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Product'),
        content: Text(
          'Are you sure you want to deactivate ${product.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Create request with all product data, but set isActive to false
      final request = {
        'name': product.name,
        'price': product.price,
        'picture': product.picture,
        'categoryId': product.categoryId,
        'manufacturerId': product.manufacturerId,
        'isActive': false,
      };

      await productProvider.update(product.id, request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deactivated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        // Refresh the list
        await _performSearch();
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Products Administration",
      child: Center(
        child: Column(
          children: [
            _buildSearch(),
            Expanded(child: _buildResultView()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: customTextFieldDecoration(
                "Name",
                prefixIcon: Icons.search,
              ),
              controller: nameController,
              onSubmitted: (value) => _performSearch(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: BaseDropdown<Category?>(
              label: 'Category',
              prefixIcon: Icons.category_outlined,
              value: selectedCategory,
              items: [
                const DropdownMenuItem<Category?>(value: null, child: Text('All Categories')),
                ..._categories.map((category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.name),
                  );
                }),
              ],
              onChanged: (Category? newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
                _performSearch(page: 0);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: BaseDropdown<Manufacturer?>(
              label: 'Manufacturer',
              prefixIcon: Icons.factory_outlined,
              value: selectedManufacturer,
              items: [
                const DropdownMenuItem<Manufacturer?>(value: null, child: Text('All Manufacturers')),
                ..._manufacturers.map((manufacturer) {
                  return DropdownMenuItem<Manufacturer>(
                    value: manufacturer,
                    child: Text(manufacturer.name),
                  );
                }),
              ],
              onChanged: (Manufacturer? newValue) {
                setState(() {
                  selectedManufacturer = newValue;
                });
                _performSearch(page: 0);
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _performSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: const Color(0xFF1F2937),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  "Search",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductEditScreen(),
                  settings: const RouteSettings(name: 'ProductEditScreen'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C42),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: const Color(0xFFFF8C42).withOpacity(0.3),
            ).copyWith(
              elevation: WidgetStateProperty.all(0),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'Add Product',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        products == null || products!.items == null || products!.items!.isEmpty;
    final int totalCount = products?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage =
        _currentPage >= totalPages - 1 || totalPages == 0;
    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.shopping_bag_outlined,
            title: "Products",
            width: 1400,
            height: 423,
            imageColumnIndices: {0}, // First column contains images
            columnWidths: [
              80,   // Image
                180,  // Manufacturer
              200,  // Name
              75,  // Price
              180,  // Category
            
              80,  // Active
              200,  // Controls
            ],
            columns: const [
              DataColumn(
                label: Text(
                  "Image",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
                      DataColumn(
                label: Text(
                  "Manufacturer",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Product",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Price",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Category",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
      
              DataColumn(
                label: Text(
                  "Active",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Controls',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
            rows: isEmpty
                ? []
                : products!.items!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(
                            Center(
                              child: SizedBox(
                                width: 70,
                                height: 70,
                                child: e.picture != null && e.picture!.isNotEmpty
                                    ? BasePictureCover(
                                        base64: e.picture!,
                                        width: 70,
                                        height: 70,
                                        isCircular: false,
                                        borderRadius: 8,
                                        borderColor: Colors.grey.withOpacity(0.3),
                                        iconColor: Colors.grey[400]!,
                                        backgroundColor: Colors.grey[200],
                                        fallbackIcon: Icons.shopping_bag,
                                        showShadow: false,
                                      )
                                    : Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.shopping_bag,
                                          color: Colors.grey[400],
                                          size: 40,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                                     DataCell(
                            Text(
                              e.manufacturerName,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(e.name, style: const TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text(
                              '\$${e.price.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(
                              e.categoryName,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
               
                          DataCell(
                            Icon(
                              e.isActive
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: e.isActive ? Colors.green : Colors.red,
                              size: 20,
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductDetailsScreen(product: e),
                                            settings: const RouteSettings(
                                              name: 'ProductDetailsScreen',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF8C42).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: const Color(0xFFFF8C42).withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.visibility_outlined,
                                          color: Color(0xFFFF8C42),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductEditScreen(product: e),
                                            settings: const RouteSettings(
                                              name: 'ProductEditScreen',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFFFF8C42),
                                              Color(0xFFFF6B1A),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFF8C42).withOpacity(0.25),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.edit_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Deactivate button - only show for active products
                                if (e.isActive) ...[
                                  const SizedBox(width: 10),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () => _deactivateProduct(e),
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: const Color(0xFFFF8C42).withOpacity(0.3),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.block_outlined,
                                            color: Colors.red,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
            emptyIcon: Icons.shopping_bag,
            emptyText: "No products found.",
            emptySubtext: "Try adjusting your search or add a new product.",
          ),
          const SizedBox(height: 30),
          BasePagination(
            currentPage: _currentPage,
            totalPages: totalPages,
            onPrevious: isFirstPage
                ? null
                : () => _performSearch(page: _currentPage - 1),
            onNext: isLastPage
                ? null
                : () => _performSearch(page: _currentPage + 1),
            showPageSizeSelector: true,
            pageSize: _pageSize,
            pageSizeOptions: _pageSizeOptions,
            onPageSizeChanged: (newSize) {
              if (newSize != null && newSize != _pageSize) {
                _performSearch(page: 0, pageSize: newSize);
              }
            },
          ),
        ],
      ),
    );
  }
}

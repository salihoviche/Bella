import 'package:flutter/material.dart';
import 'package:bella_desktop/layouts/master_screen.dart';
import 'package:bella_desktop/model/hairstyle.dart';
import 'package:bella_desktop/model/search_result.dart';
import 'package:bella_desktop/model/length.dart';
import 'package:bella_desktop/model/gender.dart';
import 'package:bella_desktop/providers/hairstyle_provider.dart';
import 'package:bella_desktop/providers/length_provider.dart';
import 'package:bella_desktop/providers/gender_provider.dart';
import 'package:bella_desktop/screens/hairstyle_details_screen.dart';
import 'package:bella_desktop/screens/hairstyle_edit_screen.dart';
import 'package:bella_desktop/utils/base_table.dart';
import 'package:bella_desktop/utils/base_pagination.dart';
import 'package:bella_desktop/utils/base_textfield.dart';
import 'package:bella_desktop/utils/base_picture_cover.dart';
import 'package:bella_desktop/utils/base_dropdown.dart';
import 'package:provider/provider.dart';

class HairstyleListScreen extends StatefulWidget {
  const HairstyleListScreen({super.key});

  @override
  State<HairstyleListScreen> createState() => _HairstyleListScreenState();
}

class _HairstyleListScreenState extends State<HairstyleListScreen> {
  late HairstyleProvider hairstyleProvider;
  late LengthProvider lengthProvider;
  late GenderProvider genderProvider;
  
  TextEditingController nameController = TextEditingController();
  Length? selectedLength;
  Gender? selectedGender;
  
  List<Length> _lengths = [];
  List<Gender> _genders = [];

  SearchResult<Hairstyle>? hairstyles;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      hairstyleProvider = context.read<HairstyleProvider>();
      lengthProvider = context.read<LengthProvider>();
      genderProvider = context.read<GenderProvider>();
      
      await _loadLengths();
      await _loadGenders();
      await _performSearch(page: 0);
    });
  }

  Future<void> _loadLengths() async {
    try {
      final result = await lengthProvider.get(filter: {
        'pageSize': 1000,
      });
      setState(() {
        _lengths = result.items ?? [];
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadGenders() async {
    try {
      final result = await genderProvider.get(filter: {
        'isActive': true,
        'pageSize': 1000,
      });
      setState(() {
        _genders = result.items ?? [];
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
      if (selectedLength != null) 'lengthId': selectedLength!.id,
      if (selectedGender != null) 'genderId': selectedGender!.id,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };
    var hairstylesResult = await hairstyleProvider.get(filter: filter);
    setState(() {
      this.hairstyles = hairstylesResult;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  Future<void> _deactivateHairstyle(Hairstyle hairstyle) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Hairstyle'),
        content: Text(
          'Are you sure you want to deactivate ${hairstyle.name}?',
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
      // Create request with all hairstyle data, but set isActive to false
      final request = {
        'name': hairstyle.name,
        'price': hairstyle.price,
        'image': hairstyle.image,
        'lengthId': hairstyle.lengthId,
        'genderId': hairstyle.genderId,
        'isActive': false,
      };

      await hairstyleProvider.update(hairstyle.id, request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hairstyle deactivated successfully'),
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
      title: "Hairstyles Administration",
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
            child: BaseDropdown<Length?>(
              label: 'Length',
              prefixIcon: Icons.straighten_outlined,
              value: selectedLength,
              items: [
                const DropdownMenuItem<Length?>(value: null, child: Text('All Lengths')),
                ..._lengths.map((length) {
                  return DropdownMenuItem<Length>(
                    value: length,
                    child: Text(length.name),
                  );
                }),
              ],
              onChanged: (Length? newValue) {
                setState(() {
                  selectedLength = newValue;
                });
                _performSearch(page: 0);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: BaseDropdown<Gender?>(
              label: 'Gender',
              prefixIcon: Icons.person_outline,
              value: selectedGender,
              items: [
                const DropdownMenuItem<Gender?>(value: null, child: Text('All Genders')),
                ..._genders.map((gender) {
                  return DropdownMenuItem<Gender>(
                    value: gender,
                    child: Text(gender.name),
                  );
                }),
              ],
              onChanged: (Gender? newValue) {
                setState(() {
                  selectedGender = newValue;
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
                  builder: (context) => const HairstyleEditScreen(),
                  settings: const RouteSettings(name: 'HairstyleEditScreen'),
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
                  'Add Hairstyle',
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
        hairstyles == null || hairstyles!.items == null || hairstyles!.items!.isEmpty;
    final int totalCount = hairstyles?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage =
        _currentPage >= totalPages - 1 || totalPages == 0;
    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.content_cut_outlined,
            title: "Hairstyles",
            width: 1400,
            height: 423,
            imageColumnIndices: {0}, // First column contains images
            columnWidths: [
              80,   // Image
              250,  // Name
              80,   // Price
              150,  // Length
              150,  // Gender
              80,   // Active
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
                  "Name",
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
                  "Length",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Gender",
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
                : hairstyles!.items!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(
                            Center(
                              child: SizedBox(
                                width: 50,
                                height: 90,
                                child: e.image != null && e.image!.isNotEmpty
                                    ? BasePictureCover(
                                        base64: e.image!,
                                        width: 70,
                                        height: 70,
                                        isCircular: false,
                                        borderRadius: 8,
                                        borderColor: Colors.grey.withOpacity(0.3),
                                        iconColor: Colors.grey[400]!,
                                        backgroundColor: Colors.grey[200],
                                        fallbackIcon: Icons.content_cut,
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
                                          Icons.content_cut,
                                          color: Colors.grey[400],
                                          size: 40,
                                        ),
                                      ),
                              ),
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
                              e.lengthName,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(
                              e.genderName,
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
                                                HairstyleDetailsScreen(hairstyle: e),
                                            settings: const RouteSettings(
                                              name: 'HairstyleDetailsScreen',
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
                                                HairstyleEditScreen(hairstyle: e),
                                            settings: const RouteSettings(
                                              name: 'HairstyleEditScreen',
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
                                // Deactivate button - only show for active hairstyles
                                if (e.isActive) ...[
                                  const SizedBox(width: 10),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () => _deactivateHairstyle(e),
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
            emptyIcon: Icons.content_cut,
            emptyText: "No hairstyles found.",
            emptySubtext: "Try adjusting your search or add a new hairstyle.",
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


import 'package:flutter/material.dart';
import 'package:bella_desktop/layouts/master_screen.dart';
import 'package:bella_desktop/model/review.dart';
import 'package:bella_desktop/model/search_result.dart';
import 'package:bella_desktop/model/user.dart';
import 'package:bella_desktop/providers/review_provider.dart';
import 'package:bella_desktop/providers/user_provider.dart';
import 'package:bella_desktop/screens/review_details_screen.dart';
import 'package:bella_desktop/utils/base_pagination.dart';
import 'package:bella_desktop/utils/base_table.dart';
import 'package:bella_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

// Orange color scheme
const Color _orangePrimary = Color(0xFFFF8C42);

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  late ReviewProvider reviewProvider;
  late UserProvider userProvider;

  int? selectedUserId;
  int? selectedHairdresserId;
  int? selectedRating;

  List<User> _users = [];
  List<User> _hairdressers = [];
  bool _isLoadingUsers = false;
  bool _isLoadingHairdressers = false;

  SearchResult<Review>? reviews;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    final filter = {
      if (selectedUserId != null) 'userId': selectedUserId,
      if (selectedHairdresserId != null) 'hairdresserId': selectedHairdresserId,
      if (selectedRating != null) 'rating': selectedRating,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };

    final result = await reviewProvider.get(filter: filter);
    setState(() {
      reviews = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final result = await userProvider.get(filter: {
        'roleId': 2, // User role (customers)
        'page': 0,
        'pageSize': 1000, // Get all users
        'includeTotalCount': false,
      });

      if (result.items != null) {
        setState(() {
          _users = result.items!;
          _isLoadingUsers = false;
        });
      } else {
        setState(() {
          _users = [];
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      setState(() {
        _users = [];
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _loadHairdressers() async {
    setState(() {
      _isLoadingHairdressers = true;
    });

    try {
      final result = await userProvider.get(filter: {
        'roleId': 3, // Hairdresser role
        'page': 0,
        'pageSize': 1000, // Get all hairdressers
        'includeTotalCount': false,
      });

      if (result.items != null) {
        setState(() {
          _hairdressers = result.items!;
          _isLoadingHairdressers = false;
        });
      } else {
        setState(() {
          _hairdressers = [];
          _isLoadingHairdressers = false;
        });
      }
    } catch (e) {
      setState(() {
        _hairdressers = [];
        _isLoadingHairdressers = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reviewProvider = context.read<ReviewProvider>();
      userProvider = context.read<UserProvider>();
      await Future.wait([
        _loadUsers(),
        _loadHairdressers(),
        _performSearch(page: 0),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Reviews Administration',
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildUserDropdown(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHairdresserDropdown(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  decoration: customTextFieldDecoration(
                    'Rating',
                    prefixIcon: Icons.star,
                  ),
                  value: selectedRating,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All Ratings'),
                    ),
                    ...List.generate(5, (index) => index + 1).map(
                      (rating) => DropdownMenuItem<int?>(
                        value: rating,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text('$rating'),
                            ),
                            const SizedBox(width: 4),
                            ...List.generate(
                              rating,
                              (index) => const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRating = value;
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserDropdown() {
    if (_isLoadingUsers) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text("Loading users...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return DropdownButtonFormField<int?>(
      decoration: customTextFieldDecoration(
        'Customer',
        prefixIcon: Icons.person,
      ),
      value: selectedUserId,
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('All Customers'),
        ),
        ..._users.map((user) => DropdownMenuItem<int?>(
              value: user.id,
              child: Text('${user.firstName} ${user.lastName}'),
            )),
      ],
      onChanged: (value) {
        setState(() {
          selectedUserId = value;
        });
        _performSearch(page: 0);
      },
    );
  }

  Widget _buildHairdresserDropdown() {
    if (_isLoadingHairdressers) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text("Loading hairdressers...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return DropdownButtonFormField<int?>(
      decoration: customTextFieldDecoration(
        'Hairdresser',
        prefixIcon: Icons.content_cut,
      ),
      value: selectedHairdresserId,
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('All Hairdressers'),
        ),
        ..._hairdressers.map((hairdresser) => DropdownMenuItem<int?>(
              value: hairdresser.id,
              child: Text('${hairdresser.firstName} ${hairdresser.lastName}'),
            )),
      ],
      onChanged: (value) {
        setState(() {
          selectedHairdresserId = value;
        });
        _performSearch(page: 0);
      },
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        reviews == null || reviews!.items == null || reviews!.items!.isEmpty;
    final int totalCount = reviews?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.rate_review,
            title: 'Reviews',
            width: 1200,
            height: 423,
            columnWidths: const [
              180, // Customer Name
              180, // Hairdresser Name
              120, // Rating
              420, // Comment
              130, // Controls
            ],
            columns: const [
              DataColumn(
                label: Text(
                  'Customer Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Hairdresser Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Rating',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Comment',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
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
                : reviews!.items!
                      .map(
                        (e) => DataRow(
                          cells: [
                            DataCell(
                              Text(
                                e.userFullName,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                e.hairdresserFullName.isNotEmpty 
                                    ? e.hairdresserFullName 
                                    : 'N/A',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  ...List.generate(
                                    e.rating,
                                    (index) => const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                e.comment ?? 'No comment',
                                style: const TextStyle(fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                                                  ReviewDetailsScreen(review: e),
                                              settings: const RouteSettings(
                                                name: 'ReviewDetailsScreen',
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: _orangePrimary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: _orangePrimary.withOpacity(0.3),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.visibility_outlined,
                                            color: _orangePrimary,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            emptyIcon: Icons.rate_review,
            emptyText: 'No reviews found.',
            emptySubtext: 'Try adjusting your search criteria.',
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

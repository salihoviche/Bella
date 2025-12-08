import 'package:flutter/material.dart';
import 'package:bella_desktop/layouts/master_screen.dart';
import 'package:bella_desktop/model/appointment.dart';
import 'package:bella_desktop/model/search_result.dart';
import 'package:bella_desktop/providers/appointment_provider.dart';
import 'package:bella_desktop/screens/appointment_details_screen.dart';
import 'package:bella_desktop/utils/base_pagination.dart';
import 'package:bella_desktop/utils/base_table.dart';
import 'package:bella_desktop/utils/base_textfield.dart';
import 'package:bella_desktop/utils/base_date_picker.dart';
import 'package:provider/provider.dart';

// Orange color scheme matching the app
const Color _orangePrimary = Color(0xFFFF8C42);
const Color _orangeDark = Color(0xFFFF6B1A);

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  late AppointmentProvider appointmentProvider;

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController hairdresserNameController = TextEditingController();
  DateTime? selectedDate;

  SearchResult<Appointment>? appointments;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    final filter = {
      // FTS searches both user and hairdresser names, so combine if both are provided
      if (userNameController.text.isNotEmpty || hairdresserNameController.text.isNotEmpty)
        'fts': [
          if (userNameController.text.isNotEmpty) userNameController.text,
          if (hairdresserNameController.text.isNotEmpty) hairdresserNameController.text,
        ].join(' '),
      if (selectedDate != null) 'appointmentDateFrom': selectedDate!,
      if (selectedDate != null)
        'appointmentDateTo': DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          23,
          59,
          59,
        ),
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };

    final result = await appointmentProvider.get(filter: filter);
    setState(() {
      appointments = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      appointmentProvider = context.read<AppointmentProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  void dispose() {
    userNameController.dispose();
    hairdresserNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Appointments Administration',
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
                child: TextField(
                  decoration: customTextFieldDecoration(
                    'User Full Name',
                    prefixIcon: Icons.person,
                  ),
                  controller: userNameController,
                  onSubmitted: (_) => _performSearch(page: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: customTextFieldDecoration(
                    'Hairdresser Full Name',
                    prefixIcon: Icons.content_cut,
                  ),
                  controller: hairdresserNameController,
                  onSubmitted: (_) => _performSearch(page: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BaseDatePicker(
                  label: 'Appointment Date',
                  selectedDate: selectedDate,
                  onChanged: (DateTime? date) {
                    setState(() {
                      selectedDate = date;
                    });
                    _performSearch(page: 0);
                  },
                  prefixIcon: Icons.calendar_today_outlined,
                  hintText: 'Select date',
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _orangePrimary,
                          _orangeDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: _orangePrimary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _performSearch(page: 0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Search',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      userNameController.clear();
                      hairdresserNameController.clear();
                      setState(() {
                        selectedDate = null;
                      });
                      _performSearch(page: 0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty = appointments == null ||
        appointments!.items == null ||
        appointments!.items!.isEmpty;
    final int totalCount = appointments?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.calendar_today_outlined,
            title: "Appointments",
            width: 1400,
            height: 423,
            columnWidths: [
              152, // User Name
              145, // Hairdresser Name
              110, // Status
              160, // Appointment Date
              80, // Final Price
              215, // Services
              120, // Actions
            ],
            columns: const [
              DataColumn(
                label: Text(
                  "User Name",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Hairdresser",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Status",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Date",
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
                  "Services",
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
                : appointments!.items!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(
                            Text(
                              e.userName,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(
                              e.hairdresserName,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 0,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(e.statusName)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(e.statusName),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                e.statusName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: _getStatusColor(e.statusName),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              _formatDate(e.appointmentDate),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(
                              '\$${e.finalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          DataCell(
                            _buildServicesCell(e),
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
                                                AppointmentDetailsScreen(
                                              appointment: e,
                                            ),
                                            settings: const RouteSettings(
                                              name: 'AppointmentDetailsScreen',
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
            emptyIcon: Icons.calendar_today,
            emptyText: "No appointments found.",
            emptySubtext: "Try adjusting your search criteria.",
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

  Widget _buildServicesCell(Appointment appointment) {
    List<String> services = [];
    if (appointment.hairstyleName != null) {
      services.add('Hairstyle');
    }
    if (appointment.facialHairName != null) {
      services.add('Facial Hair');
    }
    if (appointment.dyingName != null) {
      services.add('Dye');
    }

    if (services.isEmpty) {
      return const Text(
        'No services',
        style: TextStyle(fontSize: 13, color: Colors.grey),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: services.map((service) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _orangePrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _orangePrimary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            service,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _orangePrimary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String statusName) {
    switch (statusName.toLowerCase()) {
      case 'reserved':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

import 'package:flutter/material.dart';
import 'package:bella_client_mobile/screens/history_products_list_screen.dart';
import 'package:bella_client_mobile/screens/history_appointments_list_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Orange color scheme
  static const Color orangePrimary = Color(0xFFFF8C42);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: orangePrimary,
              indicatorWeight: 3,
              labelColor: orangePrimary,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.shopping_bag_rounded, size: 24),
                  text: 'Products',
                ),
                Tab(
                  icon: Icon(Icons.calendar_today_rounded, size: 24),
                  text: 'Appointments',
                ),
              ],
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                HistoryProductsListScreen(),
                HistoryAppointmentsListScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


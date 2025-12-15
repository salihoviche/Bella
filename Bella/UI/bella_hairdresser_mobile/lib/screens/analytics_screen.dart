import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bella_hairdresser_mobile/providers/hairdresser_analytics_provider.dart';
import 'package:bella_hairdresser_mobile/providers/user_provider.dart';
import 'package:bella_hairdresser_mobile/model/hairdresser_analytics.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTime _selectedDate = DateTime.now();
  
  // Purple color scheme for hairdresser app
  static const Color purplePrimary = Color(0xFF8B5CF6);
  static const Color purpleDark = Color(0xFF6D28D9);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
    });
  }

  Future<void> _loadAnalytics() async {
    final user = UserProvider.currentUser;
    if (user == null) return;

    final hairdresserAnalyticsProvider =
        Provider.of<HairdresserAnalyticsProvider>(context, listen: false);
    
    await hairdresserAnalyticsProvider.getHairdresserAnalytics(
      user.id,
      _selectedDate.year,
      _selectedDate.month,
    );
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    });
    _loadAnalytics();
  }

  void _goToNextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    });
    _loadAnalytics();
  }

  void _goToCurrentMonth() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, 1);
    });
    _loadAnalytics();
  }

  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _loadAnalytics,
        color: purplePrimary,
        child: Consumer<HairdresserAnalyticsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(purplePrimary),
                ),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.error ?? 'Error loading analytics',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadAnalytics,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purplePrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final analytics = provider.hairdresserAnalytics;
            if (analytics == null) {
              return const Center(
                child: Text('No analytics data available'),
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month selector
                  _buildMonthSelector(),
                  const SizedBox(height: 20),
                  
                  // Summary cards
                  _buildSummaryCards(analytics),
                  const SizedBox(height: 20),
                  
                  // Appointments chart
                  _buildAppointmentsChart(analytics),
                  const SizedBox(height: 20),
                  
                  // Revenue chart
                  _buildRevenueChart(analytics),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    final isCurrentMonth = _isCurrentMonth(_selectedDate);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            purpleDark,
            purplePrimary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: purplePrimary.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title and Month Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCurrentMonth ? Icons.today_rounded : Icons.calendar_today_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Month Button
              _buildNavButton(
                icon: Icons.chevron_left_rounded,
                onPressed: _goToPreviousMonth,
              ),
              
              // This Month Button (if not current month)
              if (!isCurrentMonth)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildCurrentMonthButton(),
                  ),
                )
              else
                const Spacer(),
              
              // Next Month Button
              _buildNavButton(
                icon: Icons.chevron_right_rounded,
                onPressed: _goToNextMonth,
                isNext: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isNext = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildCurrentMonthButton() {
    return GestureDetector(
      onTap: _goToCurrentMonth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Text(
          'This Month',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSummaryCards(HairdresserAnalyticsResponse analytics) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Appointments',
            analytics.totalAppointments.toString(),
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total Revenue',
            '\$${analytics.totalRevenue.toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsChart(HairdresserAnalyticsResponse analytics) {
    final dailyData = analytics.dailyData;
    if (dailyData.isEmpty) {
      return _buildEmptyChartCard('Daily Appointments', Icons.calendar_today);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: purplePrimary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Daily Appointments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: dailyData.length * 35.0, // ~35px per day
                  child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: dailyData.map((d) => d.appointmentCount.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => purplePrimary,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    tooltipMargin: 12,
                    direction: TooltipDirection.auto,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final index = group.x.toInt();
                      if (index < 0 || index >= dailyData.length) {
                        return BarTooltipItem(
                          '',
                          const TextStyle(color: Colors.transparent),
                        );
                      }
                      final dayData = dailyData[index];
                      final count = dayData.appointmentCount;
                      return BarTooltipItem(
                        '$count ${count == 1 ? 'appointment' : 'appointments'}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= dailyData.length || value.toInt() < 0) {
                              return const Text('');
                            }
                            final dayData = dailyData[value.toInt()];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                dayData.dayNumber.toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[200]!,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: dailyData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final dayData = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: dayData.appointmentCount.toDouble(),
                            color: purplePrimary,
                            width: 12,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
                ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(HairdresserAnalyticsResponse analytics) {
    final dailyData = analytics.dailyData;
    if (dailyData.isEmpty) {
      return _buildEmptyChartCard('Daily Revenue', Icons.attach_money);
    }

    final maxRevenue = dailyData.map((d) => d.revenue).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: purpleDark, size: 24),
              const SizedBox(width: 8),
              Text(
                'Daily Revenue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: dailyData.length * 35.0, // ~35px per day
                  child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => purpleDark,
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((LineBarSpot touchedSpot) {
                            return LineTooltipItem(
                              '\$${touchedSpot.y.toStringAsFixed(2)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxRevenue > 0 ? maxRevenue / 5 : 10,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[200]!,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= dailyData.length || value.toInt() < 0) {
                              return const Text('');
                            }
                            final dayData = dailyData[value.toInt()];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                dayData.dayNumber.toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '\$${value.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (dailyData.length - 1).toDouble(),
                    minY: 0,
                    maxY: maxRevenue * 1.2,
                    lineBarsData: [
                      LineChartBarData(
                        spots: dailyData.asMap().entries.map((entry) {
                          return FlSpot(entry.key.toDouble(), entry.value.revenue);
                        }).toList(),
                        isCurved: true,
                        color: purpleDark,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: purpleDark.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChartCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}


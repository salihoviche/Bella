import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bella_desktop/layouts/master_screen.dart';
import 'package:bella_desktop/model/analytics.dart';
import 'package:bella_desktop/providers/analytics_provider.dart';
import 'package:provider/provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().getAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Business Insights',
      child: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: TextStyle(color: Colors.red[700], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.getAnalytics(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final analytics = provider.analytics;
          if (analytics == null) {
            return const Center(child: Text('No data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
  

                // First Row: Products and Hairstyles
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildProductsPieChart(analytics.top3Products),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildHairstylesPieChart(analytics.top3Hairstyles),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Second Row: Facial Hairs and Dye Colors
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildFacialHairsPieChart(analytics.top3FacialHairs),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildDyingColorsPieChart(analytics.top3DyingColors),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsPieChart(List<TopProductAnalyticsResponse> products) {
    if (products.isEmpty) {
      return _buildEmptyChartCard('Top Products', Icons.shopping_bag);
    }

    final totalQuantity = products.fold<int>(
      0,
      (sum, product) => sum + product.totalQuantitySold,
    );

    final pieChartSections = products.asMap().entries.map((entry) {
      final index = entry.key;
      final product = entry.value;
      final percentage = totalQuantity > 0
          ? (product.totalQuantitySold / totalQuantity * 100)
          : 0.0;

      final colors = [
        const Color(0xFF2F855A),
        const Color(0xFF38A169),
        const Color(0xFF48BB78),
      ];

      return PieChartSectionData(
        value: product.totalQuantitySold.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[index % colors.length],
        radius: 52,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_bag, color: Color(0xFF2F855A)),
                const SizedBox(width: 8),
                const Text(
                  'Top 3 Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 175,
                  height: 175,
                  child: PieChart(
                    PieChartData(
                      sections: pieChartSections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 45,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: products.asMap().entries.map((entry) {
                      final index = entry.key;
                      final product = entry.value;
                      final colors = [
                        const Color(0xFF2F855A),
                        const Color(0xFF38A169),
                        const Color(0xFF48BB78),
                      ];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${product.totalQuantitySold} sold • \$${product.totalRevenue.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHairstylesPieChart(List<TopHairstyleAnalyticsResponse> hairstyles) {
    if (hairstyles.isEmpty) {
      return _buildEmptyChartCard('Top Hairstyles', Icons.face);
    }

    final totalAppointments = hairstyles.fold<int>(
      0,
      (sum, hairstyle) => sum + hairstyle.totalAppointments,
    );

    final pieChartSections = hairstyles.asMap().entries.map((entry) {
      final index = entry.key;
      final hairstyle = entry.value;
      final percentage = totalAppointments > 0
          ? (hairstyle.totalAppointments / totalAppointments * 100)
          : 0.0;

      final colors = [
        const Color(0xFF805AD5),
        const Color(0xFF9F7AEA),
        const Color(0xFFB794F6),
      ];

      return PieChartSectionData(
        value: hairstyle.totalAppointments.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[index % colors.length],
        radius: 52,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.face, color: Color(0xFF805AD5)),
                const SizedBox(width: 8),
                const Text(
                  'Top 3 Hairstyles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 175,
                  height: 175,
                  child: PieChart(
                    PieChartData(
                      sections: pieChartSections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 45,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: hairstyles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final hairstyle = entry.value;
                      final colors = [
                        const Color(0xFF805AD5),
                        const Color(0xFF9F7AEA),
                        const Color(0xFFB794F6),
                      ];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hairstyle.hairstyleName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${hairstyle.totalAppointments} appointments • \$${hairstyle.totalRevenue.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacialHairsPieChart(List<TopFacialHairAnalyticsResponse> facialHairs) {
    if (facialHairs.isEmpty) {
      return _buildEmptyChartCard('Top Facial Hairs', Icons.face_retouching_natural);
    }

    final totalAppointments = facialHairs.fold<int>(
      0,
      (sum, facialHair) => sum + facialHair.totalAppointments,
    );

    final pieChartSections = facialHairs.asMap().entries.map((entry) {
      final index = entry.key;
      final facialHair = entry.value;
      final percentage = totalAppointments > 0
          ? (facialHair.totalAppointments / totalAppointments * 100)
          : 0.0;

      final colors = [
        const Color(0xFFD69E2E),
        const Color(0xFFECC94B),
        const Color(0xFFF6E05E),
      ];

      return PieChartSectionData(
        value: facialHair.totalAppointments.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[index % colors.length],
        radius: 52,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.face_retouching_natural, color: Color(0xFFD69E2E)),
                const SizedBox(width: 8),
                const Text(
                  'Top 3 Facial Hairs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 175,
                  height: 175,
                  child: PieChart(
                    PieChartData(
                      sections: pieChartSections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 45,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: facialHairs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final facialHair = entry.value;
                      final colors = [
                        const Color(0xFFD69E2E),
                        const Color(0xFFECC94B),
                        const Color(0xFFF6E05E),
                      ];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    facialHair.facialHairName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${facialHair.totalAppointments} appointments • \$${facialHair.totalRevenue.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDyingColorsPieChart(List<TopDyingAnalyticsResponse> dyingColors) {
    if (dyingColors.isEmpty) {
      return _buildEmptyChartCard('Top Dye Colors', Icons.palette);
    }

    final totalAppointments = dyingColors.fold<int>(
      0,
      (sum, dying) => sum + dying.totalAppointments,
    );

    final pieChartSections = dyingColors.asMap().entries.map((entry) {
      final index = entry.key;
      final dying = entry.value;
      final percentage = totalAppointments > 0
          ? (dying.totalAppointments / totalAppointments * 100)
          : 0.0;

      final colors = [
        const Color(0xFFFF8C42),
        const Color(0xFFFF6B1A),
        const Color(0xFFFFA500),
      ];

      return PieChartSectionData(
        value: dying.totalAppointments.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[index % colors.length],
        radius: 52,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette, color: Color(0xFFFF8C42)),
                const SizedBox(width: 8),
                const Text(
                  'Top 3 Dye Colors',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 175,
                  height: 175,
                  child: PieChart(
                    PieChartData(
                      sections: pieChartSections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 45,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: dyingColors.asMap().entries.map((entry) {
                      final index = entry.key;
                      final dying = entry.value;
                      final colors = [
                        const Color(0xFFFF8C42),
                        const Color(0xFFFF6B1A),
                        const Color(0xFFFFA500),
                      ];

                      // Parse hex color if available
                      Color? dyingColor;
                      if (dying.dyingHexCode != null && dying.dyingHexCode!.isNotEmpty) {
                        try {
                          String hex = dying.dyingHexCode!.replaceAll('#', '');
                          if (hex.length == 3) {
                            hex = hex.split('').map((char) => char + char).join();
                          }
                          if (hex.length == 6) {
                            dyingColor = Color(int.parse('FF$hex', radix: 16));
                          }
                        } catch (e) {
                          // Invalid hex code
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: dyingColor ?? colors[index % colors.length],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dying.dyingName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${dying.totalAppointments} appointments • \$${dying.totalRevenue.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChartCard(String title, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No $title Data',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

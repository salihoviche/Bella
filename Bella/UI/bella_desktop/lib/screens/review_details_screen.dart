import 'package:flutter/material.dart';
import 'package:bella_desktop/layouts/master_screen.dart';
import 'package:bella_desktop/model/review.dart';
import 'package:bella_desktop/utils/base_picture_cover.dart';

// Orange color scheme matching the app
const Color _orangePrimary = Color(0xFFFF8C42);
const Color _orangeDark = Color(0xFFFF6B1A);

class ReviewDetailsScreen extends StatelessWidget {
  final Review review;

  const ReviewDetailsScreen({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Review Details',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildReviewDetails(context),
      ),
    );
  }

  Widget _buildReviewDetails(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with orange gradient
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _orangePrimary,
                      _orangeDark,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.rate_review_rounded,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Review Information',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const SizedBox(height: 24),

                // Service image and basic info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service image
                    BasePictureCover(
                      base64: review.wellnessServiceImage,
                      size: 120,
                      fallbackIcon: Icons.cut,
                      borderColor: _orangePrimary,
                      iconColor: _orangePrimary,
                      backgroundColor: _orangePrimary.withOpacity(0.1),
                      showShadow: true,
                    ),
                    const SizedBox(width: 24),

                    // Basic review info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.wellnessServiceName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Review by ${review.userFullName}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Rating stars
                          Row(
                            children: [
                              ...List.generate(
                                review.rating,
                                (index) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${review.rating}/5',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),

                // Detailed information grid
                _buildInfoGrid(),

                const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.person_outline,
                label: 'Customer',
                value: review.userFullName,
                iconColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.content_cut,
                label: 'Hairdresser',
                value: review.hairdresserFullName.isNotEmpty 
                    ? review.hairdresserFullName 
                    : 'N/A',
                iconColor: _orangePrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.star_outline,
                label: 'Rating',
                value: '${review.rating} out of 5',
                iconColor: Colors.amber,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.calendar_today_outlined,
                label: 'Review Date',
                value: _formatDate(review.createdAt),
                iconColor: _orangePrimary,
              ),
            ),
          ],
        ),
        if (review.appointment != null) ...[
          const SizedBox(height: 24),
          const Text(
            'Appointment Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: 'Appointment Date',
                  value: _formatDate(review.appointment!.appointmentDate),
                  iconColor: _orangePrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.attach_money,
                  label: 'Final Price',
                  value: '\$${review.appointment!.finalPrice.toStringAsFixed(2)}',
                  iconColor: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.info_outline,
                  label: 'Status',
                  value: review.appointment!.statusName.isNotEmpty 
                      ? review.appointment!.statusName 
                      : 'N/A',
                  iconColor: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.person_outline,
                  label: 'Appointment Customer',
                  value: review.appointment!.userName.isNotEmpty 
                      ? review.appointment!.userName 
                      : 'N/A',
                  iconColor: Colors.purple,
                ),
              ),
            ],
          ),
          if (review.appointment!.hairstyleName != null || 
              review.appointment!.facialHairName != null || 
              review.appointment!.dyingName != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Services',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (review.appointment!.hairstyleName != null && 
                    review.appointment!.hairstyleName!.isNotEmpty)
                  _buildServiceChip(
                    'Hairstyle',
                    review.appointment!.hairstyleName!,
                    review.appointment!.hairstylePrice,
                  ),
                if (review.appointment!.facialHairName != null && 
                    review.appointment!.facialHairName!.isNotEmpty)
                  _buildServiceChip(
                    'Facial Hair',
                    review.appointment!.facialHairName!,
                    review.appointment!.facialHairPrice,
                  ),
                if (review.appointment!.dyingName != null && 
                    review.appointment!.dyingName!.isNotEmpty)
                  _buildServiceChip(
                    'Dying',
                    review.appointment!.dyingName!,
                    null,
                    hexCode: review.appointment!.dyingHexCode,
                  ),
              ],
            ),
          ],
        ],
        if (review.comment != null && review.comment!.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Comment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Text(
              review.comment!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildServiceChip(String label, String name, double? price, {String? hexCode}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _orangePrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _orangePrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cut,
                size: 16,
                color: _orangePrimary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          if (price != null) ...[
            const SizedBox(height: 4),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.green[700],
              ),
            ),
          ],
          if (hexCode != null && hexCode.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _parseHexColor(hexCode),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  hexCode,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _parseHexColor(String hexCode) {
    try {
      // Remove # if present
      String hex = hexCode.replaceAll('#', '');
      // Add alpha if not present
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

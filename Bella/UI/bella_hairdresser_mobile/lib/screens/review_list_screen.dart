import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bella_hairdresser_mobile/model/review.dart';
import 'package:bella_hairdresser_mobile/model/search_result.dart';
import 'package:bella_hairdresser_mobile/providers/review_provider.dart';
import 'package:bella_hairdresser_mobile/providers/user_provider.dart';
import 'package:bella_hairdresser_mobile/screens/review_details_screen.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  SearchResult<Review>? reviews;
  bool _isLoading = false;

  // Purple color scheme for hairdresser app
  static const Color purplePrimary = Color(0xFF8B5CF6); // Purple

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviews();
    });
  }

  Future<void> _loadReviews() async {
    final user = UserProvider.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      
      // Filter reviews by hairdresserId to show only reviews about this hairdresser
      final filter = {
        'hairdresserId': user.id, // Filter by current hairdresser's ID
        'isActive': true,
        'page': 0,
        'pageSize': 100,
        'includeTotalCount': true,
      };

      final result = await reviewProvider.get(filter: filter);
      
      if (mounted) {
        setState(() {
          reviews = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Failed to load reviews: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFE53E3E)),
            SizedBox(width: 8),
            Text("Error"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: purplePrimary,
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(purplePrimary),
              ),
            )
          : reviews == null || reviews!.items == null || reviews!.items!.isEmpty
              ? _buildEmptyState()
              : _buildReviewsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your reviews will appear here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return RefreshIndicator(
      onRefresh: _loadReviews,
      color: purplePrimary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews!.items!.length,
        itemBuilder: (context, index) {
          final review = reviews!.items![index];
          return _buildReviewCard(review);
        },
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewDetailsScreen(review: review),
              ),
            ).then((_) {
              _loadReviews();
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Rating, Date, and Delete Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Star Rating
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: index < review.rating
                          ? Colors.amber
                          : Colors.grey[300],
                      size: 24,
                    );
                  }),
                ),
                // Date and Delete Button
                Row(
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(review.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Appointment Info - Show Customer Info
            if (review.appointment != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: purplePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer
                    Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 16,
                          color: purplePrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Customer: ${review.userFullName}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Appointment Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: purplePrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Date: ${DateFormat('MMM dd, yyyy • hh:mm a').format(review.appointment!.appointmentDate)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Services
                    if (review.appointment!.hairstyleName != null ||
                        review.appointment!.facialHairName != null ||
                        review.appointment!.dyingName != null) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (review.appointment!.hairstyleName != null)
                            _buildServiceChip(
                              review.appointment!.hairstyleName!,
                              Icons.content_cut_rounded,
                            ),
                          if (review.appointment!.facialHairName != null)
                            _buildServiceChip(
                              review.appointment!.facialHairName!,
                              Icons.face_rounded,
                            ),
                          if (review.appointment!.dyingName != null)
                            _buildServiceChip(
                              review.appointment!.dyingName!,
                              Icons.palette_rounded,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Comment
            if (review.comment != null && review.comment!.isNotEmpty)
              Text(
                review.comment!,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1F2937),
                  height: 1.5,
                ),
              )
            else
              Text(
                'No comment provided',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceChip(String label, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? purplePrimary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color ?? purplePrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color ?? purplePrimary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color ?? purplePrimary,
            ),
          ),
        ],
      ),
    );
  }
}


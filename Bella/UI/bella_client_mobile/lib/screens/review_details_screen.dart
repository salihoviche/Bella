import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bella_client_mobile/model/review.dart';
import 'package:bella_client_mobile/providers/review_provider.dart';
import 'package:bella_client_mobile/providers/user_provider.dart';
import 'package:bella_client_mobile/utils/base_picture_cover.dart';
import 'package:bella_client_mobile/layouts/master_screen.dart';

class ReviewDetailsScreen extends StatefulWidget {
  final Review review;

  const ReviewDetailsScreen({
    super.key,
    required this.review,
  });

  @override
  State<ReviewDetailsScreen> createState() => _ReviewDetailsScreenState();
}

class _ReviewDetailsScreenState extends State<ReviewDetailsScreen> {
  late TextEditingController _commentController;
  int _selectedRating = 0;
  bool _isLoading = false;

  // Orange color scheme
  static const Color orangePrimary = Color(0xFFFF8C42);
  static const Color orangeDark = Color(0xFFFF6B1A);

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.review.comment ?? '');
    _selectedRating = widget.review.rating;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _saveReview() async {
    if (_selectedRating == 0) {
      _showErrorSnackbar('Please select a rating');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      final user = UserProvider.currentUser;
      
      if (user == null) {
        _showErrorSnackbar('User not found. Please login again.');
        return;
      }
      
      final requestData = {
        'userId': user.id,
        'rating': _selectedRating,
        'comment': _commentController.text.trim().isEmpty 
            ? null 
            : _commentController.text.trim(),
        'appointmentId': widget.review.appointmentId,
      };
      
      if (widget.review.id == 0) {
        // Create new review - first check if appointment already has a review
        try {
          final existingReviews = await reviewProvider.get(
            filter: {
              'appointmentId': widget.review.appointmentId,
              'userId': user.id,
              'page': 0,
              'pageSize': 1,
              'includeTotalCount': false,
            },
          );
          
          if (existingReviews.items != null && existingReviews.items!.isNotEmpty) {
            if (mounted) {
              _showErrorSnackbar('This appointment already has a review. Please edit the existing review instead.');
              setState(() {
                _isLoading = false;
              });
              return;
            }
          }
        } catch (e) {
          // If check fails, proceed anyway - backend will validate
        }
        
        // Create new review
        await reviewProvider.insert(requestData);
        
        if (mounted) {
          _showSuccessSnackbar('Review created successfully!');
          Navigator.pop(context);
        }
      } else {
        // Update existing review
        await reviewProvider.update(
          widget.review.id,
          requestData,
        );
        
        if (mounted) {
          _showSuccessSnackbar('Review updated successfully!');
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to save review: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: orangePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get service name and image from appointment
    String serviceName = widget.review.wellnessServiceName;
    String? serviceImage = widget.review.wellnessServiceImage;
    IconData serviceIcon = Icons.content_cut_rounded;
    
    if (widget.review.appointment?.hairstyleName != null && 
        widget.review.appointment!.hairstyleName!.isNotEmpty) {
      serviceIcon = Icons.content_cut_rounded;
    } else if (widget.review.appointment?.facialHairName != null && 
               widget.review.appointment!.facialHairName!.isNotEmpty) {
      serviceIcon = Icons.face_rounded;
    } else if (widget.review.appointment?.dyingName != null && 
               widget.review.appointment!.dyingName!.isNotEmpty) {
      serviceIcon = Icons.palette_rounded;
    }

    return MasterScreen(
      title: widget.review.id == 0 ? 'Create Review' : 'Edit Review',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appointment Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 0,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  BasePictureCover(
                    base64: serviceImage,
                    size: 80,
                    fallbackIcon: serviceIcon,
                    borderColor: orangePrimary.withOpacity(0.2),
                    iconColor: orangePrimary,
                    backgroundColor: orangePrimary.withOpacity(0.1),
                    isCircular: false,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName.isNotEmpty ? serviceName : 'Appointment',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (widget.review.appointment != null)
                          Text(
                            DateFormat('MMM dd, yyyy • hh:mm a').format(widget.review.appointment!.appointmentDate),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'Hairdresser: ${widget.review.hairdresserFullName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rating Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rating',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRating = index + 1;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            index < _selectedRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 48,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Comment Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: orangePrimary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    orangePrimary,
                    orangeDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: orangePrimary.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveReview,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save_rounded, size: 22),
                  label: Text(
                    _isLoading 
                        ? (widget.review.id == 0 ? 'Creating...' : 'Updating...')
                        : (widget.review.id == 0 ? 'Create Review' : 'Update Review'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    disabledForegroundColor: Colors.white70,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}


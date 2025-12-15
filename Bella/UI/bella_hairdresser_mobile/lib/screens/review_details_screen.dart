import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bella_hairdresser_mobile/model/review.dart';
import 'package:bella_hairdresser_mobile/utils/base_picture_cover.dart';
import 'package:bella_hairdresser_mobile/layouts/master_screen.dart';

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

  // Purple color scheme for hairdresser app
  static const Color purplePrimary = Color(0xFF8B5CF6); // Purple


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
      title: 'Review Details',
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
                    borderColor: purplePrimary.withOpacity(0.2),
                    iconColor: purplePrimary,
                    backgroundColor: purplePrimary.withOpacity(0.1),
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
                          'Customer: ${widget.review.userFullName}',
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
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          index < widget.review.rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 48,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Comment Section
            if (widget.review.comment != null && widget.review.comment!.isNotEmpty)
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        widget.review.comment!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1F2937),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox.shrink(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}


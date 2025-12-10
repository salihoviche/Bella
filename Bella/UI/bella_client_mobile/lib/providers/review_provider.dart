import 'package:bella_client_mobile/model/review.dart';
import 'package:bella_client_mobile/providers/base_provider.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() : super('Review');

  @override
  Review fromJson(dynamic json) {
    return Review.fromJson(json as Map<String, dynamic>);
  }
}

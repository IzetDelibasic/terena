import 'package:terena_admin/models/review.dart';
import 'package:terena_admin/providers/base_provider.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() : super("Review");

  @override
  Review fromJson(data) {
    return Review.fromJson(data);
  }
}

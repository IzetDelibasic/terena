import 'package:terena_admin/models/booking.dart';
import 'package:terena_admin/providers/base_provider.dart';

class BookingProvider extends BaseProvider<Booking> {
  BookingProvider() : super("Booking");

  @override
  Booking fromJson(data) {
    return Booking.fromJson(data);
  }
}

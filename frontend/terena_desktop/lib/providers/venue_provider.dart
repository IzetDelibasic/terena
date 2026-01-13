import 'package:terena_admin/models/venue.dart';
import 'package:terena_admin/providers/base_provider.dart';

class VenueProvider extends BaseProvider<Venue> {
  VenueProvider() : super("Venue");

  @override
  Venue fromJson(data) {
    return Venue.fromJson(data);
  }
}

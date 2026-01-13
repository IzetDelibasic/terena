import 'package:terena_admin/models/court.dart';
import 'package:terena_admin/providers/base_provider.dart';

class CourtProvider extends BaseProvider<Court> {
  CourtProvider() : super("Court");

  @override
  Court fromJson(data) {
    return Court.fromJson(data);
  }
}


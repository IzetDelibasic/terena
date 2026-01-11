import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terena_admin/helpers/fullscreen_loader.dart';
import 'package:terena_admin/layouts/master_screen.dart';
import 'package:terena_admin/models/booking.dart';
import 'package:terena_admin/models/search_result.dart';
import 'package:terena_admin/providers/booking_provider.dart';
import 'package:terena_admin/providers/helper_providers/utils.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  late BookingProvider provider;
  late BookingDataSource dataSource;

  bool isLoading = true;
  final TextEditingController bookingNumberController = TextEditingController();

  @override
  void initState() {
    provider = context.read<BookingProvider>();
    dataSource = BookingDataSource(provider: provider, context: context);
    super.initState();
    initForm();
  }

  Future initForm() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      FullScreenLoader(
        isLoading: isLoading,
        isList: true,
        title: "",
        actions: <Widget>[Container()],
        child: Column(children: [_buildSearchForm(), _buildResultView()]),
      ),
      "Bookings",
    );
  }

  Widget _buildSearchForm() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(235, 241, 224, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: bookingNumberController,
                  decoration: const InputDecoration(
                    labelText: "Booking Number",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 50),
                  backgroundColor: const Color.fromRGBO(56, 142, 60, 1),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  dataSource.filterServerSide(bookingNumberController.text);
                },
                child: const Text("Search"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 50),
                  backgroundColor: Colors.grey.shade600,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  bookingNumberController.clear();
                  dataSource.filterServerSide("");
                },
                child: const Text("Clear"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return buildResultView(
      AdvancedPaginatedDataTable(
        showCheckboxColumn: false,
        rowsPerPage: 10,
        columns: const [
          DataColumn(
            label: Text(
              "Booking Number",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          DataColumn(
            label: Text(
              "Venue",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          DataColumn(
            label: Text(
              "User",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          DataColumn(
            label: Text(
              "Date",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          DataColumn(
            label: Text(
              "Time",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          DataColumn(
            label: Text(
              "Total",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          DataColumn(
            label: Text(
              "Status",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
        ],
        source: dataSource,
        addEmptyRows: false,
      ),
    );
  }
}

class BookingDataSource extends AdvancedDataTableSource<Booking> {
  List<Booking>? data = [];
  final BookingProvider provider;
  int count = 10;
  int page = 1;
  int pageSize = 10;
  String _bookingNumber = "";
  BuildContext context;

  BookingDataSource({required this.provider, required this.context});

  @override
  DataRow? getRow(int index) {
    if (index >= data!.length) {
      return null;
    }

    final item = data?[index];
    Color statusColor = Colors.grey;
    String statusText = item?.status ?? "";

    if (statusText == "Pending") {
      statusColor = Colors.orange;
      statusText = "Pending";
    } else if (statusText == "Confirmed") {
      statusColor = Colors.green;
      statusText = "Confirmed";
    } else if (statusText == "Cancelled") {
      statusColor = Colors.red;
      statusText = "Cancelled";
    } else if (statusText == "Completed") {
      statusColor = Colors.blue;
      statusText = "Completed";
    }

    return DataRow(
      cells: [
        DataCell(Text(item?.bookingNumber ?? "")),
        DataCell(Text(item?.venueName ?? "")),
        DataCell(Text(item?.userName ?? "")),
        DataCell(Text(formatDateString(item?.bookingDate?.toIso8601String()))),
        DataCell(
          Text(
            "${item?.startTime?.toLocal().hour.toString().padLeft(2, '0')}:${item?.startTime?.toLocal().minute.toString().padLeft(2, '0')} - ${item?.endTime?.toLocal().hour.toString().padLeft(2, '0')}:${item?.endTime?.toLocal().minute.toString().padLeft(2, '0')}",
          ),
        ),
        DataCell(Text(formatCurrency(item?.totalPrice))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              statusText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  int get selectedRowCount => 0;

  @override
  Future<RemoteDataSourceDetails<Booking>> getNextPage(
    NextPageRequest pageRequest,
  ) async {
    page = (pageRequest.offset ~/ pageSize).toInt() + 1;

    var filter = {
      'BookingNumber': _bookingNumber,
      'Page': page,
      'PageSize': pageSize,
      'OrderBy': 'CreatedAt',
      'SortDirection': 'DESC',
    };

    try {
      var result = await provider.get(filter: filter);
      data = result.result;
      count = result.count ?? 0;
      notifyListeners();
    } on Exception catch (e) {
      if (context.mounted) {
        await buildErrorAlert(context, "Error", e.toString(), e);
      }
    }
    return RemoteDataSourceDetails(count, data!);
  }

  void filterServerSide(String bookingNumber) {
    _bookingNumber = bookingNumber;
    setNextView();
  }
}

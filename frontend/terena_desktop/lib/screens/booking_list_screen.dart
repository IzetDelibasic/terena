import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terena_admin/layouts/master_screen.dart';
import 'package:terena_admin/models/booking.dart';
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
    dataSource.onApprove = _showApproveDialog;
    dataSource.onReject = _showRejectDialog;
    dataSource.onCancel = _showCancelDialog;
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
      Container(
        color: Colors.grey[100],
        child: Column(children: [_buildSearchForm(), _buildResultView()]),
      ),
      "Bookings",
    );
  }

  Widget _buildSearchForm() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: bookingNumberController,
              decoration: InputDecoration(
                labelText: "Booking Number",
                hintText: "Search by booking number",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(140, 50),
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            onPressed: () {
              dataSource.filterServerSide(bookingNumberController.text);
            },
            icon: const Icon(Icons.search, size: 20),
            label: const Text(
              "Search",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 50),
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () {
              bookingNumberController.clear();
              dataSource.filterServerSide("");
            },
            icon: const Icon(Icons.clear, size: 20),
            label: const Text(
              "Clear",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AdvancedPaginatedDataTable(
            showCheckboxColumn: false,
            rowsPerPage: 10,
            columns: [
              DataColumn(
                label: Text(
                  "Booking Number",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Venue",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "User",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Date",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Time",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Total",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Status",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Actions",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            source: dataSource,
            addEmptyRows: false,
          ),
        ),
      ),
    );
  }

  Future<void> _showApproveDialog(Booking booking) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Approve Booking'),
          content: Text(
            'Are you sure you want to approve booking ${booking.bookingNumber}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Approve'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await provider.approveBooking(booking.id!);
                  dataSource.setNextView();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking approved successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRejectDialog(Booking booking) async {
    final TextEditingController reasonController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reject booking ${booking.bookingNumber}?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for rejection',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
              onPressed: () async {
                if (reasonController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a reason for rejection'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop();
                try {
                  await provider.rejectBooking(
                    booking.id!,
                    reasonController.text,
                  );
                  dataSource.setNextView();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking rejected'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCancelDialog(Booking booking) async {
    final TextEditingController reasonController = TextEditingController();
    final TextEditingController refundController = TextEditingController(
      text: booking.totalPrice?.toStringAsFixed(2) ?? '0.00',
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Booking & Refund'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cancel booking ${booking.bookingNumber}?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Venue: ${booking.venueName}'),
                      Text('Date: ${booking.bookingDate}'),
                      Text(
                        'Total Price: ${booking.totalPrice?.toStringAsFixed(2)} BAM',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cancellation Fee: ${(booking.totalPrice ?? 0) * 0.50} BAM (50%)',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for cancellation',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: refundController,
                  decoration: const InputDecoration(
                    labelText: 'Refund Amount (BAM)',
                    border: OutlineInputBorder(),
                    helperText: 'Full amount by default',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel & Refund'),
              onPressed: () async {
                if (reasonController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a reason for cancellation'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final refundAmount = double.tryParse(refundController.text);
                if (refundAmount == null || refundAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid refund amount'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();
                try {
                  await provider.cancelBooking(
                    booking.id!,
                    reasonController.text,
                  );

                  await provider.refundBooking(
                    booking.id!,
                    refundAmount: refundAmount,
                  );

                  dataSource.setNextView();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Booking cancelled and refunded ${refundAmount.toStringAsFixed(2)} BAM',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
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

  void Function(Booking)? onApprove;
  void Function(Booking)? onReject;
  void Function(Booking)? onCancel;

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
    } else if (statusText == "Accepted") {
      statusColor = Colors.lightGreen;
      statusText = "Accepted";
    } else if (statusText == "Confirmed") {
      statusColor = Colors.green;
      statusText = "Confirmed";
    } else if (statusText == "Cancelled") {
      statusColor = Colors.red;
      statusText = "Cancelled";
    } else if (statusText == "Completed") {
      statusColor = Colors.blue;
      statusText = "Completed";
    } else if (statusText == "Expired") {
      statusColor = Colors.grey;
      statusText = "Expired";
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
        DataCell(
          item?.status == "Pending"
              ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    tooltip: 'Approve',
                    onPressed: () {
                      if (onApprove != null && item != null) {
                        onApprove!(item);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    tooltip: 'Reject',
                    onPressed: () {
                      if (onReject != null && item != null) {
                        onReject!(item);
                      }
                    },
                  ),
                ],
              )
              : (item?.status == "Accepted" || item?.status == "Confirmed")
              ? IconButton(
                icon: Icon(Icons.cancel_outlined, color: Colors.orange[700]),
                tooltip: 'Cancel & Refund',
                onPressed: () {
                  if (onCancel != null && item != null) {
                    onCancel!(item);
                  }
                },
              )
              : const Text('-'),
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

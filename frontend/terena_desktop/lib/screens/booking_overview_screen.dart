import 'package:flutter/material.dart';
import 'package:terena_admin/layouts/master_screen.dart';
import 'package:intl/intl.dart';

class BookingOverviewScreen extends StatefulWidget {
  const BookingOverviewScreen({super.key});

  @override
  State<BookingOverviewScreen> createState() => _BookingOverviewScreenState();
}

class _BookingOverviewScreenState extends State<BookingOverviewScreen> {
  bool isLoading = false;
  String? selectedStatus;
  String? selectedVenue;
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> bookings = [
    {
      'id': 'BK001',
      'venueName': 'Arena Sport Center',
      'userName': 'John Doe',
      'date': DateTime(2026, 1, 15),
      'startTime': '14:00',
      'endTime': '16:00',
      'price': 75.0,
      'status': 'Confirmed',
      'venueImage': null,
    },
    {
      'id': 'BK002',
      'venueName': 'City Football Field',
      'userName': 'Jane Smith',
      'date': DateTime(2026, 1, 16),
      'startTime': '10:00',
      'endTime': '12:00',
      'price': 100.0,
      'status': 'Pending',
      'venueImage': null,
    },
    {
      'id': 'BK003',
      'venueName': 'Olympic Tennis Courts',
      'userName': 'Bob Johnson',
      'date': DateTime(2026, 1, 14),
      'startTime': '18:00',
      'endTime': '20:00',
      'price': 60.0,
      'status': 'Completed',
      'venueImage': null,
    },
    {
      'id': 'BK004',
      'venueName': 'Basketball Arena Pro',
      'userName': 'Alice Brown',
      'date': DateTime(2026, 1, 17),
      'startTime': '16:00',
      'endTime': '18:00',
      'price': 80.0,
      'status': 'Confirmed',
      'venueImage': null,
    },
    {
      'id': 'BK005',
      'venueName': 'Green Valley Courts',
      'userName': 'Charlie Davis',
      'date': DateTime(2026, 1, 13),
      'startTime': '12:00',
      'endTime': '14:00',
      'price': 50.0,
      'status': 'Cancelled',
      'venueImage': null,
    },
    {
      'id': 'BK006',
      'venueName': 'Arena Sport Center',
      'userName': 'Eva Martinez',
      'date': DateTime(2026, 1, 18),
      'startTime': '09:00',
      'endTime': '11:00',
      'price': 75.0,
      'status': 'Pending',
      'venueImage': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildHeader(),
            _buildFilters(),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildBookingsGrid(),
            ),
          ],
        ),
      ),
      "Bookings Overview",
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Bookings Overview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'Confirmed', child: Text('Confirmed')),
                DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) {
                setState(() => selectedStatus = value);
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: selectedVenue,
              decoration: InputDecoration(
                labelText: 'Venue',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(
                  value: 'Arena Sport Center',
                  child: Text('Arena Sport Center'),
                ),
                DropdownMenuItem(
                  value: 'City Football Field',
                  child: Text('City Football Field'),
                ),
              ],
              onChanged: (value) {
                setState(() => selectedVenue = value);
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 3,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search bookings...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          OutlinedButton(
            onPressed: () {
              setState(() {
                selectedStatus = null;
                selectedVenue = null;
                searchController.clear();
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsGrid() {
    if (bookings.isEmpty) {
      return const Center(
        child: Text(
          'No bookings to display',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(30),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(bookings[index]);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    Color statusColor;
    switch (booking['status']) {
      case 'Confirmed':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Completed':
        statusColor = Colors.blue;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child:
                  booking['venueImage'] != null
                      ? Image.network(
                        booking['venueImage'],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            width: double.infinity,
                            height: double.infinity,
                            child: const Center(
                              child: Icon(
                                Icons.sports_soccer,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey[300],
                        width: double.infinity,
                        height: double.infinity,
                        child: const Center(
                          child: Icon(
                            Icons.calendar_today,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                      ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['venueName'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              booking['userName'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat('MMM dd, yyyy').format(booking['date']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${booking['startTime']} - ${booking['endTime']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${booking['price'].toStringAsFixed(0)} BAM',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          booking['status'].toString().toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}


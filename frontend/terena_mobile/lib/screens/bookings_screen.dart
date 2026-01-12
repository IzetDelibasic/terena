import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';
import '../providers/auth_provider.dart';

class BookingsScreen extends StatefulWidget {
  final AuthProvider authProvider;

  const BookingsScreen({super.key, required this.authProvider});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _bookingProvider = BookingProvider();
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    final userId = widget.authProvider.currentUser?.id;
    if (userId != null) {
      final bookings = await _bookingProvider.getBookings(userId);
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Booking'),
            content: Text(
              'Are you sure you want to cancel booking for ${booking.venueName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final success = await _bookingProvider.cancelBooking(
      booking.id,
      'Cancelled by user',
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadBookings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel booking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Booking> get _upcomingBookings {
    return _bookings
        .where(
          (b) =>
              b.status == 'Pending' ||
              b.status == 'Confirmed' ||
              b.status == 'PENDING' ||
              b.status == 'CONFIRMED' ||
              b.status == 'ACCEPTED',
        )
        .toList();
  }

  List<Booking> get _historyBookings {
    return _bookings
        .where(
          (b) =>
              b.status == 'Completed' ||
              b.status == 'Cancelled' ||
              b.status == 'COMPLETED' ||
              b.status == 'CANCELLED' ||
              b.status == 'CANCELED' ||
              b.status == 'EXPIRED',
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Reservations'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'History')],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingList(_upcomingBookings, isHistory: false),
                  _buildBookingList(_historyBookings, isHistory: true),
                ],
              ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings, {required bool isHistory}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isHistory ? 'No booking history' : 'No upcoming bookings',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(bookings[index]);
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color statusColor = Colors.green;
    String statusText = booking.status;

    switch (booking.status.toUpperCase()) {
      case 'ACCEPTED':
      case 'CONFIRMED':
        statusColor = Colors.green;
        statusText = 'CONFIRMED';
        break;
      case 'COMPLETED':
        statusColor = Colors.blue;
        statusText = 'COMPLETED';
        break;
      case 'CANCELLED':
      case 'CANCELED':
        statusColor = Colors.red;
        statusText = 'CANCELLED';
        break;
      case 'EXPIRED':
        statusColor = Colors.grey;
        statusText = 'EXPIRED';
        break;
      case 'PENDING':
        statusColor = Colors.orange;
        statusText = 'PENDING';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.sports_soccer,
                    color: Colors.green[700],
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.venueName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (booking.location != null)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                booking.location!,
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
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),

            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM yyyy').format(booking.date),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.timeSlot,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            if (booking.courtName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.sports_tennis, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Court: ${booking.courtName}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],

            if (booking.discountPercentage != null &&
                booking.discountPercentage! > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_offer,
                      size: 14,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${booking.discountPercentage!.toStringAsFixed(0)}% Discount Applied',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 24, thickness: 1),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking #',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                    Text(
                      booking.bookingNumber,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${booking.totalAmount.toStringAsFixed(2)} BAM',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (booking.status.toUpperCase() == 'PENDING') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _cancelBooking(booking),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancel Booking',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

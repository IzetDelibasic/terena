import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:terena_admin/layouts/master_screen.dart';
import 'package:terena_admin/providers/statistics_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedPeriod = 'This Month';
  final StatisticsProvider _statsProvider = StatisticsProvider();

  bool _isLoading = true;
  Map<String, dynamic> _earningsData = {};
  Map<String, dynamic> _bookingStatusData = {};
  Map<String, dynamic> _topVenuesData = {};
  int _activeVenues = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final dateRange = _getDateRange();

      final results = await Future.wait([
        _statsProvider.getEarnings(
          fromDate: dateRange['fromDate'],
          toDate: dateRange['toDate'],
        ),
        _statsProvider.getBookingStatus(
          fromDate: dateRange['fromDate'],
          toDate: dateRange['toDate'],
        ),
        _statsProvider.getTopVenues(count: 5),
        _statsProvider.getActiveVenues(),
      ]);

      setState(() {
        _earningsData = results[0] as Map<String, dynamic>;
        _bookingStatusData = results[1] as Map<String, dynamic>;
        _topVenuesData = results[2] as Map<String, dynamic>;
        _activeVenues = results[3] as int;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading statistics: $e')));
      }
    }
  }

  Map<String, DateTime?> _getDateRange() {
    final now = DateTime.now();
    DateTime? fromDate;

    switch (selectedPeriod) {
      case 'Today':
        fromDate = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        fromDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        fromDate = DateTime(now.year, now.month, 1);
        break;
      case 'This Year':
        fromDate = DateTime(now.year, 1, 1);
        break;
    }

    return {'fromDate': fromDate, 'toDate': now};
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatsCards(),
                            const SizedBox(height: 30),
                            _buildChartsSection(),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
      "Statistics",
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Statistics Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: selectedPeriod,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'Today', child: Text('Today')),
                DropdownMenuItem(value: 'This Week', child: Text('This Week')),
                DropdownMenuItem(
                  value: 'This Month',
                  child: Text('This Month'),
                ),
                DropdownMenuItem(value: 'This Year', child: Text('This Year')),
              ],
              onChanged: (value) {
                setState(() => selectedPeriod = value!);
                _loadStatistics();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalBookings = _earningsData['totalBookings'] ?? 0;
    final totalEarnings = _earningsData['totalEarnings'] ?? 0.0;
    final completedBookings = _earningsData['completedBookings'] ?? 0;
    final bookingsChangePercent = _earningsData['bookingsChangePercent'] ?? 0.0;
    final earningsChangePercent = _earningsData['earningsChangePercent'] ?? 0.0;

    final currencyFormat = NumberFormat.currency(
      symbol: 'BAM ',
      decimalDigits: 2,
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Bookings',
            totalBookings.toString(),
            Icons.calendar_today,
            Colors.blue,
            '${bookingsChangePercent >= 0 ? "+" : ""}${bookingsChangePercent.toStringAsFixed(1)}% from last period',
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            'Total Revenue',
            currencyFormat.format(totalEarnings),
            Icons.attach_money,
            Colors.green,
            '${earningsChangePercent >= 0 ? "+" : ""}${earningsChangePercent.toStringAsFixed(1)}% from last period',
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            'Completed Bookings',
            completedBookings.toString(),
            Icons.check_circle,
            Colors.orange,
            'Successfully finished',
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            'Active Venues',
            _activeVenues.toString(),
            Icons.stadium,
            Colors.purple,
            'Venues available',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 40, color: color),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.trending_up, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildBookingStatusChart()),
        const SizedBox(width: 20),
        Expanded(flex: 1, child: _buildTopVenues()),
      ],
    );
  }

  Widget _buildBookingStatusChart() {
    final completed = _bookingStatusData['completed'] ?? 0;
    final accepted = _bookingStatusData['accepted'] ?? 0;
    final pending = _bookingStatusData['pending'] ?? 0;
    final cancelled = _bookingStatusData['cancelled'] ?? 0;

    final total = completed + accepted + pending + cancelled;
    final maxValue = [
      completed,
      accepted,
      pending,
      cancelled,
    ].reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Status Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            total == 0
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text(
                      'No booking data available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusColumn(
                      'Completed',
                      completed,
                      Colors.green,
                      maxValue > 0 ? completed / maxValue : 0,
                    ),
                    _buildStatusColumn(
                      'Accepted',
                      accepted,
                      Colors.blue,
                      maxValue > 0 ? accepted / maxValue : 0,
                    ),
                    _buildStatusColumn(
                      'Pending',
                      pending,
                      Colors.orange,
                      maxValue > 0 ? pending / maxValue : 0,
                    ),
                    _buildStatusColumn(
                      'Cancelled',
                      cancelled,
                      Colors.red,
                      maxValue > 0 ? cancelled / maxValue : 0,
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusColumn(
    String label,
    int count,
    Color color,
    double heightFactor,
  ) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 60,
          height: 200 * heightFactor,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTopVenues() {
    final venues = _topVenuesData['venues'] as List? ?? [];
    final currencyFormat = NumberFormat.currency(
      symbol: 'BAM ',
      decimalDigits: 2,
    );

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Venues',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            if (venues.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text(
                    'No venue data available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...venues.asMap().entries.map((entry) {
                final index = entry.key;
                final venue = entry.value as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color:
                              index < 3
                                  ? const Color.fromRGBO(32, 76, 56, 1)
                                  : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: index < 3 ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              venue['venueName'] as String? ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${venue['totalBookings'] ?? 0} bookings',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        currencyFormat.format(venue['totalEarnings'] ?? 0),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

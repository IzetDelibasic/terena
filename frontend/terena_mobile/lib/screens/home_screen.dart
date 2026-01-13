import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/venue.dart';
import '../models/booking.dart';
import '../providers/venue_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/auth_provider.dart';
import 'venue_details_screen.dart';
import 'all_venues_screen.dart';

class HomeScreen extends StatefulWidget {
  final AuthProvider authProvider;

  const HomeScreen({super.key, required this.authProvider});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _venueProvider = VenueProvider();
  final _bookingProvider = BookingProvider();
  List<Venue> _venues = [];
  List<Venue> _recommendedVenues = [];
  List<Booking> _upcomingBookings = [];
  bool _isLoading = true;
  String? _selectedSport;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _sports = [
    {'name': 'Football', 'icon': Icons.sports_soccer},
    {'name': 'Basketball', 'icon': Icons.sports_basketball},
    {'name': 'Tennis', 'icon': Icons.sports_tennis},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final venues = await _venueProvider.getVenues();
      final bookings = await _bookingProvider.getBookings(
        widget.authProvider.currentUser!.id,
      );

      final recommended = List<Venue>.from(venues);

      final bookedVenueIds = bookings.map((b) => b.venueId).toSet();

      recommended.sort((a, b) {
        final aBooked = bookedVenueIds.contains(a.id) ? 1 : 0;
        final bBooked = bookedVenueIds.contains(b.id) ? 1 : 0;
        if (aBooked != bBooked) return bBooked.compareTo(aBooked);

        final ratingA = a.rating ?? 0;
        final ratingB = b.rating ?? 0;
        return ratingB.compareTo(ratingA);
      });

      setState(() {
        _venues = venues;
        _recommendedVenues = recommended.take(3).toList();
        _upcomingBookings =
            bookings
                .where((b) => b.status == 'CONFIRMED' || b.status == 'PENDING')
                .take(2)
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Venue> get _filteredVenues {
    var filtered = _venues;

    if (_selectedSport != null) {
      filtered = filtered.where((v) => v.sportType == _selectedSport).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((v) {
            return v.name.toLowerCase().contains(_searchQuery) ||
                (v.location?.toLowerCase().contains(_searchQuery) ?? false) ||
                (v.sportType?.toLowerCase().contains(_searchQuery) ?? false);
          }).toList();
    }

    filtered.sort((a, b) {
      final ratingA = a.rating ?? 0;
      final ratingB = b.rating ?? 0;
      return ratingB.compareTo(ratingA);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Find your perfect venue!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              TextField(
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value.toLowerCase();
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search venues or sports...',
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _sports.length,
                            itemBuilder: (context, index) {
                              final sport = _sports[index];
                              final isSelected =
                                  _selectedSport == sport['name'];

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Row(
                                    children: [
                                      Icon(
                                        sport['icon'],
                                        size: 18,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.green[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(sport['name']),
                                    ],
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedSport =
                                          selected ? sport['name'] : null;
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: Colors.green[700],
                                  labelStyle: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.green[700],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        if (_upcomingBookings.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Upcoming Bookings',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('See all'),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: _upcomingBookings.length,
                              itemBuilder: (context, index) {
                                return _buildBookingCard(
                                  _upcomingBookings[index],
                                );
                              },
                            ),
                          ),
                        ],

                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recommended For You',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AllVenuesScreen(
                                            authProvider: widget.authProvider,
                                          ),
                                    ),
                                  );
                                },
                                child: const Text('See all'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 240,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _recommendedVenues.length,
                            itemBuilder: (context, index) {
                              return _buildRecommendedCard(
                                _recommendedVenues[index],
                              );
                            },
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Top Rated Venues',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AllVenuesScreen(
                                            authProvider: widget.authProvider,
                                          ),
                                    ),
                                  );
                                },
                                child: const Text('See all'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _filteredVenues.take(5).length,
                            itemBuilder: (context, index) {
                              return _buildVenueCard(_filteredVenues[index]);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color statusColor = Colors.green;
    if (booking.status == 'PENDING') statusColor = Colors.orange;

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.sports_soccer, color: Colors.grey[400]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  booking.venueName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        booking.location ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.date.day}.${booking.date.month}.${booking.date.year} • ${booking.timeSlot}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.totalAmount.toStringAsFixed(2)} BAM',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              booking.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(Venue venue) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => VenueDetailsScreen(
                  venue: venue,
                  authProvider: widget.authProvider,
                ),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        venue.imageUrl != null && venue.imageUrl!.isNotEmpty
                            ? _buildVenueImage(venue.imageUrl!, 120)
                            : Center(
                              child: Icon(
                                Icons.sports_soccer,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                            ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              venue.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    venue.location ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                if (venue.rating != null && venue.rating! > 0) ...[
                  Text(
                    venue.rating!.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (venue.reviewCount != null && venue.reviewCount! > 0) ...[
                    const SizedBox(width: 2),
                    Text(
                      '(${venue.reviewCount})',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ] else ...[
                  const Text('New', style: TextStyle(fontSize: 12)),
                ],
                const Spacer(),
                Text(
                  '${venue.pricePerHour?.toStringAsFixed(0)} BAM/h',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueCard(Venue venue) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => VenueDetailsScreen(
                  venue: venue,
                  authProvider: widget.authProvider,
                ),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child:
                        venue.imageUrl != null && venue.imageUrl!.isNotEmpty
                            ? _buildVenueImage(venue.imageUrl!, 120)
                            : Center(
                              child: Icon(
                                Icons.sports_soccer,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                            ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, size: 18),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venue.location ?? '',
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      if (venue.rating != null && venue.rating! > 0) ...[
                        Text(
                          venue.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (venue.reviewCount != null &&
                            venue.reviewCount! > 0) ...[
                          const SizedBox(width: 2),
                          Text(
                            '(${venue.reviewCount})',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ] else ...[
                        const Text('New', style: TextStyle(fontSize: 12)),
                      ],
                      const Spacer(),
                      Text(
                        '${venue.pricePerHour?.toStringAsFixed(0)} BAM/h',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueImage(String imageUrl, double height) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        width: double.infinity,
        height: height,
        child: Center(
          child: Icon(Icons.sports_soccer, size: 50, color: Colors.grey[400]),
        ),
      );
    }

    try {
      if (imageUrl.startsWith('data:image')) {
        final base64Data = imageUrl.split(',')[1];
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              width: double.infinity,
              height: height,
              child: Center(
                child: Icon(
                  Icons.sports_soccer,
                  size: 50,
                  color: Colors.grey[400],
                ),
              ),
            );
          },
        );
      } else {
        return Image.network(
          imageUrl,
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              width: double.infinity,
              height: height,
              child: Center(
                child: Icon(
                  Icons.sports_soccer,
                  size: 50,
                  color: Colors.grey[400],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      return Container(
        color: Colors.grey[300],
        width: double.infinity,
        height: height,
        child: Center(
          child: Icon(Icons.sports_soccer, size: 50, color: Colors.grey[400]),
        ),
      );
    }
  }
}

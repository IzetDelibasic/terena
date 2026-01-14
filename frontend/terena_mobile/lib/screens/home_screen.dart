import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/venue.dart';
import '../models/booking.dart';
import '../providers/venue_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/auth_provider.dart';
import 'venue_details_screen.dart';
import 'all_venues_screen.dart';

class HomeScreen extends StatefulWidget {
  final AuthProvider authProvider;

  const HomeScreen({
    super.key,
    required this.authProvider,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _venueProvider = VenueProvider();
  final _bookingProvider = BookingProvider();
  final _recommendationProvider = RecommendationProvider();
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

      final recommended = await _recommendationProvider.getRecommendations(
        widget.authProvider.currentUser!.id,
        count: 6,
      );

      setState(() {
        _venues = venues;
        _recommendedVenues =
            recommended.isNotEmpty ? recommended : venues.take(6).toList();
        _upcomingBookings =
            bookings
                .where((b) => b.status == 'CONFIRMED' || b.status == 'PENDING')
                .take(2)
                .toList();
        _isLoading = false;
      });
    } catch (e) {
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
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'Upcoming Bookings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: _upcomingBookings.take(3).length,
                              itemBuilder: (context, index) {
                                return _buildBookingCard(
                                  _upcomingBookings.take(3).toList()[index],
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
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _filteredVenues.take(3).length,
                            itemBuilder: (context, index) {
                              return _buildVenueCard(
                                _filteredVenues.take(3).toList()[index],
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
                            itemCount: _recommendedVenues.take(3).length,
                            itemBuilder: (context, index) {
                              return _buildRecommendedCard(
                                _recommendedVenues.take(3).toList()[index],
                              );
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
      width: 280,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  booking.venueName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 8),
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
              const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${booking.date.day}.${booking.date.month}.${booking.date.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.access_time, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                booking.timeSlot,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${booking.totalAmount.toStringAsFixed(2)} BAM',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.green[700],
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
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                    top: Radius.circular(16),
                  ),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    child:
                        venue.imageUrl != null && venue.imageUrl!.isNotEmpty
                            ? _buildVenueImage(venue.imageUrl!, 140)
                            : Center(
                              child: Icon(
                                Icons.sports_soccer,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                if (venue.rating != null && venue.rating! >= 4.5)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            venue.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
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
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (venue.rating != null && venue.rating! > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              venue.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
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
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'New',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Text(
                        '${venue.pricePerHour?.toStringAsFixed(0)} BAM/h',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green[700],
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                    top: Radius.circular(16),
                  ),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[300]),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(40),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Top Rated',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          if (venue.rating != null && venue.rating! > 0) ...[
                            Text(
                              venue.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ] else ...[
                            const Text('New', style: TextStyle(fontSize: 12)),
                          ],
                        ],
                      ),
                      Text(
                        '${venue.pricePerHour?.toStringAsFixed(0)} BAM/h',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.green[700],
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

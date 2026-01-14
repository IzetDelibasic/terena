import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/venue.dart';
import '../providers/venue_provider.dart';
import '../providers/auth_provider.dart';
import 'venue_details_screen.dart';

class AllVenuesScreen extends StatefulWidget {
  final AuthProvider authProvider;

  const AllVenuesScreen({super.key, required this.authProvider});

  @override
  State<AllVenuesScreen> createState() => _AllVenuesScreenState();
}

class _AllVenuesScreenState extends State<AllVenuesScreen> {
  final VenueProvider _venueProvider = VenueProvider();
  List<Venue> _venues = [];
  List<Venue> _filteredVenues = [];
  bool _isLoading = true;
  String? _selectedSport;

  final List<String> _sports = ['Football', 'Basketball', 'Tennis'];

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final venues = await _venueProvider.getVenues();
      setState(() {
        _venues = venues;
        _filteredVenues = venues;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterVenues(String? sportType) {
    setState(() {
      _selectedSport = sportType;
      if (sportType == null) {
        _filteredVenues = _venues;
      } else {
        _filteredVenues =
            _venues.where((v) => v.sportType == sportType).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Venues',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
              )
              : Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _buildFilterChip('All', _selectedSport == null),
                          const SizedBox(width: 8),
                          ..._sports.map(
                            (sport) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildFilterChip(
                                sport,
                                _selectedSport == sport,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child:
                        _filteredVenues.isEmpty
                            ? Center(
                              child: Text(
                                'No venues found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            )
                            : GridView.builder(
                              padding: const EdgeInsets.all(20),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.75,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: _filteredVenues.length,
                              itemBuilder: (context, index) {
                                return _buildVenueCard(_filteredVenues[index]);
                              },
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (label == 'All') {
          _filterVenues(null);
        } else {
          _filterVenues(label);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              _getSportIcon(label),
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport) {
      case 'Football':
        return Icons.sports_soccer;
      case 'Basketball':
        return Icons.sports_basketball;
      case 'Tennis':
        return Icons.sports_tennis;
      default:
        return Icons.sports;
    }
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
                    height: 105,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child:
                        venue.imageUrl != null && venue.imageUrl!.isNotEmpty
                            ? _buildVenueImage(venue.imageUrl!, 105)
                            : Center(
                              child: Icon(
                                _getSportIcon(venue.sportType ?? ''),
                                size: 42,
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
                    child: const Icon(Icons.favorite_border, size: 16),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 5, 6, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 11,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          venue.location ?? '',
                          style: TextStyle(
                            fontSize: 11,
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
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      if (venue.rating != null && venue.rating! > 0) ...[
                        Text(
                          venue.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (venue.reviewCount != null &&
                            venue.reviewCount! > 0) ...[
                          Text(
                            ' (${venue.reviewCount})',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ] else ...[
                        const Text('New', style: TextStyle(fontSize: 10)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${venue.pricePerHour?.toStringAsFixed(0)} BAM/h',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF4CAF50),
                    ),
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
          child: Icon(Icons.sports_soccer, size: 42, color: Colors.grey[400]),
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
                  size: 42,
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
                  size: 42,
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
          child: Icon(Icons.sports_soccer, size: 42, color: Colors.grey[400]),
        ),
      );
    }
  }
}

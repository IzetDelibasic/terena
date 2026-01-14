import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terena_admin/models/search_result.dart';
import 'package:terena_admin/models/venue.dart';
import 'package:terena_admin/providers/venue_provider.dart';
import 'package:terena_admin/screens/venue_add_screen.dart';
import 'package:terena_admin/screens/venue_details_screen.dart';
import 'package:terena_admin/layouts/master_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VenueProvider venueProvider;
  SearchResult<Venue>? venuesResult;
  final TextEditingController searchController = TextEditingController();

  String? selectedLocation;
  String? selectedSport;
  String? selectedSurface;

  @override
  void initState() {
    super.initState();
    venueProvider = context.read<VenueProvider>();
    loadVenues();
  }

  void loadVenues() async {
    try {
      Map<String, dynamic> searchObj = {};

      if (searchController.text.isNotEmpty) {
        searchObj['searchTerm'] = searchController.text;
      }

      if (selectedLocation != null) {
        searchObj['location'] = selectedLocation;
      }

      if (selectedSport != null) {
        searchObj['sportType'] = selectedSport;
      }

      if (selectedSurface != null) {
        searchObj['surfaceType'] = selectedSurface;
      }

      var result = await venueProvider.get(filter: searchObj);

      setState(() {
        venuesResult = result;
      });
    } catch (e) {
      print('Error loading venues: $e');
    }
  }

  void clearFilters() {
    setState(() {
      selectedLocation = null;
      selectedSport = null;
      selectedSurface = null;
      searchController.clear();
    });
    loadVenues();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildFilters(),
                  const SizedBox(height: 20),
                  Expanded(child: _buildVenueGrid()),
                ],
              ),
            ),
          ],
        ),
      ),
      'Venues',
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Venues',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VenueAddScreen()),
              );
              if (result == true) {
                loadVenues();
              }
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 20),
            label: const Text(
              'ADD NEW VENUE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(30),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Location',
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
              value: selectedLocation,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Locations'),
                ),
                const DropdownMenuItem(
                  value: 'Sarajevo',
                  child: Text('Sarajevo'),
                ),
                const DropdownMenuItem(value: 'Mostar', child: Text('Mostar')),
                const DropdownMenuItem(
                  value: 'Banja Luka',
                  child: Text('Banja Luka'),
                ),
                const DropdownMenuItem(value: 'Neum', child: Text('Neum')),
              ],
              onChanged: (value) {
                setState(() => selectedLocation = value);
                loadVenues();
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Sport Type',
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
              value: selectedSport,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Sports')),
                const DropdownMenuItem(value: 'Tennis', child: Text('Tennis')),
                const DropdownMenuItem(
                  value: 'Basketball',
                  child: Text('Basketball'),
                ),
                const DropdownMenuItem(
                  value: 'Football',
                  child: Text('Football'),
                ),
              ],
              onChanged: (value) {
                setState(() => selectedSport = value);
                loadVenues();
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Surface Type',
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
              value: selectedSurface,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Surfaces'),
                ),
                const DropdownMenuItem(value: 'Grass', child: Text('Grass')),
                const DropdownMenuItem(value: 'Clay', child: Text('Clay')),
                const DropdownMenuItem(
                  value: 'Hardwood',
                  child: Text('Hardwood'),
                ),
              ],
              onChanged: (value) {
                setState(() => selectedSurface = value);
                loadVenues();
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 3,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search venues...',
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
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
              onSubmitted: (_) => loadVenues(),
            ),
          ),
          const SizedBox(width: 15),
          OutlinedButton(
            onPressed: clearFilters,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: Colors.grey[400]!),
            ),
            child: Text('CLEAR', style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueGrid() {
    final venues = venuesResult?.result;
    if (venues == null || venues.isEmpty) {
      return const Center(
        child: Text(
          'No venues to display',
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
      itemCount: venues.length,
      itemBuilder: (context, index) {
        return _buildVenueCard(venues[index]);
      },
    );
  }

  Widget _buildVenueCard(Venue venue) {
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
                  (venue.venueImageUrl != null &&
                          venue.venueImageUrl!.isNotEmpty)
                      ? _buildVenueImage(venue.venueImageUrl!)
                      : Container(
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
                        venue.name ?? '',
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
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  (venue.availableSlots ?? 0) > 0
                                      ? Colors.green
                                      : Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${venue.availableSlots ?? 0} slots available',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.sports_soccer,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${venue.sportType} | ${venue.surfaceType}',
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
                                  '${venue.pricePerHour?.toStringAsFixed(0)} BAM',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextSpan(
                              text: ' / hour',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => VenueDetailsScreen(venue: venue),
                            ),
                          );
                          if (result == true) {
                            loadVenues();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(32, 76, 56, 1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          minimumSize: const Size(120, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'EDIT DETAILS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
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

  Widget _buildVenueImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        width: double.infinity,
        height: double.infinity,
        child: const Center(
          child: Icon(Icons.sports_soccer, size: 100, color: Colors.grey),
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
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: Icon(Icons.sports_soccer, size: 100, color: Colors.grey),
              ),
            );
          },
        );
      } else {
        return Image.network(
          imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: Icon(Icons.sports_soccer, size: 100, color: Colors.grey),
              ),
            );
          },
        );
      }
    } catch (e) {
      return Container(
        color: Colors.grey[300],
        width: double.infinity,
        height: double.infinity,
        child: const Center(
          child: Icon(Icons.sports_soccer, size: 100, color: Colors.grey),
        ),
      );
    }
  }
}

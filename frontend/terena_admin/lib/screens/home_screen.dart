import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:terena_admin/layouts/master_screen.dart';
import 'package:terena_admin/models/venue.dart';
import 'package:terena_admin/models/search_result.dart';
import 'package:terena_admin/providers/venue_provider.dart';
import 'package:terena_admin/screens/venue_add_screen_new.dart';
import 'package:terena_admin/screens/venue_details_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VenueProvider venueProvider;
  SearchResult<Venue>? venuesResult;
  bool isLoading = true;

  String? selectedSportType;
  String? selectedLocation;
  String? selectedSurface;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    venueProvider = context.read<VenueProvider>();
    loadVenues();
  }

  Future<void> loadVenues() async {
    setState(() => isLoading = true);

    try {
      var filter = <String, dynamic>{'Page': 1, 'PageSize': 50};

      if (selectedSportType != null && selectedSportType!.isNotEmpty) {
        filter['SportType'] = selectedSportType;
      }
      if (selectedLocation != null && selectedLocation!.isNotEmpty) {
        filter['Location'] = selectedLocation;
      }
      if (selectedSurface != null && selectedSurface!.isNotEmpty) {
        filter['SurfaceType'] = selectedSurface;
      }
      if (searchController.text.isNotEmpty) {
        filter['SearchTerm'] = searchController.text;
      }

      venuesResult = await venueProvider.get(filter: filter);
    } catch (e) {
    } finally {
      setState(() => isLoading = false);
    }
  }

  void clearFilters() {
    setState(() {
      selectedSportType = null;
      selectedLocation = null;
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
            _buildHeader(),
            _buildFilters(),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildVenueGrid(),
            ),
          ],
        ),
      ),
      "Court & Field Management",
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Court & Field Management',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VenueAddScreenNew(),
                ),
              );
              if (result == true) {
                loadVenues();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(32, 76, 56, 1),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'ADD NEW',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
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
              value: selectedSportType,
              decoration: InputDecoration(
                labelText: 'Sport Type',
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
                DropdownMenuItem(value: 'Football', child: Text('Football')),
                DropdownMenuItem(
                  value: 'Basketball',
                  child: Text('Basketball'),
                ),
                DropdownMenuItem(value: 'Tennis', child: Text('Tennis')),
                DropdownMenuItem(
                  value: 'Volleyball',
                  child: Text('Volleyball'),
                ),
              ],
              onChanged: (value) {
                setState(() => selectedSportType = value);
                loadVenues();
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: selectedLocation,
              decoration: InputDecoration(
                labelText: 'Location',
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
                DropdownMenuItem(value: 'Sarajevo', child: Text('Sarajevo')),
                DropdownMenuItem(value: 'Mostar', child: Text('Mostar')),
                DropdownMenuItem(
                  value: 'Banja Luka',
                  child: Text('Banja Luka'),
                ),
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
              value: selectedSurface,
              decoration: InputDecoration(
                labelText: 'Surface',
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
                DropdownMenuItem(value: 'Grass', child: Text('Grass')),
                DropdownMenuItem(
                  value: 'Artificial Turf',
                  child: Text('Artificial Turf'),
                ),
                DropdownMenuItem(value: 'Hardwood', child: Text('Hardwood')),
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
                ),
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
            ),
            child: const Text('CLEAR'),
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
        return Container(
          color: Colors.grey[300],
          width: double.infinity,
          height: double.infinity,
          child: const Center(
            child: Icon(Icons.sports_soccer, size: 100, color: Colors.grey),
          ),
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

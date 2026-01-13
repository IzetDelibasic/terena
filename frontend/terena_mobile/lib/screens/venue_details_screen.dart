import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../models/venue.dart';
import '../models/review.dart';
import '../providers/favorite_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/review_provider.dart';

class VenueDetailsScreen extends StatefulWidget {
  final Venue venue;
  final AuthProvider authProvider;

  const VenueDetailsScreen({
    super.key,
    required this.venue,
    required this.authProvider,
  });

  @override
  State<VenueDetailsScreen> createState() => _VenueDetailsScreenState();
}

class _VenueDetailsScreenState extends State<VenueDetailsScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  int _duration = 3;
  bool _isFavorite = false;
  bool _isCheckingFavorite = true;
  final _bookingProvider = BookingProvider();
  final _reviewProvider = ReviewProvider();
  List<String> _availableSlots = [];
  bool _isLoadingSlots = false;
  String? _selectedTimeSlot;
  List<Review> _reviews = [];
  bool _isLoadingReviews = false;

  double get _averageRating {
    if (_reviews.isEmpty) return widget.venue.rating ?? 0.0;
    final sum = _reviews.fold<int>(0, (prev, review) => prev + review.rating);
    return sum / _reviews.length;
  }

  int get _reviewCount {
    return _reviews.isEmpty ? (widget.venue.reviewCount ?? 0) : _reviews.length;
  }

  double get _totalPrice {
    return (widget.venue.pricePerHour ?? 0) * _duration;
  }

  double get _discount {
    final discountData = widget.venue.discount;
    if (discountData != null && discountData.percentage != null) {
      // Discount applies for bookings of 3+ hours
      if (_duration >= 3) {
        return _totalPrice * (discountData.percentage! / 100);
      }
    }
    return 0.0;
  }

  double get _finalPrice {
    return _totalPrice - _discount;
  }

  double get _cancellationFee {
    final cancellationData = widget.venue.cancellationPolicy;
    if (cancellationData != null && cancellationData.fee != null) {
      return _finalPrice * (cancellationData.fee! / 100);
    }
    return _finalPrice * 0.50;
  }

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _loadAvailableSlots();
    _loadReviews();
  }

  Future<void> _loadAvailableSlots() async {
    setState(() {
      _isLoadingSlots = true;
    });

    final slots = await _bookingProvider.getAvailableTimeSlots(
      widget.venue.id,
      _selectedDate,
    );

    setState(() {
      _availableSlots = slots;
      _isLoadingSlots = false;
      if (_availableSlots.isNotEmpty && _selectedTimeSlot == null) {
        _selectedTimeSlot = _availableSlots.first;
        final parts = _selectedTimeSlot!.split(':');
        _selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    });
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    final reviews = await _reviewProvider.getReviews(venueId: widget.venue.id);

    setState(() {
      _reviews = reviews;
      _isLoadingReviews = false;
    });
  }

  Future<void> _showReviewDialog() async {
    double rating = 5.0;
    final commentController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Leave a Review'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Rate your experience'),
                const SizedBox(height: 16),
                RatingBar.builder(
                  initialRating: 5,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder:
                      (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (value) {
                    rating = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: 'Write your review (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
    );

    if (result == true) {
      final userId = widget.authProvider.currentUser?.id;
      if (userId != null) {
        final success = await _reviewProvider.createReview(
          userId: userId,
          venueId: widget.venue.id,
          rating: rating.toInt(),
          comment:
              commentController.text.isEmpty ? null : commentController.text,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadReviews();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit review'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _checkIfFavorite() async {
    final userId = widget.authProvider.currentUser?.id;

    if (userId != null) {
      final favoriteProvider = Provider.of<FavoriteProvider>(
        context,
        listen: false,
      );
      final isFav = await favoriteProvider.isFavorite(userId, widget.venue.id);
      setState(() {
        _isFavorite = isFav;
        _isCheckingFavorite = false;
      });
    } else {
      setState(() {
        _isCheckingFavorite = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final userId = widget.authProvider.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add favorites'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );
    bool success;
    if (_isFavorite) {
      success = await favoriteProvider.removeFavorite(userId, widget.venue.id);
    } else {
      success = await favoriteProvider.addFavorite(userId, widget.venue.id);
    }

    if (success) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite
                ? '${widget.venue.name} added to favorites'
                : '${widget.venue.name} removed from favorites',
          ),
          backgroundColor: _isFavorite ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.green[700],
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              _isCheckingFavorite
                  ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                  : IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.black,
                      ),
                    ),
                    onPressed: _toggleFavorite,
                  ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background:
                  widget.venue.imageUrl != null &&
                          widget.venue.imageUrl!.isNotEmpty
                      ? _buildVenueImage(widget.venue.imageUrl!, 300)
                      : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.sports_soccer,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                      ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.venue.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${widget.venue.address}, ${widget.venue.location}',
                          style: TextStyle(
                            fontSize: 14,
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
                    children: [
                      const Icon(Icons.star, size: 20, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        _averageRating > 0
                            ? _averageRating.toStringAsFixed(1)
                            : 'No rating yet',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _reviewCount > 0 ? '($_reviewCount reviews)' : '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Price per hour',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${widget.venue.pricePerHour?.toStringAsFixed(2)} BAM',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_offer,
                          color: Colors.orange[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '10% discount if you book 3+ hours',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      const Text(
                        'Sport Type:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.sports_soccer,
                              size: 18,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.venue.sportType ?? 'Football',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard('Surface:', 'Artificial Turf'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInfoCard('Capacity:', '5v5 / 7v7')),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildInfoCard('Available Slots:', '18 slots today'),

                  const SizedBox(height: 24),

                  if (widget.venue.discount != null &&
                      widget.venue.discount!.percentage != null &&
                      widget.venue.discount!.percentage! > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.discount,
                            color: Colors.green[700],
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${widget.venue.discount!.percentage!.toStringAsFixed(0)}% discount if you book 3+ hours',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.event_busy, color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Cancellation Policy',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildBulletPoint(
                          'Free cancellation until 24 hours before booking',
                        ),
                        _buildBulletPoint(
                          widget.venue.cancellationPolicy != null &&
                                  widget.venue.cancellationPolicy!.fee != null
                              ? '${widget.venue.cancellationPolicy!.fee!.toStringAsFixed(0)}% cancellation fee applies after deadline'
                              : '50% cancellation fee applies after deadline',
                        ),
                        _buildBulletPoint(
                          'Refund processed within 3-5 business days',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Amenities',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (widget.venue.hasParking)
                        _buildAmenityChip('Free Parking', Icons.local_parking),
                      if (widget.venue.hasShowers)
                        _buildAmenityChip('Showers', Icons.shower),
                      if (widget.venue.hasChangingRooms)
                        _buildAmenityChip('Changing Rooms', Icons.checkroom),
                      if (widget.venue.hasLighting)
                        _buildAmenityChip('Night Lighting', Icons.lightbulb),
                      if (widget.venue.hasEquipmentRental)
                        _buildAmenityChip(
                          'Equipment Rental',
                          Icons.sports_soccer,
                        ),
                      if (widget.venue.hasCafeBar)
                        _buildAmenityChip('Cafe/Bar', Icons.local_cafe),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showReviewDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Write Review'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isLoadingReviews
                      ? const Center(child: CircularProgressIndicator())
                      : _reviews.isEmpty
                      ? Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'No reviews yet. Be the first to review!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                      : Column(
                        children:
                            _reviews.take(3).map((review) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.green[100],
                                          child: Text(
                                            review.userUsername
                                                    ?.substring(0, 1)
                                                    .toUpperCase() ??
                                                'U',
                                            style: TextStyle(
                                              color: Colors.green[700],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                review.userUsername ??
                                                    'Anonymous',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: List.generate(
                                                  5,
                                                  (index) => Icon(
                                                    index < review.rating
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    size: 16,
                                                    color: Colors.amber,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (review.createdAt != null)
                                          Text(
                                            _formatDate(review.createdAt!),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (review.comment != null &&
                                        review.comment!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        review.comment!,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                  if (_reviews.length > 3) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View all reviews'),
                    ),
                  ],

                  const SizedBox(height: 32),

                  const Text(
                    'Select Date & Time',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),


                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 90),
                              ),
                            );
                            if (date != null) {
                              setState(() {
                                _selectedDate = date;
                                _selectedTimeSlot = null;
                              });
                              _loadAvailableSlots();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                              
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.green[700],
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.green[700]),
                              const SizedBox(width: 12),
                              Text(
                                _selectedTimeSlot ?? '--:--',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (_isLoadingSlots)
                    const Center(child: CircularProgressIndicator())
                  else if (_availableSlots.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red[700]),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'No available time slots for this date',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    const Text(
                      'Available Time Slots',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _availableSlots.map((slot) {
                            final isSelected = _selectedTimeSlot == slot;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedTimeSlot = slot;
                                  final parts = slot.split(':');
                                  _selectedTime = TimeOfDay(
                                    hour: int.parse(parts[0]),
                                    minute: int.parse(parts[1]),
                                  );
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.green[700]
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? Colors.green[700]!
                                            : Colors.grey[300]!,
                                  ),
                                ),
                                child: Text(
                                  slot,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],

                  const SizedBox(height: 24),

                  const Text(
                    'Duration (hours)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: (_duration > 1
                                ? () => setState(() => _duration--)
                                : null),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                _duration > 1
                                    ? Colors.green[700]
                                    : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.remove, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        '$_duration',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _duration++;
                          });
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Price ($_duration hours × ${widget.venue.pricePerHour?.toStringAsFixed(0)} BAM)',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              '${_totalPrice.toStringAsFixed(2)} BAM',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        if (_duration >= 3) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_offer,
                                    size: 16,
                                    color: Colors.orange[700],
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Discount (10%)',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              Text(
                                '-${_discount.toStringAsFixed(2)} BAM',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_finalPrice.toStringAsFixed(2)} BAM',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '${_finalPrice.toStringAsFixed(2)} BAM',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    
                            _availableSlots.isEmpty ||
                            _selectedTimeSlot == null
                        ? null
                        : () async {
                          await _handleBooking();
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.payment),
                    const SizedBox(width: 8),
                    Text(
                      'Book Now',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBooking() async {
    final userId = widget.authProvider.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to make a booking'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show payment method selection dialog
    final paymentMethod = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Payment Method'),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.credit_card, color: Colors.green[700]),
                  title: const Text('Pay with Card'),
                  subtitle: const Text('Secure online payment'),
                  onTap: () => Navigator.of(context).pop('Card'),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.money, color: Colors.green[700]),
                  title: const Text('Cash on Arrival'),
                  subtitle: const Text('Pay at the venue'),
                  onTap: () => Navigator.of(context).pop('Cash'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );

    if (paymentMethod == null) return;

    // Show booking confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Booking'),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Venue: ${widget.venue.name}'),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                    ),
                    const SizedBox(height: 8),
                    Text('Time: $_selectedTimeSlot'),
                    const SizedBox(height: 8),
                    Text('Duration: $_duration hours'),
                    const SizedBox(height: 8),
                    Text(
                      'Total: ${_finalPrice.toStringAsFixed(2)} BAM',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            paymentMethod == 'Card'
                                ? Colors.blue[50]
                                : Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            paymentMethod == 'Card'
                                ? Icons.credit_card
                                : Icons.money,
                            color:
                                paymentMethod == 'Card'
                                    ? Colors.blue[700]
                                    : Colors.orange[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            paymentMethod == 'Card'
                                ? 'Payment: Card (Secure Payment)'
                                : 'Payment: Cash on Arrival',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    String? paymentIntentId;

    // If card payment, show Stripe payment sheet
    if (paymentMethod == 'Card') {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        // Create payment intent
        print('Creating payment intent for amount: $_finalPrice');
        final paymentIntentData = await _bookingProvider.createPaymentIntent(
          _finalPrice,
          'Booking at ${widget.venue.name}',
        );

        Navigator.of(context).pop();

        if (paymentIntentData == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to initialize payment. Please check your connection and try again.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }

        // Validate payment intent data
        if (!paymentIntentData.containsKey('clientSecret') ||
            paymentIntentData['clientSecret'] == null) {
          print('Invalid payment intent data: $paymentIntentData');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Payment configuration error. Please contact support.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }

        print('Payment intent created, initializing payment sheet...');

        // Initialize payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentData['clientSecret'],
            merchantDisplayName: 'Terena',
            style: ThemeMode.light,
          ),
        );

        print('Presenting payment sheet...');

        // Present payment sheet
        await Stripe.instance.presentPaymentSheet();

        print('Payment completed successfully');

        paymentIntentId = paymentIntentData['paymentIntentId'];
      } on StripeException catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop();
          print('Stripe error: ${e.error.code} - ${e.error.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Payment error: ${e.error.localizedMessage ?? e.error.message}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop();
          print('Payment error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment cancelled or failed. Please try again.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    // Create booking
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final timeParts = _selectedTimeSlot!.split(':');
    final startTime = DateTime.utc(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    final endTime = startTime.add(Duration(hours: _duration));

    final booking = await _bookingProvider.createBooking(
      userId: userId,
      venueId: widget.venue.id,
      bookingDate: DateTime.utc(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
      startTime: startTime,
      endTime: endTime,
      pricePerHour: widget.venue.pricePerHour ?? 0,
      numberOfPlayers: 1,
      notes: null,
      paymentMethod: paymentMethod,
      stripePaymentIntentId: paymentIntentId,
    );

    Navigator.of(context).pop();

    if (booking != null) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 32),
                  const SizedBox(width: 12),
                  const Text('Booking Created!'),
                ],
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Number: ${booking.bookingNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text('Venue: ${booking.venueName}'),
                    Text(
                      'Date: ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                    ),
                    Text('Time: $_selectedTimeSlot - ${endTime.hour}:00'),
                    Text('Duration: $_duration hours'),
                    const SizedBox(height: 12),
                    Text(
                      'Total: ${_finalPrice.toStringAsFixed(2)} BAM',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            paymentMethod == 'Card'
                                ? Colors.blue[50]
                                : Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        paymentMethod == 'Card'
                            ? 'Status: Pending confirmation\nPayment: Card (Paid)'
                            : 'Status: Pending confirmation\nPayment: Cash on arrival',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );

      _loadAvailableSlots();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create booking. Time slot may be taken.'),
          backgroundColor: Colors.red,
        ),
      );
      _loadAvailableSlots();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.green[700]),
      label: Text(label),
      backgroundColor: Colors.green[50],
      side: BorderSide(color: Colors.green[200]!),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 16, color: Colors.orange[900])),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.orange[900]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueImage(String imageUrl, double height) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64Data = imageUrl.split(',')[1];
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: height,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              height: height,
              child: Icon(
                Icons.sports_soccer,
                size: 100,
                color: Colors.grey[400],
              ),
            );
          },
        );
      } catch (e) {
        return Container(
          color: Colors.grey[300],
          height: height,
          child: Icon(Icons.sports_soccer, size: 100, color: Colors.grey[400]),
        );
      }
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          height: height,
          child: Icon(Icons.sports_soccer, size: 100, color: Colors.grey[400]),
        );
      },
    );
  }
}


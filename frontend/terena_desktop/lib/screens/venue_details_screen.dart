import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:terena_admin/layouts/master_screen.dart';
import 'package:terena_admin/models/venue.dart';
import 'package:terena_admin/providers/venue_provider.dart';

class VenueDetailsScreen extends StatefulWidget {
  final Venue venue;

  const VenueDetailsScreen({super.key, required this.venue});

  @override
  State<VenueDetailsScreen> createState() => _VenueDetailsScreenState();
}

class _VenueDetailsScreenState extends State<VenueDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late VenueProvider venueProvider;
  bool isLoading = false;
  List<String> selectedAmenities = [];
  File? selectedImage;
  String? selectedImagePath;

  final TextEditingController cancellationFeeController =
      TextEditingController();
  final TextEditingController discountPercentageController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    venueProvider = context.read<VenueProvider>();
    _loadVenueDetails();
  }

  Future<void> _loadVenueDetails() async {
    try {
      print('Loading venue details for ID: ${widget.venue.id}');
      final fullVenue = await venueProvider.getById(widget.venue.id!);

      print('Full venue loaded:');
      print('CancellationPolicy: ${fullVenue?.cancellationPolicy}');
      print('CancellationPolicy Fee: ${fullVenue?.cancellationPolicy?.fee}');
      print('Discount: ${fullVenue?.discount}');
      print('Discount Percentage: ${fullVenue?.discount?.percentage}');

      if (fullVenue != null) {
        setState(() {
          if (fullVenue.amenities != null && fullVenue.amenities!.isNotEmpty) {
            selectedAmenities = List<String>.from(fullVenue.amenities!);
          }

          if (fullVenue.cancellationPolicy?.fee != null) {
            cancellationFeeController.text =
                fullVenue.cancellationPolicy!.fee!.toString();
            print(
              'Set cancellationFeeController: ${cancellationFeeController.text}',
            );
          }
          if (fullVenue.discount?.percentage != null) {
            discountPercentageController.text =
                fullVenue.discount!.percentage!.toString();
            print(
              'Set discountPercentageController: ${discountPercentageController.text}',
            );
          }
        });
      }
    } catch (e) {
      print('Error loading venue details: $e');
    }
  }

  @override
  void dispose() {
    cancellationFeeController.dispose();
    discountPercentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      Container(
        color: Colors.white,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Venue Details',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(height: 30),
                      FormBuilder(
                        key: _formKey,
                        initialValue: {
                          'name': widget.venue.name,
                          'location': widget.venue.location,
                          'address': widget.venue.address,
                          'sportType': widget.venue.sportType,
                          'surfaceType': widget.venue.surfaceType,
                          'pricePerHour': widget.venue.pricePerHour?.toString(),
                          'availableSlots':
                              widget.venue.availableSlots?.toString(),
                          'description': widget.venue.description,
                          'contactPhone': widget.venue.contactPhone,
                          'contactEmail': widget.venue.contactEmail,
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTextField('name', 'Venue name'),
                                  const SizedBox(height: 20),
                                  _buildDropdown('location', 'Location', [
                                    'Sarajevo',
                                    'Mostar',
                                    'Banja Luka',
                                    'Neum',
                                  ]),
                                  const SizedBox(height: 20),
                                  _buildTextField('address', 'Address'),
                                  const SizedBox(height: 20),
                                  _buildDropdown('sportType', 'Sport type', [
                                    'Tennis',
                                    'Basketball',
                                    'Football',
                                  ]),
                                  const SizedBox(height: 20),
                                  _buildDropdown(
                                    'surfaceType',
                                    'Surface type',
                                    ['Grass', 'Clay', 'Hardwood'],
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    'pricePerHour',
                                    'Price per hour',
                                    suffix: 'BAM',
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    'availableSlots',
                                    'Available slots',
                                  ),
                                  const SizedBox(height: 20),
                                  _buildAmenities(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 30),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTextField(
                                    'description',
                                    'Description',
                                    maxLines: 4,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildCancellationPolicy(),
                                  const SizedBox(height: 20),
                                  _buildDiscount(),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    'contactPhone',
                                    'Contact phone',
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    'contactEmail',
                                    'Contact email',
                                  ),
                                  const SizedBox(height: 30),
                                  _buildVenueImage(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildActionButtons(),
                    ],
                  ),
                ),
      ),
      'Venue Details',
    );
  }

  Widget _buildTextField(
    String name,
    String label, {
    String? suffix,
    int maxLines = 1,
  }) {
    return FormBuilderTextField(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildDropdown(String name, String label, List<String> items) {
    return FormBuilderDropdown<String>(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      items:
          items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
    );
  }

  Widget _buildAmenities() {
    final amenitiesList = [
      {'icon': Icons.local_parking, 'name': 'Parking'},
      {'icon': Icons.wc, 'name': 'Restrooms'},
      {'icon': Icons.shower, 'name': 'Showers'},
      {'icon': Icons.water_drop, 'name': 'Water Fountain'},
      {'icon': Icons.light, 'name': 'Lighting'},
      {'icon': Icons.wifi, 'name': 'WiFi'},
      {'icon': Icons.video_camera_back, 'name': 'CCTV'},
      {'icon': Icons.chair, 'name': 'Seating Area'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Amenities',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: amenitiesList.length,
          itemBuilder: (context, index) {
            final amenity = amenitiesList[index];
            final isSelected = selectedAmenities.contains(amenity['name']);

            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedAmenities.remove(amenity['name']);
                  } else {
                    selectedAmenities.add(amenity['name'] as String);
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color.fromRGBO(56, 142, 60, 0.1)
                          : Colors.grey[50],
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color.fromRGBO(56, 142, 60, 1)
                            : Colors.grey[300]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      amenity['icon'] as IconData,
                      color:
                          isSelected
                              ? const Color.fromRGBO(56, 142, 60, 1)
                              : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        amenity['name'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color:
                              isSelected
                                  ? const Color.fromRGBO(56, 142, 60, 1)
                                  : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCancellationPolicy() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cancellation policy',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: cancellationFeeController,
            decoration: const InputDecoration(
              labelText: 'Cancellation Fee (%)',
              hintText: 'Enter percentage (e.g., 20 for 20%)',
              prefixIcon: Icon(Icons.percent, size: 18),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          Text(
            'This fee applies after the cancellation deadline',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscount() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Discount',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: discountPercentageController,
            decoration: const InputDecoration(
              labelText: 'Discount Percentage (%)',
              hintText: 'Enter percentage (e.g., 10 for 10%)',
              prefixIcon: Icon(Icons.discount, size: 18),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          Text(
            'Discount applies for bookings of 3+ hours',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTextField(
    String labelText,
    String hint,
    IconData? icon, {
    String? additionalLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (additionalLabel != null) ...[
          Text(
            additionalLabel,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 5),
        ],
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 18) : null,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildVenueImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.image, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Venue Image',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          height: 350,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                selectedImage != null
                    ? Image.file(selectedImage!, fit: BoxFit.cover)
                    : (widget.venue.venueImageUrl != null &&
                        widget.venue.venueImageUrl!.isNotEmpty)
                    ? _buildImageFromUrl(widget.venue.venueImageUrl!)
                    : const Center(
                      child: Icon(Icons.image, size: 64, color: Colors.grey),
                    ),
          ),
        ),
        if (selectedImagePath != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'New image selected: ${selectedImagePath!.split('\\').last}',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.red),
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    selectedImage = null;
                    selectedImagePath = null;
                  });
                },
              ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'CHANGE PHOTO',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () {
            _showDeleteConfirmation();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('DELETE VENUE', style: TextStyle(fontSize: 13)),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('CANCEL', style: TextStyle(fontSize: 13)),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _saveChanges,
          icon: const Icon(Icons.save, size: 20),
          label: const Text(
            'SAVE CHANGES',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Delete Venue',
      text:
          'Are you sure you want to delete this venue? This action cannot be undone.',
      confirmBtnText: 'Delete',
      cancelBtnText: 'Cancel',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        Navigator.pop(context);
        try {
          await venueProvider.delete(widget.venue.id!);
          if (mounted) {
            Navigator.pop(context, true);
            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: 'Success',
              text: 'Venue has been deleted successfully',
            );
          }
        } catch (e) {
          if (mounted) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Error',
              text: e.toString(),
            );
          }
        }
      },
    );
  }

  void _saveChanges() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => isLoading = true);

      try {
        final values = _formKey.currentState!.value;

        Map<String, dynamic>? cancellationPolicy;
        if (cancellationFeeController.text.isNotEmpty) {
          cancellationPolicy = {
            'freeUntil':
                DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
            'fee': double.tryParse(cancellationFeeController.text) ?? 0.0,
          };
        }

        Map<String, dynamic>? discount;
        if (discountPercentageController.text.isNotEmpty) {
          discount = {
            'percentage':
                double.tryParse(discountPercentageController.text) ?? 0.0,
            'forBookings': 3,
          };
        }

        final updateData = {
          'name': values['name'],
          'location': values['location'],
          'address': values['address'],
          'sportType': values['sportType'],
          'surfaceType': values['surfaceType'],
          'description': values['description'] ?? '',
          'pricePerHour': double.tryParse(values['pricePerHour'] ?? '0') ?? 0.0,
          'availableSlots': int.tryParse(values['availableSlots'] ?? '0') ?? 0,
          'contactPhone': values['contactPhone'],
          'contactEmail': values['contactEmail'],
          'amenities': selectedAmenities,
          'hasParking': selectedAmenities.contains('Parking'),
          'hasShowers': selectedAmenities.contains('Showers'),
          'hasLighting': selectedAmenities.contains('Lighting'),
          'hasChangingRooms': selectedAmenities.contains('Restrooms'),
          'hasEquipmentRental': selectedAmenities.contains('WiFi'),
          'hasCafeBar': selectedAmenities.contains('CCTV'),
          'hasWaterFountain': selectedAmenities.contains('Water Fountain'),
          'hasSeatingArea': selectedAmenities.contains('Seating Area'),
          'cancellationPolicy': cancellationPolicy,
          'discount': discount,
        };

        if (selectedImage != null) {
          final bytes = await selectedImage!.readAsBytes();
          final base64Image = base64Encode(bytes);
          updateData['venueImageUrl'] = 'data:image/jpeg;base64,$base64Image';
        } else if (widget.venue.venueImageUrl != null) {
          updateData['venueImageUrl'] = widget.venue.venueImageUrl;
        }

        await venueProvider.update(widget.venue.id!, updateData);

        if (mounted) {
          Navigator.pop(context, true);
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Success',
            text: 'Venue has been updated successfully',
          );
        }
      } catch (e) {
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Error',
            text: e.toString(),
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          selectedImagePath = result.files.single.path!;
          selectedImage = File(selectedImagePath!);
        });
      }
    } catch (e) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Failed to select image',
        );
      }
    }
  }

  Widget _buildImageFromUrl(String imageUrl) {
    if (imageUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.image, size: 64, color: Colors.grey),
      );
    }

    try {
      if (imageUrl.startsWith('data:image')) {
        final base64Data = imageUrl.split(',')[1];
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
            );
          },
        );
      } else {
        return const Center(
          child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
        );
      }
    } catch (e) {
      return const Center(
        child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
      );
    }
  }
}

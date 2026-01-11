import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
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

  @override
  void initState() {
    super.initState();
    venueProvider = context.read<VenueProvider>();
    selectedAmenities = widget.venue.amenities ?? [];
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
                          'cancellationFreeUntil':
                              widget.venue.cancellationPolicy?.freeUntil
                                  ?.toIso8601String()
                                  .split('T')[0],
                          'cancellationFee':
                              widget.venue.cancellationPolicy?.fee?.toString(),
                          'discountPercentage':
                              widget.venue.discount?.percentage?.toString(),
                          'discountForBookings':
                              widget.venue.discount?.forBookings?.toString(),
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
                                    'Zagreb',
                                    'Beograd',
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
                                  _buildOperatingHours(),
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

  Widget _buildOperatingHours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Operating Hours',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 15),
        if (widget.venue.operatingHours != null &&
            widget.venue.operatingHours!.isNotEmpty)
          ...widget.venue.operatingHours!.map(
            (oh) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildOperatingHourRow(
                oh.day ?? '',
                '${oh.startTime ?? ''} - ${oh.endTime ?? ''}',
                Colors.green,
              ),
            ),
          )
        else
          const Text(
            'No operating hours set',
            style: TextStyle(color: Colors.grey),
          ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add time slot'),
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromRGBO(32, 76, 56, 1),
          ),
        ),
      ],
    );
  }

  Widget _buildOperatingHourRow(String day, String hours, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              day,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            hours,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    final amenitiesList = [
      'Parking',
      'Showers',
      'Lighting',
      'Changing Rooms',
      'Equipment Rental',
      'Cafe/Bar',
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
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              amenitiesList.map((amenity) {
                final isSelected = selectedAmenities.contains(amenity);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedAmenities.remove(amenity);
                      } else {
                        selectedAmenities.add(amenity);
                      }
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedAmenities.add(amenity);
                            } else {
                              selectedAmenities.remove(amenity);
                            }
                          });
                        },
                        activeColor: const Color.fromRGBO(32, 76, 56, 1),
                      ),
                      Text(amenity),
                    ],
                  ),
                );
              }).toList(),
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
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: 'cancellationFreeUntil',
                  decoration: const InputDecoration(
                    labelText: 'Free until',
                    hintText: 'mm / dd / yyyy',
                    prefixIcon: Icon(Icons.calendar_today, size: 18),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  name: 'cancellationFee',
                  decoration: const InputDecoration(
                    labelText: 'Fee (%)',
                    hintText: '0',
                    prefixIcon: Icon(Icons.percent, size: 18),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ],
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormBuilderTextField(
                      name: 'discountPercentage',
                      decoration: const InputDecoration(
                        labelText: 'Discount %',
                        hintText: '0',
                        prefixIcon: Icon(Icons.percent, size: 18),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormBuilderTextField(
                      name: 'discountForBookings',
                      decoration: const InputDecoration(
                        labelText: 'For bookings',
                        hintText: '0',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
          height: 200,
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
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: const Text('DELETE VENUE'),
        ),
        const SizedBox(width: 15),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: const Text('CANCEL'),
        ),
        const SizedBox(width: 15),
        ElevatedButton(
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(32, 76, 56, 1),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: const Text(
            'SAVE CHANGES',
            style: TextStyle(color: Colors.white),
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
        if (values['cancellationFreeUntil'] != null &&
            values['cancellationFee'] != null) {
          try {
            cancellationPolicy = {
              'freeUntil':
                  DateTime.parse(
                    values['cancellationFreeUntil'],
                  ).toIso8601String(),
              'fee': double.tryParse(values['cancellationFee'] ?? '0') ?? 0.0,
            };
          } catch (e) {}
        }

        Map<String, dynamic>? discount;
        if (values['discountPercentage'] != null &&
            values['discountForBookings'] != null) {
          discount = {
            'percentage':
                double.tryParse(values['discountPercentage'] ?? '0') ?? 0.0,
            'forBookings':
                int.tryParse(values['discountForBookings'] ?? '0') ?? 0,
          };
        }

        List<Map<String, dynamic>>? operatingHours;
        if (widget.venue.operatingHours != null &&
            widget.venue.operatingHours!.isNotEmpty) {
          operatingHours =
              widget.venue.operatingHours!
                  .map(
                    (oh) => {
                      'day': oh.day,
                      'startTime': oh.startTime,
                      'endTime': oh.endTime,
                    },
                  )
                  .toList();
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
          'operatingHours': operatingHours,
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

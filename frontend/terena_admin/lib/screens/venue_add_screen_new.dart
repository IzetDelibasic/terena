import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:terena_admin/providers/venue_provider.dart';

class VenueAddScreenNew extends StatefulWidget {
  const VenueAddScreenNew({super.key});

  @override
  State<VenueAddScreenNew> createState() => _VenueAddScreenNewState();
}

class _VenueAddScreenNewState extends State<VenueAddScreenNew> {
  final _formKey = GlobalKey<FormBuilderState>();
  late VenueProvider venueProvider;
  bool isLoading = false;
  int selectedTab = 0;

  List<String> selectedAmenities = [];
  File? selectedImage;
  String? selectedImagePath;

  final List<Map<String, dynamic>> tabs = [
    {'icon': Icons.info_outline, 'title': 'Basic Info'},
    {'icon': Icons.sports_soccer, 'title': 'Amenities'},
    {'icon': Icons.attach_money, 'title': 'Pricing'},
    {'icon': Icons.policy, 'title': 'Policies'},
  ];

  @override
  void initState() {
    super.initState();
    venueProvider = context.read<VenueProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(56, 142, 60, 1),
        title: const Text(
          "Add New Venue",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                'Step ${selectedTab + 1} of ${tabs.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSidebar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(30),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 900),
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
                          padding: const EdgeInsets.all(40),
                          child: FormBuilder(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTabContent(),
                                const SizedBox(height: 40),
                                _buildActionButtons(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: const Color.fromRGBO(250, 250, 250, 1),
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Venue Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Fill in all required information',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 25),
          ...tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = selectedTab == index;
            final isCompleted = index < selectedTab;

            return InkWell(
              onTap: () => setState(() => selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color.fromRGBO(56, 142, 60, 0.08)
                          : Colors.transparent,
                  border: Border(
                    left: BorderSide(
                      color:
                          isSelected
                              ? const Color.fromRGBO(56, 142, 60, 1)
                              : Colors.transparent,
                      width: 4,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color:
                            isCompleted
                                ? const Color.fromRGBO(56, 142, 60, 1)
                                : isSelected
                                ? const Color.fromRGBO(56, 142, 60, 0.2)
                                : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : tab['icon'] as IconData,
                        color:
                            isCompleted
                                ? Colors.white
                                : isSelected
                                ? const Color.fromRGBO(56, 142, 60, 1)
                                : Colors.grey[500],
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tab['title'] as String,
                        style: TextStyle(
                          fontSize: 14,
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
          }),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 0:
        return _buildBasicInfo();
      case 1:
        return _buildAmenities();
      case 2:
        return _buildPricing();
      case 3:
        return _buildPolicies();
      default:
        return _buildBasicInfo();
    }
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Basic Information",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(32, 76, 56, 1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Enter the basic details about your venue",
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
        ),
        const Divider(height: 40),
        Row(
          children: [
            Expanded(
              child: FormBuilderTextField(
                name: 'name',
                decoration: InputDecoration(
                  labelText: 'Venue Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: FormBuilderValidators.required(
                  errorText: 'Required field',
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: FormBuilderDropdown<String>(
                name: 'sportType',
                decoration: InputDecoration(
                  labelText: 'Sport Type *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items:
                    ['Tennis', 'Basketball', 'Football']
                        .map(
                          (sport) => DropdownMenuItem(
                            value: sport,
                            child: Text(sport),
                          ),
                        )
                        .toList(),
                validator: FormBuilderValidators.required(
                  errorText: 'Required field',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: FormBuilderDropdown<String>(
                name: 'location',
                decoration: InputDecoration(
                  labelText: 'Location (City) *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.location_city),
                ),
                items:
                    ['Sarajevo', 'Mostar', 'Zagreb', 'Beograd']
                        .map(
                          (city) =>
                              DropdownMenuItem(value: city, child: Text(city)),
                        )
                        .toList(),
                validator: FormBuilderValidators.required(
                  errorText: 'Required field',
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: FormBuilderTextField(
                name: 'address',
                decoration: InputDecoration(
                  labelText: 'Full Address *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.location_on),
                ),
                validator: FormBuilderValidators.required(
                  errorText: 'Required field',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FormBuilderDropdown<String>(
          name: 'surfaceType',
          decoration: InputDecoration(
            labelText: 'Surface Type *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items:
              ['Grass', 'Clay', 'Hardwood']
                  .map(
                    (surface) =>
                        DropdownMenuItem(value: surface, child: Text(surface)),
                  )
                  .toList(),
          validator: FormBuilderValidators.required(
            errorText: 'Required field',
          ),
        ),
        const SizedBox(height: 20),
        FormBuilderTextField(
          name: 'description',
          decoration: InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[50],
            alignLabelWithHint: true,
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 20),
        const Text(
          'Venue Image',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child:
                selectedImage != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(selectedImage!, fit: BoxFit.cover),
                    )
                    : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Click to upload venue image',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
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
                  'Selected: ${selectedImagePath!.split('\\').last}',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.red),
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
      ],
    );
  }

  Widget _buildOperatingHours() {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Operating Hours",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(32, 76, 56, 1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Set your venue's working hours for each day",
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
        ),
        const Divider(height: 40),
        ...days.map(
          (day) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: FormBuilderTextField(
                    name: 'operatingHours_${day.toLowerCase()}_start',
                    decoration: InputDecoration(
                      labelText: 'Open Time',
                      hintText: '08:00',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      isDense: true,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text('to', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(
                  child: FormBuilderTextField(
                    name: 'operatingHours_${day.toLowerCase()}_end',
                    decoration: InputDecoration(
                      labelText: 'Close Time',
                      hintText: '22:00',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
        const Text(
          "Amenities & Facilities",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(32, 76, 56, 1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Select available amenities at your venue",
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
        ),
        const Divider(height: 40),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 2.5,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      amenity['icon'] as IconData,
                      color:
                          isSelected
                              ? const Color.fromRGBO(56, 142, 60, 1)
                              : Colors.grey[600],
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
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
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPricing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pricing & Contact",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(32, 76, 56, 1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Set your pricing and contact information",
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
        ),
        const Divider(height: 40),
        const Text(
          "Pricing",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: FormBuilderTextField(
                name: 'pricePerHour',
                decoration: InputDecoration(
                  labelText: 'Price per Hour (BAM) *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Required field'),
                  FormBuilderValidators.numeric(
                    errorText: 'Enter valid number',
                  ),
                ]),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: FormBuilderTextField(
                name: 'availableSlots',
                decoration: InputDecoration(
                  labelText: 'Available Slots',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.event_available),
                ),
                keyboardType: TextInputType.number,
                initialValue: '0',
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          "Contact Information",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: FormBuilderTextField(
                name: 'contactPhone',
                decoration: InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: FormBuilderValidators.required(
                  errorText: 'Required field',
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: FormBuilderTextField(
                name: 'contactEmail',
                decoration: InputDecoration(
                  labelText: 'Email Address *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Required field'),
                  FormBuilderValidators.email(errorText: 'Enter valid email'),
                ]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPolicies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Policies",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(32, 76, 56, 1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Configure cancellation and refund policies",
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
        ),
        const Divider(height: 40),
        const Text(
          "Cancellation Policy",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        FormBuilderTextField(
          name: 'cancellationPolicyHours',
          decoration: InputDecoration(
            labelText: 'Free cancellation hours before booking',
            hintText: 'e.g., 24',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[50],
            helperText:
                'Users can cancel for free up to this many hours before',
            prefixIcon: const Icon(Icons.schedule),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        FormBuilderTextField(
          name: 'cancellationFeePercentage',
          decoration: InputDecoration(
            labelText: 'Cancellation fee (%)',
            hintText: 'e.g., 20',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[50],
            helperText: 'Fee charged if cancelled after the free period',
            prefixIcon: const Icon(Icons.percent),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 30),
        const Text(
          "Refund Policy",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        FormBuilderTextField(
          name: 'refundProcessingDays',
          decoration: InputDecoration(
            labelText: 'Refund processing time (days)',
            hintText: 'e.g., 7',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[50],
            helperText: 'Number of business days to process refunds',
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (selectedTab > 0)
          OutlinedButton.icon(
            onPressed: () => setState(() => selectedTab--),
            icon: const Icon(Icons.arrow_back),
            label: const Text('PREVIOUS'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(color: Color.fromRGBO(32, 76, 56, 1)),
              foregroundColor: const Color.fromRGBO(32, 76, 56, 1),
            ),
          )
        else
          const SizedBox(),
        Row(
          children: [
            if (selectedTab < tabs.length - 1)
              ElevatedButton.icon(
                onPressed: () => setState(() => selectedTab++),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('NEXT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(32, 76, 56, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            if (selectedTab == tabs.length - 1)
              ElevatedButton.icon(
                onPressed: _saveVenue,
                icon: const Icon(Icons.check),
                label: const Text('SAVE VENUE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(32, 76, 56, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveVenue() async {
    _formKey.currentState?.save();

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);

      try {
        final values = _formKey.currentState!.value;

        final venueData = {
          'name': values['name'],
          'location': values['location'],
          'address': values['address'],
          'sportType': values['sportType'],
          'surfaceType': values['surfaceType'],
          'description': values['description'] ?? '',
          'pricePerHour':
              double.tryParse(values['pricePerHour']?.toString() ?? '0') ?? 0.0,
          'availableSlots':
              int.tryParse(values['availableSlots']?.toString() ?? '0') ?? 0,
          'contactPhone': values['contactPhone'],
          'contactEmail': values['contactEmail'],
          'amenities': selectedAmenities,
          'cancellationPolicyHours':
              int.tryParse(
                values['cancellationPolicyHours']?.toString() ?? '0',
              ) ??
              0,
          'cancellationFeePercentage':
              double.tryParse(
                values['cancellationFeePercentage']?.toString() ?? '0',
              ) ??
              0.0,
          'refundProcessingDays':
              int.tryParse(values['refundProcessingDays']?.toString() ?? '0') ??
              0,
        };

        if (selectedImage != null) {
          final bytes = await selectedImage!.readAsBytes();
          final base64Image = base64Encode(bytes);
          venueData['venueImageUrl'] = 'data:image/jpeg;base64,$base64Image';
        }

        await venueProvider.insert(venueData);

        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: "Success!",
            text: "Venue has been successfully created",
            confirmBtnText: "OK",
            onConfirmBtnTap: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
          );
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = e.toString();

          if (errorMessage.startsWith('Exception: ')) {
            errorMessage = errorMessage.substring('Exception: '.length);
          }

          if (errorMessage.contains('\n')) {
            errorMessage = errorMessage.split('\n').first;
          }

          if (errorMessage.length > 500) {
            errorMessage = errorMessage.substring(0, 500) + '...';
          }

          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Error Creating Venue",
            text: errorMessage,
            confirmBtnText: "OK",
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } else {
      final invalidFields = <String>[];
      _formKey.currentState?.fields.forEach((key, field) {
        if (field.hasError) {
          invalidFields.add(key);
        }
      });

      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: "Validation Error",
        text:
            "Please fill in all required fields correctly.\nCheck: ${invalidFields.join(', ')}",
        confirmBtnText: "OK",
      );
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
          title: "Error",
          text: "Failed to select image",
        );
      }
    }
  }
}

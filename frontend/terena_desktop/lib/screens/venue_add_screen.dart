import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:terena_admin/providers/venue_provider.dart';
import 'package:terena_admin/models/venue.dart';

class VenueAddScreen extends StatefulWidget {
  final Venue? venue;

  const VenueAddScreen({super.key, this.venue});

  @override
  State<VenueAddScreen> createState() => _VenueAddScreenState();
}

class _VenueAddScreenState extends State<VenueAddScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  final _basicInfoKey = GlobalKey<FormBuilderState>();
  final _amenitiesKey = GlobalKey<FormBuilderState>();
  final _policiesKey = GlobalKey<FormBuilderState>();

  final Map<String, dynamic> _formData = {};
  File? _selectedImage;
  String? _selectedImagePath;

  bool get _isEditMode => widget.venue != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode && widget.venue != null) {
      _loadVenueData();
    }
  }

  void _loadVenueData() {
    final venue = widget.venue!;
    print('Loading venue data:');
    print('CancellationPolicy: ${venue.cancellationPolicy}');
    print('CancellationPolicy Fee: ${venue.cancellationPolicy?.fee}');
    print('Discount: ${venue.discount}');
    print('Discount Percentage: ${venue.discount?.percentage}');

    _formData.addAll({
      'name': venue.name,
      'location': venue.location,
      'address': venue.address,
      'sportType': venue.sportType,
      'surfaceType': venue.surfaceType,
      'pricePerHour': venue.pricePerHour?.toString(),
      'availableSlots': venue.availableSlots?.toString(),
      'description': venue.description,
      'contactPhone': venue.contactPhone,
      'contactEmail': venue.contactEmail,
      'hasParking': venue.hasParking,
      'hasShowers': venue.hasShowers,
      'hasLighting': venue.hasLighting,
      'hasChangingRooms': venue.hasChangingRooms,
      'hasEquipmentRental': venue.hasEquipmentRental,
      'hasCafeBar': venue.hasCafeBar,
      'hasWaterFountain': venue.hasWaterFountain,
      'hasSeatingArea': venue.hasSeatingArea,
      'cancellationFeePercentage': venue.cancellationPolicy?.fee?.toString(),
      'discountPercentage': venue.discount?.percentage?.toString(),
    });

    print(
      'FormData cancellationFeePercentage: ${_formData['cancellationFeePercentage']}',
    );
    print('FormData discountPercentage: ${_formData['discountPercentage']}');
  }

  bool get _isStepComplete {
    switch (_currentStep) {
      case 0:
        return _basicInfoKey.currentState?.saveAndValidate() ?? false;
      case 1:
        return true;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _saveCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_basicInfoKey.currentState?.saveAndValidate() ?? false) {
          _formData.addAll(_basicInfoKey.currentState!.value);
        }
        break;
      case 1:
        if (_amenitiesKey.currentState?.saveAndValidate() ?? false) {
          _formData.addAll(_amenitiesKey.currentState!.value);
        }
        break;
      case 2:
        if (_policiesKey.currentState?.saveAndValidate() ?? false) {
          _formData.addAll(_policiesKey.currentState!.value);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Venue' : 'Add New Venue',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Step ${_currentStep + 1} of 3',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 280,
            color: const Color(0xFFF5F5F5),
            child: Column(
              children: [
                _buildStepItem(
                  0,
                  'Venue Details',
                  'Fill in all required information',
                  Icons.info_outline,
                ),
                _buildStepItem(
                  1,
                  'Amenities',
                  'List available facilities',
                  Icons.star_outline,
                ),
                _buildStepItem(
                  2,
                  'Pricing & Policies',
                  'Set pricing and cancellation policies',
                  Icons.policy_outlined,
                ),
              ],
            ),
          ),
          Expanded(child: _buildCurrentStepContent()),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    int step,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isActive = _currentStep == step;
    final isCompleted =
        _currentStep > step || (_currentStep == step && _isStepComplete);

    return InkWell(
      onTap: () {
        _saveCurrentStep();
        setState(() => _currentStep = step);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? const Color(0xFF4CAF50) : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isCompleted
                        ? const Color(0xFF4CAF50)
                        : isActive
                        ? const Color(0xFF4CAF50).withOpacity(0.2)
                        : Colors.grey[300],
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                color:
                    isCompleted
                        ? Colors.white
                        : isActive
                        ? const Color(0xFF4CAF50)
                        : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                      color: isActive ? Colors.black : Colors.grey[700],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: _getStepContent(),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _getStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoForm();
      case 1:
        return _buildAmenitiesForm();
      case 2:
        return _buildPricingAndPoliciesForm();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBasicInfoForm() {
    return FormBuilder(
      key: _basicInfoKey,
      initialValue: _formData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Venue Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fill in all required information',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          FormBuilderTextField(
            name: 'name',
            decoration: const InputDecoration(
              labelText: 'Venue Name *',
              border: OutlineInputBorder(),
            ),
            validator: FormBuilderValidators.required(
              errorText: 'Required field',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FormBuilderDropdown<String>(
                  name: 'location',
                  decoration: const InputDecoration(
                    labelText: 'Location (City) *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Sarajevo',
                      child: Text('Sarajevo'),
                    ),
                    DropdownMenuItem(value: 'Mostar', child: Text('Mostar')),
                    DropdownMenuItem(
                      value: 'Banja Luka',
                      child: Text('Banja Luka'),
                    ),
                    DropdownMenuItem(value: 'Neum', child: Text('Neum')),
                  ],
                  validator: FormBuilderValidators.required(
                    errorText: 'Required',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FormBuilderTextField(
                  name: 'address',
                  decoration: const InputDecoration(
                    labelText: 'Address *',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: 'Required',
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
                  name: 'sportType',
                  decoration: const InputDecoration(
                    labelText: 'Sport Type *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Tennis', child: Text('Tennis')),
                    DropdownMenuItem(
                      value: 'Basketball',
                      child: Text('Basketball'),
                    ),
                    DropdownMenuItem(
                      value: 'Football',
                      child: Text('Football'),
                    ),
                  ],
                  validator: FormBuilderValidators.required(
                    errorText: 'Required',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FormBuilderDropdown<String>(
                  name: 'surfaceType',
                  decoration: const InputDecoration(
                    labelText: 'Surface Type *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Grass', child: Text('Grass')),
                    DropdownMenuItem(value: 'Clay', child: Text('Clay')),
                    DropdownMenuItem(
                      value: 'Hardwood',
                      child: Text('Hardwood'),
                    ),
                  ],
                  validator: FormBuilderValidators.required(
                    errorText: 'Required',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FormBuilderTextField(
            name: 'description',
            decoration: const InputDecoration(
              labelText: 'Description *',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            validator: FormBuilderValidators.required(errorText: 'Required'),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: 'contactPhone',
                  decoration: const InputDecoration(
                    labelText: 'Contact Phone *',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: 'Required',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FormBuilderTextField(
                  name: 'contactEmail',
                  decoration: const InputDecoration(
                    labelText: 'Contact Email *',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Required'),
                    FormBuilderValidators.email(errorText: 'Invalid email'),
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: 'pricePerHour',
                  decoration: const InputDecoration(
                    labelText: 'Price per Hour (BAM) *',
                    border: OutlineInputBorder(),
                    suffixText: 'BAM',
                  ),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Required'),
                    FormBuilderValidators.numeric(
                      errorText: 'Must be a number',
                    ),
                  ]),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FormBuilderTextField(
                  name: 'availableSlots',
                  decoration: const InputDecoration(
                    labelText: 'Available Slots *',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 18',
                  ),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Required'),
                    FormBuilderValidators.integer(
                      errorText: 'Must be an integer',
                    ),
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Venue Image',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              if (_selectedImage != null)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  ),
                ),
              if (_selectedImagePath != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Selected: ${_selectedImagePath!.split('\\').last}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.red,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                          _selectedImagePath = null;
                        });
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload, color: Colors.white),
                  label: Text(
                    _selectedImage == null ? 'CHOOSE IMAGE' : 'CHANGE IMAGE',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesForm() {
    return FormBuilder(
      key: _amenitiesKey,
      initialValue: _formData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amenities',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select available facilities',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  FormBuilderCheckbox(
                    name: 'hasParking',
                    title: const Text('Parking'),
                    initialValue: false,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                  const Divider(),
                  FormBuilderCheckbox(
                    name: 'hasShowers',
                    title: const Text('Showers'),
                    initialValue: false,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                  const Divider(),
                  FormBuilderCheckbox(
                    name: 'hasLighting',
                    title: const Text('Lighting'),
                    initialValue: false,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                  const Divider(),
                  FormBuilderCheckbox(
                    name: 'hasChangingRooms',
                    title: const Text('Restrooms'),
                    initialValue: false,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                  const Divider(),
                  FormBuilderCheckbox(
                    name: 'hasEquipmentRental',
                    title: const Text('WiFi'),
                    initialValue: false,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                  const Divider(),
                  FormBuilderCheckbox(
                    name: 'hasCafeBar',
                    title: const Text('CCTV'),
                    initialValue: false,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                  const Divider(),
                  FormBuilderCheckbox(
                    name: 'hasWaterFountain',
                    title: const Text('Water Fountain'),
                    initialValue: false,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                  const Divider(),
                  FormBuilderCheckbox(
                    name: 'hasSeatingArea',
                    title: const Text('Seating Area'),
                    initialValue: false,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingAndPoliciesForm() {
    return FormBuilder(
      key: _policiesKey,
      initialValue: _formData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pricing & Policies',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure cancellation and discount policies',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          const Text(
            'Cancellation Policy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'cancellationFeePercentage',
            decoration: const InputDecoration(
              labelText: 'Cancellation Fee (%)',
              border: OutlineInputBorder(),
              hintText: 'e.g., 50',
              helperText: 'This fee applies after the cancellation deadline',
            ),
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.numeric(errorText: 'Must be a number'),
              FormBuilderValidators.max(100, errorText: 'Cannot exceed 100%'),
            ]),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          const Text(
            'Discount',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Discount applies for bookings of 3+ hours',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'discountPercentage',
            decoration: const InputDecoration(
              labelText: 'Discount Percentage (%)',
              border: OutlineInputBorder(),
              hintText: 'e.g., 10',
            ),
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.numeric(errorText: 'Must be a number'),
              FormBuilderValidators.max(100, errorText: 'Cannot exceed 100%'),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            OutlinedButton(
              onPressed: () {
                _saveCurrentStep();
                setState(() => _currentStep--);
              },
              child: const Text('Previous'),
            )
          else
            const SizedBox(),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              if (_currentStep < 2)
                ElevatedButton(
                  onPressed:
                      _isStepComplete
                          ? () {
                            _saveCurrentStep();
                            setState(() => _currentStep++);
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Next'),
                )
              else
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveVenue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text('Save Venue'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveVenue() async {
    _saveCurrentStep();

    if (_formData['name'] == null || _formData['pricePerHour'] == null) {
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Please fill in all required information',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amenitiesList = <String>[];
      if (_formData['hasParking'] == true) amenitiesList.add('Parking');
      if (_formData['hasChangingRooms'] == true) amenitiesList.add('Restrooms');
      if (_formData['hasShowers'] == true) amenitiesList.add('Showers');
      if (_formData['hasWaterFountain'] == true)
        amenitiesList.add('Water Fountain');
      if (_formData['hasLighting'] == true) amenitiesList.add('Lighting');
      if (_formData['hasEquipmentRental'] == true) amenitiesList.add('WiFi');
      if (_formData['hasCafeBar'] == true) amenitiesList.add('CCTV');
      if (_formData['hasSeatingArea'] == true)
        amenitiesList.add('Seating Area');

      final request = {
        'name': _formData['name'],
        'location': _formData['location'],
        'address': _formData['address'],
        'sportType': _formData['sportType'],
        'surfaceType': _formData['surfaceType'],
        'pricePerHour':
            double.tryParse(_formData['pricePerHour']?.toString() ?? '0') ??
            0.0,
        'availableSlots':
            int.tryParse(_formData['availableSlots']?.toString() ?? '0') ?? 0,
        'description': _formData['description'],
        'contactPhone': _formData['contactPhone'],
        'contactEmail': _formData['contactEmail'],
        'amenities': amenitiesList,
        'hasParking': _formData['hasParking'] ?? false,
        'hasShowers': _formData['hasShowers'] ?? false,
        'hasLighting': _formData['hasLighting'] ?? false,
        'hasChangingRooms': _formData['hasChangingRooms'] ?? false,
        'hasEquipmentRental': _formData['hasEquipmentRental'] ?? false,
        'hasCafeBar': _formData['hasCafeBar'] ?? false,
        'hasWaterFountain': _formData['hasWaterFountain'] ?? false,
        'hasSeatingArea': _formData['hasSeatingArea'] ?? false,
      };

      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final base64Image = base64Encode(bytes);
        request['venueImageUrl'] = 'data:image/jpeg;base64,$base64Image';
      } else {
        request['venueImageUrl'] = '';
      }

      if (_formData['cancellationFeePercentage'] != null &&
          _formData['cancellationFeePercentage'].toString().isNotEmpty) {
        final fee = double.tryParse(
          _formData['cancellationFeePercentage']?.toString() ?? '0',
        );
        if (fee != null && fee > 0) {
          request['cancellationPolicy'] = {
            'freeUntil':
                DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
            'fee': fee,
          };
        }
      }

      if (_formData['discountPercentage'] != null &&
          _formData['discountPercentage'].toString().isNotEmpty) {
        final percentage = double.tryParse(
          _formData['discountPercentage']?.toString() ?? '0',
        );
        if (percentage != null && percentage > 0) {
          request['discount'] = {'percentage': percentage, 'forBookings': 3};
        }
      }

      final venueProvider = context.read<VenueProvider>();

      if (_isEditMode) {
        await venueProvider.update(widget.venue!.id!, request);
      } else {
        await venueProvider.insert(request);
      }

      if (mounted) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success!',
          text:
              _isEditMode
                  ? 'Venue has been updated successfully'
                  : 'Venue has been added successfully',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          _selectedImagePath = result.files.single.path!;
          _selectedImage = File(_selectedImagePath!);
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
}
